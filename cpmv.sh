#!/usr/bin/env bash

#moving directories in the same filesystem does not copy data.
#It just changes a pointer.
#Sometimes this is not desirable, you need to copy data first
#and then delete the data.
#This is useful for btrfs/zfs when you change mount options (for example compress in btrfs)
#or move data across filesystems on the same tank (zfs)

#requirements bash version 4 or higher

#usage: cpmv source_directory target_directory
#target directory must not exist


src=$(readlink -e "$1")
#echo $src
srcbasename=$(basename "$src")
srcpath=$(dirname "$src")
#echo $srcbasename
#echo $srcpath

dirs=()
while IFS= read -d $'\0' -r file ; do
  dir="${file:${#src}}"
  #echo "$dir"
  if [ "$dir" == "" ]; then
    continue
  fi
  dirs+=("$dir")
done < <(find "$src" -depth -type d -print0)

files=()
while IFS= read -d $'\0' -r file ; do
  files+=("$file")
done < <(find "$src" -type f -print0)


if [ ! -d "$2" ]; then
  $(mkdir -p "$2")

  #need a hash to store modification time of folders
  declare -A dirmodtimes
  #sore modification time of source
  rootmodtime=$(stat -c %Y "$src")
  
  for (( idx=${#dirs[@]}-1 ; idx>=0 ; idx-- )) ; do
    $(mkdir "$2${dirs[idx]}")
    #store the modification time of the directory
    dirmodtimes[${dirs[idx]}]=$(stat -c %Y "$src${dirs[idx]}")
    #echo ${dirs[idx]}
  done
  
  #for K in "${!dirmodtimes[@]}"; do echo $K --- ${dirmodtimes[$K]}; done
  
  for file in "${files[@]}"
  do
   targetfile="${file:${#src}}"
   $(cp -p "$file" "$2$targetfile")
   $(rm "$file")
  done
#restore permissions & modificaiton times of directories
  for dir in "${dirs[@]}"
  do
    $(chown --reference="$src$dir" "$2$dir")
    $(chmod --reference="$src$dir" "$2$dir")
    $(touch -m -d "@${dirmodtimes[$dir]}" "$2$dir")
    $(rmdir "$src$dir")
  done
  $(chown --reference="$src" "$2")
  $(chmod --reference="$src" "$2")
  $(touch -m -d "@$rootmodtime" "$2")
  $(rmdir "$src")
fi
