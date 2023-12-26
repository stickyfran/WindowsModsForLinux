#!/bin/sh

# Default variables - ffmpeg_qv Lossless as default is 22 on HEVC
paths=paths.txt
ffmpeg_qv=22

ffmpeg_function() {
    for file in $(find . -type f \( -name "*.mp4" -o -name "*.avi" -o -name "*.mov" -o -name "*.wmv" -o -name "*.ts" -o -name "*.m2ts" -o -name "*.mkv" -o -name "*.mts" \)); do
        echo "Processing $file"
        ffmpeg -hwaccel auto -i "$file" -pix_fmt p010le -map 0:v -map 0:a -map_metadata 0 -c:v hevc_nvenc -rc constqp -qp $ffmpeg_qv -b:v 0K -c:a aac -b:a 384k -movflags +faststart -movflags use_metadata_tags "${file%.*}_CRF${ffmpeg_qv}_HEVC.mp4"
        # "-pix_fmt p010le" is setting it to 10-bit instead of 420 8-bit, which is what I had before
        # "-map_metadata 0" copies all metadata from the source file
        # "-movflags +faststart" helps with audio streaming
        echo "Processed $file"
    done
}

# Test if the paths file exists and iterate through it
if [ -e "$paths" ]; then
    while IFS= read -r path; do
        echo "Changing to directory $path"
        cd "$path" || exit 1
        ffmpeg_function
        cd - || exit 1
    done < "$paths"
else
    # It doesn't exist
    ffmpeg_function
fi
