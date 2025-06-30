#!/bin/bash

# Usage:
#   ./sync_plone_instance.sh /local/plone-instance user@remote:/remote/plone-instance
#   ./sync_plone_instance.sh --dry-run /local/plone-instance user@remote:/remote/plone-instance

# --- Parse arguments ---
DRY_RUN=false

if [ "$1" == "--dry-run" ]; then
  DRY_RUN=true
  shift
fi

INSTANCE_DIR="$1"
REMOTE_PATH="$2"

# --- Validate inputs ---
if [ -z "$INSTANCE_DIR" ] || [ -z "$REMOTE_PATH" ]; then
  echo "Usage: $0 [--dry-run] /local/plone-instance user@remote:/remote/plone-instance"
  exit 1
fi

if [ ! -d "$INSTANCE_DIR" ]; then
  echo "Error: Local instance directory $INSTANCE_DIR does not exist."
  exit 2
fi

INSTANCE_NAME=$(basename "$INSTANCE_DIR")

echo "Syncing Plone instance: $INSTANCE_NAME"
echo "  Local:  $INSTANCE_DIR"
echo "  Remote: $REMOTE_PATH"
if [ "$DRY_RUN" = true ]; then
  echo "  Mode:   DRY RUN (no data will be transferred, no services will be stopped or started)"
fi

# --- Stop via supervisor (only if not dry-run) ---
if [ "$DRY_RUN" = false ]; then
  echo "Stopping $INSTANCE_NAME"
  supervisorctl stop "$INSTANCE_NAME"
else
  echo "[DRY RUN] Skipping supervisorctl stop"
fi

# --- Run rsync ---
RSYNC_OPTIONS="-az --delete"
if [ "$DRY_RUN" = true ]; then
  RSYNC_OPTIONS="$RSYNC_OPTIONS --dry-run"
fi

echo "Running rsync from $INSTANCE_DIR/var/ to $REMOTE_PATH/var/"
rsync $RSYNC_OPTIONS -e ssh "$INSTANCE_DIR/var/" "$REMOTE_PATH/var/"

# --- Restart via supervisor (only if not dry-run) ---
if [ "$DRY_RUN" = false ]; then
  echo "Restarting $INSTANCE_NAME"
  supervisorctl start "$INSTANCE_NAME"
else
  echo "[DRY RUN] Skipping supervisorctl start"
fi

echo "Sync complete for $INSTANCE_NAME"
