#!/bin/bash

# This script will loop over all the PNG files in the current folder and  use Imagemagick "convert" :

#   - convert .svg to a various .png
#   - autocrop / trim
#   - resize, remove semi transparent >95%
#   - resize to defined values
#   - add a margin around the image
#   - append horizontally
#   - add drop shadow

# INSTALL to use this script
##   sudo apt-get install imagemagick
# Run with
##	./make_freeship_menu_icon_sprite ./theme-folder

# This script should be placed in the ./themes folder. We expect folder structure like:

##	./themes/midnight-blue/Icons/svg     (the originals)
## 	./themes/midnight-blue/Icons/16		(folder this script creates and fills)
## 	./themes/midnight-blue/Icons/24

# Then, for example, if you want to convert all svg files in folder /themes/midnight-blue/Icons/svg, you can cd to /themes and run:

##     ./make_freeship_menu_icon_sprite ./midnight-blue



# ********************

# We will process the current folder each image in alphabetical order:  trim, then resize and then add uniform border

echo
echo "********  Create png from each svg in various sizes and coppying it to folder..."

cd ${1}/Icons

for RES in 16 24 32 48 64 128
do
	COUNTER=0
	
	for filename in `ls ./svg/*.svg | sort -V`; 
	do
	 	fullimage="${filename%.*}"
	 	image=$(basename $fullimage)
		echo "$COUNTER Converting $image to ${RES}x${RES}..."
		mkdir -p ./${RES}
		convert -density 1200 -trim -resize ${RES}x${RES} -gravity center -background transparent  -channel A -threshold 95% -extent ${RES}x${RES}  ./svg/$image.svg PNG32:./${RES}/$image.png
		# echo "Apply drop shadow"
		# convert icon_set_hor.png  \( +clone -background black -shadow 50x4+1+1 -channel A -level 0,50% +channel \) -compose DstOver -gravity center -composite icon_sprite_set_uc.png


		COUNTER=$((COUNTER+1))

	done
	
	echo "Creating horizontal ${RES} sprite..."
	# remove old sprite to avoid appending forever
	rm -f ./${RES}/icon-sprite-${RES}.png
	# make new sprite
	convert +append ./${RES}/*.png PNG32:./${RES}/icon-sprite-${RES}.png
	# echo "Compressing final icon"
	# convert -quality 0 +dither ./${RES}/icon-sprite-${RES}.png PNG32:./${RES}/icon-sprite-${RES}.png

done

echo "Creating preview image with dark background"
# +repage needed to keep image same size
convert -background "#444444" -flatten +repage -border 10x10 -bordercolor "#444444" ./24/icon-sprite-24.png preview/sprite_preview_dark.png

echo "Creating preview image with white background"
convert -background "#ffffff" -flatten +repage -border 10x10 -bordercolor "#ffffff" ./24/icon-sprite-24.png preview/sprite_preview_white.png

echo "Ready, $COUNTER .png images converted. "


