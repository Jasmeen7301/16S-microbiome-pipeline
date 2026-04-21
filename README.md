# 16S rRNA Microbiome Pipeline — Insect Vector Genomics

> Research Assistant(Casual) | Hoffmann Lab, Bio21 Institute, University of Melbourne | Spartan HPC

End-to-end 16S rRNA amplicon sequencing pipeline for profiling microbial communities in field-collected insects and mosquito populations. Applied to study endosymbiotic bacteria's of agricultural pests (*Diadegma*, *Trichogramma*, aphids, moths) and mosquito samples.

---

## Repository Structure

```
16S-microbiome-pipeline/
├── README.md
├── scripts/
│   ├── 01_raw_rename.sh                      # Step 1 — Rename Novogene raw reads to QIIME2 format
│   ├── 02_cutadapt.sh                        # Step 2 — Trim index bases (first 6 bp), with logging
│   ├── 03_qiime2_pipeline.sh                 # Step 3 — Import → primer trim → DADA2 → classify
│   ├── 04_filter_and_export.sh               # Step 4 — Filter, convert to HDF5, add taxonomy, export TSV
│   ├── 04a_filter_observations_by_sample.py  # Step 4a — Filter low-abundance observations (0.001)
│   └── 04b_filter_otus_from_otu_table.py     # Step 4b — Remove singleton OTUs
└── r_scripts/
    ├── 05_new_filtering_method_16S_byASV_QY.R  # Step 5 — 2% ASV abundance filtering
    └── 06_barplots.R                            # Step 6 — Taxonomy composition barplots
```

---

## Pipeline Overview

```
Raw reads (paired-end)
        │
        ▼
[01] 01_raw_rename.sh
        │   Rename .raw_1.fastq.gz → QIIME2 CasavaOneEight format
        ▼
[02] 02_cutadapt.sh
        │   Trim first 6 bp (index bases) from R1 and R2
        ▼
[03] 03_qiime2_pipeline.sh
        │   ├── qiime tools import
        │   ├── qiime cutadapt trim-paired  (V3-V4 primers)
        │   ├── qiime dada2 denoise-paired  (trunc-len-f, trunc-len-r based on denoising.qzv from dada2 step)
        │   └── qiime feature-classifier classify-sklearn  (SILVA 138)
        ▼
[04] 04_filter_and_export.sh
        │   ├── 04a_filter_observations_by_sample.py  (remove < 0.001 fraction)
        │   ├── biom convert → HDF5
        │   ├── 04b_filter_otus_from_otu_table.py     (remove singletons)
        │   ├── biom add-metadata + summarize_taxa (L2-L7)
        │   └── biom convert → TSV
        ▼
        [Manual step: open TSV in Excel, remove reads < 200, save as TSV]
        ▼
[05] 05_new_filtering_method_16S_byASV_QY.R
        │   Remove ASVs below 2% relative abundance threshold
        ▼
[06] 06_barplots.R
            Stacked taxonomy barplots with endosymbiont colour palette
```

---

## Step-by-Step Usage

### Step 01 — Rename raw reads
```bash
# Update SOURCE_DIR and TARGET_DIR in the script, then run:
bash scripts/01_raw_rename.sh
```
Renames Novogene `.raw_1.fastq.gz` files to QIIME2-compatible `CasavaOneEight` format.

---

### Step 02 — Trim index bases
```bash
# Update TARGET_DIR and OUTPUT_DIR in the script, then run:
bash scripts/02_cutadapt.sh
```
Removes the first 6 bp from all R1 and R2 reads. Writes a log file with per-sample processing details.

---

### Step 03 — QIIME2 pipeline
```bash
# Activate QIIME2 and set temp directory first
source activate /path/to/qiime2
export TMPDIR='/path/to/tmp'

# Update paths in the script, then run:
bash scripts/03_qiime2_pipeline.sh
```
Runs the full QIIME2 pipeline: import → V3-V4 primer trimming → DADA2 denoising → SILVA 138 taxonomic classification.

---

### Step 04 — Filter and export
```bash
bash scripts/04_filter_and_export.sh
```
Calls `04a` and `04b` internally. Extracts the feature table, filters low-abundance observations, removes singletons, adds taxonomy metadata, summarises at levels L2–L7, and exports to TSV.

**04a** — filter observations below 0.001 fraction:
```bash
python scripts/04a_filter_observations_by_sample.py \
  -i input.biom -o filtered.biom -f -n 0.001
```

**04b** — remove singleton OTUs:
```bash
python scripts/04b_filter_otus_from_otu_table.py \
  -i filtered_hd5.biom -o filtered_final.biom -s 1
```

> **Manual step after Step 04:** Open `filtered_table_final.txt` in Excel, remove rows with fewer than 200 reads, and save as tab-delimited `.txt` before running Step 05.

---

### Step 05 — ASV filtering
```r
Rscript r_scripts/05_new_filtering_method_16S_byASV_QY.R
```
Removes ASVs below 2% relative abundance threshold across all samples.

---

### Step 06 — Barplots
```r
Rscript r_scripts/06_barplots.R
```
Generates stacked relative abundance barplots with a custom colour palette for insect endosymbiont communities (Buchnera, Spiroplasma, Hamiltonella, Wolbachia, etc.).

---

## Environment Setup

**QIIME2** (Steps 3–4):
```bash
source activate /path/to/qiime2
export TMPDIR='/path/to/tmp'
```

**Old QIIME + myenv** (biom conversion in Step 4):
```bash
source activate /path/to/old_qiime
cd 16S/ && source bin/activate
```

**R packages** (Steps 5–6):
```r
install.packages(c("dplyr", "ggplot2", "scales", "tidyr", "readr"))
```

---

## Key Tools

| Tool | Version | Purpose |
|---|---|---|
| QIIME2 | latest | Core 16S analysis framework |
| cutadapt | latest | Index and adapter trimming |
| DADA2 | latest | Amplicon denoising and ASV calling |
| SILVA 138 | SSU NR99 V3-V4 | Taxonomic reference database |
| biom-format | latest | Feature table manipulation |
| Python | 3.x | Filtering scripts |
| R (ggplot2, dplyr) | latest | Downstream analysis and visualisation |
| Spartan HPC | — | University of Melbourne HPC cluster |
