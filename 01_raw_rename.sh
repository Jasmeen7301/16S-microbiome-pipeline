#!/bin/bash

# Define source and target directories
SOURCE_DIR="/mnt/galaxy/home/qazih/16S/Mar_2026/result_X201SC26024678-Z01-F001/01.RawData"
TARGET_DIR="/mnt/galaxy/home/qazih/16S/Mar_2026/raw_reads"

# Find all files ending with .raw_1.fastq.gz in subdirectories
find "$SOURCE_DIR" -type f -name "*.raw_1.fastq.gz" | while read -r file; do
  # Extract base name without extension
  base=$(basename "$file" .raw_1.fastq.gz)

  # Locate the corresponding R2 file
  file_R2=$(echo "$file" | sed 's/.raw_1.fastq.gz/.raw_2.fastq.gz/')

  # Define new file names for R1 and R2
  new_name_R1="${base}_AAAAAAAA-AAAAAAAA_L001_R1_001.fastq.gz"
  new_name_R2="${base}_AAAAAAAA-AAAAAAAA_L001_R2_001.fastq.gz"

  # Copy and rename the R1 file to the target directory
  cp "$file" "$TARGET_DIR/$new_name_R1"

  # Check if the R2 file exists, then copy and rename it
  if [[ -f "$file_R2" ]]; then
    cp "$file_R2" "$TARGET_DIR/$new_name_R2"
  else
    echo "Warning: R2 file not found for $file"
  fi
done
