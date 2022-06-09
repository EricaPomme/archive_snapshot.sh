# archive_snapshot.sh
A less convoluted approach to archiving btrfs snapshots. 

My attempt at this in Python (https://github.com/EricaPomme/archive_snapshot) worked out to be a bit less elegant than I'd have liked. This is a simpler version in bash.

Settings are done in variables at the top of the script:

* MIN_SNAPSHOTS: The minimum number of snapshots to keep. If we're past the disk usage threshold and you're at or below this number, *no archiving will happen*.
* SPACE_THRESHOLD: If disk usage on the destination is above this percentage, attempt to clear the oldest snapshots until we have enough room.
* SRC: Snapshot source
* DEST: Destination
* SNAPSHOT_SEARCH_REGEX: We use 'find' to get the paths for our snapshots to send. This regex should match your snapshots as directly as possible.

---

I use this in a cron job to backup my VMs on my Unraid server.

```
# Daily snapshot of VM images at 2am
0 2 * * * btrfs subvolume snapshot -r /mnt/images/domains /mnt/images/.snapshots/`date +%Y%m%d` && bash /boot/custom/archive_snapshot.sh
```
