import numpy as np
import pandas as pd
import youtube_dl
import os
from tabulate import tabulate
import sys

def as_str(df): return str(tabulate(df, headers='keys', tablefmt='fancy_grid'))

# function to extract audio from a youtube url
def extract_audio(yt_ids):
	# options of extraction
	options = {
		'format': 'bestaudio/best',
		'extractaudio' : True,
		'audioformat' : "mp3",
		'outtmpl': '%(id)s',
		'noplaylist' : True,
	}
	downloaded_ids = []
	failed_ids = []
	total_ids = len(yt_ids)
	progress = 0
	# for each id
	for yt_id in yt_ids:
		# get full url
		url = 'http://www.youtube.com/watch?v=' + yt_id
		# open video and download it
		with youtube_dl.YoutubeDL(options) as ydl:
			try:
				ydl.download([url,])
			except:
				failed_ids.append(yt_id)
				print("[youtube] Could not download file (skipped)")
			else:
				downloaded_ids.append(yt_id)
			finally:
				progress += 1
				print("[status] " + str(progress*100.0/total_ids) + "%" + " completed")
	
	print("[downloader] audios downloaded")
	return downloaded_ids, failed_ids

def main(file="balanced_train.csv", output_folder="train_audios", output_file="balanced_train_data.csv", samples=-1):
	# read labels
	labels = pd.read_csv("class_labels_indices.csv", sep=',', header=0, index_col=0).set_index("mid")
	# read data
	data = pd.read_csv("balanced_train.csv", sep=";", header=0)
	# get samples if needed
	if int(samples) > 0: data = data.head(int(samples))
	# add labels and gunshot columns
	data["labels"] = data["positive_labels"].apply(lambda label: ";".join( [labels.loc[l][0] for l in label.split(',') ] ))
	data["Gunshot"] = data["labels"].apply(lambda label: "Gunshot, gunfire" in label.split(";") )
	
	# exctract audio
	os.chdir('train_audios')
	downloaded, failed = extract_audio(data["YTID"].values)
	os.chdir('..')
	# get only downloaded data 
	data = data[ data["YTID"].isin(downloaded) ]
	# save final dataset
	data.to_csv(output_file, sep=";", index=False)


if __name__ == "__main__":
	args = {}
	for arg in sys.argv[1:]:
		key, *values = arg[2:].split("=")
		args[key] = "=".join(values)
	main(**args)