#!/bin/bash -e

shippable_decrypt() {
  local SECURE_FILE=$1
  local KEY_FILE=$2
  local TEMP_DEST='/home/shippable/decrypt'

  if [ -d "$TEMP_DEST" ]; then
    rm -r ${TEMP_DEST:?}
  fi
  mkdir -p $TEMP_DEST/fragments

  base64 --decode < "$SECURE_FILE" > $TEMP_DEST/encrypted.raw
  split -b 256 "$TEMP_DEST/encrypted.raw" $TEMP_DEST/fragments/
  local fragments
  fragments=$(ls -b $TEMP_DEST/fragments)
  for fragment in $fragments; do
    openssl rsautl -decrypt -inkey "$KEY_FILE" -oaep < "$TEMP_DEST/fragments/$fragment" >> "$SECURE_FILE.decrypted"
  done;

  rm -r ${TEMP_DEST:?}/*
}

shippable_decrypt "$1" "$2"
