#!/bin/bash

MIN_SNAPSHOTS=3     # Minimum number of snapshots to keep
SPACE_THRESHOLD=90  # Clear oldest snapshots if disk usage is above this percentage

SRC='/mnt/images/.snapshots'    # Source directory
DEST='/mnt/disk8/.snapshots'    # Destination directory
SNAPSHOT_SEARCH_REGEX='^\/mnt\/images\/\.snapshots\/[0-9]{8}$'  # Regex to match snapshots in SRC. Mine are all in the format: /mnt/images/.snapshots/YYYYMMDD

for i in $(find $SRC -regextype posix-extended -regex $SNAPSHOT_SEARCH_REGEX); do
    #Clearing based on snapshot size currently doesn't work because btrfs subvolume delete removes the handle for the snapshot before freeing the space, so it thinks the disk is still full. This leads to all snapshots up to the limit being killed off. Oops.
    #while [ $(df $DEST | tail -n 1 | awk '{print $4}') -lt $(du -s $SRC | awk '{print $1}') ]; do
    while [ $(df -h $DEST | tail -n 1 | awk '{print $5}' | sed 's/%//') -gt $SPACE_THRESHOLD ]; do
        if [ $(ls $DEST | wc -l) -gt $MIN_SNAPSHOTS ]; then
            btrfs subvolume delete "$DEST/$(ls -t $DEST | tail -n 1)"
        else 
            echo "Not enough snapshots to clear. Cannot delete $i. Unable to archive further snapshots."
            exit 1
        fi
    done
    btrfs send $i | btrfs receive $DEST && btrfs subvolume delete $i
done
