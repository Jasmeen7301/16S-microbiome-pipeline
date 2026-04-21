#!/bin/bash

# Define directories
TARGET_DIR="/path/to/raw_reads"
OUTPUT_DIR="/path/to/cutadapt_trimmed_index" # Directory to save trimmed files
LOG_FILE="cutadapt_processing.log"

# Ensure log file exist
> "$LOG_FILE"  # Clear the log file before starting

# Loop through all R1 files in the target directory
for R1_file in "$TARGET_DIR"/*_R1_001.fastq.gz; do
  # Extract the base name (without path and R1 extension)
  base=$(basename "$R1_file" _R1_001.fastq.gz)

  # Identify the corresponding R2 file
  R2_file="$TARGET_DIR/${base}_R2_001.fastq.gz"

  # Check if the R2 file exists
  if [[ ! -f "$R2_file" ]]; then
    echo "Warning: R2 file not found for $R1_file" >> "$LOG_FILE"
    continue
  fi

  # Define output file paths
  trimmed_R1="$OUTPUT_DIR/${base}_R1_001.fastq.gz"
  trimmed_R2="$OUTPUT_DIR/${base}_R2_001.fastq.gz"

  # Run cutadapt for both R1 and R2 files
  echo "Processing sample: $base" | tee -a "$LOG_FILE"
  cutadapt -u 6 -o "$trimmed_R1" "$R1_file" >> "$LOG_FILE" 2>&1
  cutadapt -u 6 -o "$trimmed_R2" "$R2_file" >> "$LOG_FILE" 2>&1

  # Check if the output files were created successfully
  if [[ -f "$trimmed_R1" && -f "$trimmed_R2" ]]; then
    echo "Successfully processed: $base" >> "$LOG_FILE"
  else
    echo "Error processing: $base. Check logs." >> "$LOG_FILE"
  fi
done

# Final status message
echo "Cutadapt processing completed for all samples!" | tee -a "$LOG_FILE"
