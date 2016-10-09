Moving directories in the same filesystem does not copy data.
It just changes a pointer.
Sometimes this is not desirable, you need to copy data first
and then delete the data.
This is useful for btrfs/zfs when you change mount options (for example compress in btrfs)
or move data across filesystems on the same tank (zfs)

requirements: bash version 4 or higher, stat

usage: cpmv source_directory target_directory

target directory must not exist!
