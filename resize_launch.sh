#!/bin/bash

image_file="iOpenSongs-Launch.png"
output_folder="./Resources"

width=( 768 1024 320 320 ) # sizes for iOS 7
height=( 1024 768 480 568 ) # sizes for iOS 7
modifier=( "-Portrait" "-Landscape" "" "-568h" )


for (( i=0; i < ${#width[@]}; ++i )); do
	w=${width[i]}
	h=${height[i]}
	m=${modifier[i]}
	# for 2x resolution
	w2=$(( $w * 2 ))
	h2=$(( $h * 2 ))

	printf "%sx%s\n" "${w}" "${h}"
	gm convert -size "$w"x"$h"   -resize "$w"x"$h"   -gravity center -extent "$w"x"$h"   $image_file "$output_folder/Default$m.png"
	gm convert -size "$w2"x"$h2" -resize "$w2"x"$h2" -gravity center -extent "$w2"x"$h2" $image_file "$output_folder/Default$m@2x.png"
done

echo DONE

