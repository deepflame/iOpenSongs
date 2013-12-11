#!/bin/bash

image_file="iOpenSongs.png"
output_folder="./Resources"
resolutions=( 29 40 60 76 ) # sizes for iOS 7

for i in "${resolutions[@]}"
do
  echo $i
  j=$(( $i * 2 )) # for 2x resolution
  gm convert -size $ix$i $image_file -resize $ix$i "$output_folder/Icon-$i.png"
  gm convert -size $jx$j $image_file -resize $ix$i "$output_folder/Icon-$i@2x.png"
done

echo iTunesArtwork
gm  convert -size 512x512 $image_file -resize 512x512 "$output_folder/iTunesArtwork"
gm  convert -size 1024x1024 $image_file -resize 1024x1024 "$output_folder/iTunesArtwork@2x"

echo DONE
