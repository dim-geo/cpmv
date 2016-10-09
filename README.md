#cpmv

Moving directories in the same filesystem does not copy data.
It just changes a pointer.
Sometimes this is not desirable. You may need to copy data first and then delete destination, but by using 'cp & rm -rf' you double temporarily free space requirements. cpmv performs that by operating on a per file basis, instead of copying the whole structure in advance.
This is useful for btrfs/zfs when you change mount options (for example compress in btrfs)
or move data across filesystems on the same tank (zfs)

requirements: bash version 4 or higher, stat

usage: cpmv source_directory target_directory

target directory must not exist!
Permissions & modification times are preserved for directories & files.
