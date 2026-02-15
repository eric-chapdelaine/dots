#!/usr/bin/env bash
set -euo pipefail

HOME_DIR="/home/emchap4"

DEV_NAME="/dev/$1"
MOUNT_POINT="$HOME_DIR/rx100"

MOUNT_POINT="$HOME_DIR/rx100"

mount "$DEV_NAME" "$MOUNT_POINT"

SRC="$MOUNT_POINT/DCIM/100MSDCF"
BASE_DEST="$HOME_DIR/Pictures"
RAW_DEST="$BASE_DEST/RAW"
JPEG_DEST="$BASE_DEST/JPEG"
NEW_FILES_LOG="$BASE_DEST/rsync_new_files.log"
TO_UPLOAD_DIR="$BASE_DEST/to-upload"

#mkdir -p "$RAW_DEST"

rsync -av --ignore-existing \
  --include='*/' \
  --include='*.ARW' \
  --exclude='*' \
  "$SRC/" "$RAW_DEST/"

rsync -av --ignore-existing \
  --include='*/' \
  --include='*.JPG' \
  --exclude='*' \
  --log-file="$NEW_FILES_LOG" \
  "$SRC/" "$JPEG_DEST/"

awk '/>f\+/{print $NF}' "$NEW_FILES_LOG" \
  | while read -r file; do
      cp "$JPEG_DEST/$file" "$TO_UPLOAD_DIR/$file"
    done

    GPHOTOS_CLI_TOKENSTORE_KEY=$(cat /home/emchap4/scripts/camera/GPHOTOS_TOKENSTORE_KEY) /home/emchap4/.local/bin/gphotos-uploader-cli push --config /home/emchap4/.gphotos-uploader-cli

echo "Camera import complete"

umount $MOUNT_POINT
