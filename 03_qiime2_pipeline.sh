#!/bin/bash
# ============================================================
# qiime2_pipeline.sh
# Full QIIME2 16S rRNA pipeline: import → primer trim → DADA2 → classify
#
# Usage: bash qiime2_pipeline.sh
# Must activate QIIME2 environment and set TMPDIR before running
# ============================================================

# ── Environment setup ─────────────────────────────────────────────────────────
source activate /path/to/qiime2
export TMPDIR='/path/to/tmp'

# ── Paths — update these for your run ────────────────────────────────────────
TRIMMED_DIR="cutadapt_trimmed_index"
METADATA="sample_metadata.txt"
CLASSIFIER="/path/to/silva-138-ssu-nr99-seqs-V3V4-classifier.qza"

# ── Step 1: Import sequences ──────────────────────────────────────────────────
mkdir -p qiime2_import

qiime tools import \
  --type 'SampleData[PairedEndSequencesWithQuality]' \
  --input-path "$TRIMMED_DIR" \
  --input-format CasavaOneEightSingleLanePerSampleDirFmt \
  --output-path qiime2_import/sequences.qza

# ── Step 2: Trim primers ──────────────────────────────────────────────────────
# V3-V4 primers
mkdir -p cutadapt_trimmed_primers

qiime cutadapt trim-paired \
  --i-demultiplexed-sequences qiime2_import/sequences.qza \
  --p-front-f CCTAYGGGRBGCASCAG \
  --p-front-r GGACTACNNGGGTATCTAAT \
  --o-trimmed-sequences cutadapt_trimmed_primers/trimmed.qza \
  --verbose

qiime demux summarize \
  --i-data cutadapt_trimmed_primers/trimmed.qza \
  --output-dir cutadapt_trimmed_primers/summarize

# ── Step 3: DADA2 denoising ───────────────────────────────────────────────────
mkdir -p dada2

qiime dada2 denoise-paired \
  --i-demultiplexed-seqs cutadapt_trimmed_primers/trimmed.qza \
  --p-trunc-len-f 228 \
  --p-trunc-len-r 222 \
  --output-dir dada2 \
  --verbose

# Visualisations
qiime metadata tabulate \
  --m-input-file dada2/denoising_stats.qza \
  --o-visualization dada2/denoising_stats.qzv

qiime feature-table summarize \
  --i-table dada2/table.qza \
  --o-visualization dada2/table.qzv \
  --m-sample-metadata-file "$METADATA"

qiime feature-table tabulate-seqs \
  --i-data dada2/representative_sequences.qza \
  --o-visualization dada2/representative_sequences.qzv

# ── Step 4: Taxonomic classification (SILVA 138) ──────────────────────────────
mkdir -p feature_taxonomy

qiime feature-classifier classify-sklearn \
  --i-classifier "$CLASSIFIER" \
  --i-reads dada2/representative_sequences.qza \
  --output-dir feature_taxonomy

qiime metadata tabulate \
  --m-input-file feature_taxonomy/classification.qza \
  --o-visualization feature_taxonomy/classification.qzv

qiime taxa barplot \
  --i-table dada2/table.qza \
  --i-taxonomy feature_taxonomy/classification.qza \
  --m-metadata-file "$METADATA" \
  --o-visualization barplots.qzv

echo "QIIME2 pipeline complete."
