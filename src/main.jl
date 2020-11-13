using DataFrames
using CSV
using MP3
using Plots
using Unitful
using IntervalSets
using MFCC

include("model.jl")

function read_mp3(source::String, start, stop)
    println(source)
    println(start)
    println(typeof(start))
    println(stop)
    println(typeof(stop))

    println("Original Audio")
    audio = MP3.load(source)
    println(typeof(audio) )
    println(MP3.nchannels(audio))
    println(MP3.domain(audio))

    println("Audio Cut")
    audio_cut = audio[ClosedInterval(start, stop), :]
    println(typeof(audio_cut) )
    println(MP3.nchannels(audio_cut))
    println(MP3.domain(audio_cut))

    display(plot(MP3.domain(audio_cut), audio_cut.data[:, 1], size=(1200, 200)))
    raw_data = convert.(Float64, audio_cut.data[:, 1])
    println(typeof(raw_data))

    mfccs = mfcc( raw_data , MP3.samplerate(audio_cut), :rasta, steptime=0.05, wintime=0.1)
    println(typeof(mfccs))
    println(mfccs[3])
    println(size(mfccs[1]))

end

function main(data_source::String="", source_folder::String="")
    # read csv
    data = CSV.read(data_source)[[:YTID, :start_seconds, :end_seconds, :Gunshot]]
    @show head(data, 10)
    read_mp3( source_folder*data[3,:YTID]*".mp3", uconvert(u"s", data[3,:start_seconds]*@u_str("ms")), uconvert(u"s", data[3,:end_seconds]*@u_str("ms")))
end

#main("/home/void/Desktop/Code/IS/data/balanced_train_data.csv", "/home/void/Desktop/Data/SI/train_audios/")
train_model("/home/void/Desktop/Data/csv/wine_quality.csv")
