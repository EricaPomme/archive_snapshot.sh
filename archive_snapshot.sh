#!/bin/bash

MIN_SNAPSHOTS=3     # Minimum number of snapshots to keep
SPACE_THRESHOLD=75  # Clear oldest snapshots if disk usage is above this percentage

SRC='/mnt/images/.snapshots'    # Source directory
DEST='/mnt/disk5/.snapshots'    # Destination directory
SNAPSHOT_SEARCH_REGEX='^\/mnt\/images\/\.snapshots\/[0-9]{8}$'  # Regex to match snapshots in SRC. Mine are all in the format: /mnt/images/.snapshots/YYYYMMDD

for i in $(find $SRC -regextype posix-extended -regex $SNAPSHOT_SEARCH_REGEX); do    
    while [ $(df -h $DEST | tail -n 1 | awk '{print $5}' | sed 's/%//') -gt $SPACE_THRESHOLD ]; do
        if [ $(ls $DEST | wc -l) -gt $MIN_SNAPSHOTS ]; then
            $oldest=$DEST+'/'+$(ls -t $DEST | tail -n 1)
            btrfs subvolume delete $oldest
        else 
            echo "Not enough snapshots to clear. Cannot delete $i. Unable to archive further snapshots."
            exit 1
        fi
    done
    btrfs send $i | btrfs receive $DEST && btrfs subvolume delete $i
done
