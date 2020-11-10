#!/bin/bash
clear
# setup initial dir
rm -rf train_audios 
mkdir train_audios
# run python script to download youtube videos
python main.py --file=balanced_train.csv --output_file=balanced_train_data.csv --samples=500
# for each file 
for filename in ./train_audios/*
do
	echo "[ffmpeg] extracting ${filename:15}"
	# extract audio
    ffmpeg -i "$filename" "$filename.mp3"
    # remove orifinal video 
    rm "$filename"
done

echo "[ffmpeg] audios extracted"