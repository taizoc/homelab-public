#!/bin/bash

# generated with gemma4

# --- Configuration Placeholders ---
INPUT_DIR="/path/to/input/audio_files" 
OUTPUT_DIR="/path/to/output/mp3_files" 
AGE_THRESHOLD="+5" # Files older than 5 minutes (in minutes)

echo "Starting audio processing job at $(date)"

# 1. Check if the input directory exists
if [ ! -d "$INPUT_DIR" ]; then
    echo "Error: Input directory '$INPUT_DIR' does not exist."
    exit 1
fi

# 2. Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# 3. Find files in INPUT_DIR older than AGE_THRESHOLD minutes and process them
find "$INPUT_DIR" -type f -mmin -$AGE_THRESHOLD -print0 | while IFS= read -r -d $'\0' FILE; do
    echo "Processing file: $FILE"

    # Extract the filename without path for naming consistency
    FILENAME=$(basename -- "$FILE")
    
    # Create the output MP3 filename (e.g., original_name.mp3)
    OUTPUT_FILE="${OUTPUT_DIR}/${FILENAME%.*}.mp3"

    echo "Converting to MP3: $OUTPUT_FILE"

    # Use ffmpeg to convert the file. 
    # -i "$FILE": input file
    # -vn: no video stream (ensures only audio is processed)
    # -acodec libmp3lame: specifies the encoder for MP3
    # -q:a 2: sets a good quality level for VBR encoding
    ffmpeg -i "$FILE" -vn -acodec libmp3lame -q:a 2 "$OUTPUT_FILE"

    if [ $? -eq 0 ]; then
        echo "Successfully converted and saved to $OUTPUT_FILE."
        # Optional: Move or delete the original file after successful processing.
        # If you want to keep the originals, comment out the next line.
        mv "$FILE" "${INPUT_DIR}/processed/${FILENAME}" 2>/dev/null || echo "Warning: Could not move $FILE. Check permissions."
    else
        echo "Error converting $FILE using ffmpeg. Check logs for details."
    fi

done

echo "Audio processing job finished at $(date)"