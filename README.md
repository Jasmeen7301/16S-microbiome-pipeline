# 16S rRNA Microbiome Pipeline — Insect Vector Genomics

> Research Assistant(Casual) | Hoffmann Lab, Bio21 Institute, University of Melbourne | Spartan HPC

End-to-end 16S rRNA amplicon sequencing pipeline for profiling microbial communities in field-collected insects and mosquito populations. Applied to study endosymbiotic bacteria's of agricultural pests (*Diadegma*, *Trichogramma*, aphids, moths) and mosquito samples.

---

## Repository Structure

```
16S-microbiome-pipeline/
├── README.md
├── scripts/
│   ├── raw_rename.sh                      # Rename raw reads to QIIME2 format
│   ├── cutadapt.sh                        # Trim index bases (first 6 bp), with logging
│   ├── qiime2_pipeline.sh                 # Import → primer trim → DADA2 → classify
│   ├── filter_and_export.sh               # Filter, convert to HDF5, add taxonomy, export TSV
│   ├── filter_observations_by_sample.py   # Filter low-abundance observations (0.001 threshold)
│   └── filter_otus_from_otu_table.py      # Remove singleton OTUs
└── r_scripts/
    ├── new_filtering_method_16S_byASV_QY.R  # 2% ASV abundance filtering
    └── barplots.R                            # Taxonomy composition barplots
```

---

## Pipeline Overview

```
Raw reads (Novogene paired-end)
        │
        ▼
[01] Rename files              raw_rename.sh
        │                      sequencing format → QIIME2 CasavaOneEight format
        ▼
[02] Trim index bases          cutadapt.sh
        │                      Remove first 6 bp from R1 and R2
        ▼
[03] Import to QIIME2          qiime2_pipeline.sh (Step 1)
        │                      qiime tools import
        ▼
[04] Trim primers              qiime2_pipeline.sh (Step 2)
        │                      V3-V4: CCTAYGGGRBGCASCAG / GGACTACNNGGGTATCTAAT
        ▼
[05] DADA2 denoising           qiime2_pipeline.sh (Step 3)
        │                      trunc-len-f , trunc-len-r based on denoising.qzv file
        ▼
[06] Taxonomic classification  qiime2_pipeline.sh (Step 4)
        │                      SILVA 138 V3-V4 classifier
        ▼
[07] Extract & filter          filter_and_export.sh
        │                      biom → filter_observations (0.001) → HDF5 → remove singletons
        ▼
[08] Add taxonomy & export     filter_and_export.sh
        │                      biom add-metadata → summarize_taxa (L2-L7) → TSV
        ▼
[09] Excel filtering           Manual step
        │                      Remove reads < 200, save as tab-delimited TSV
        ▼
[10] ASV filtering             r_scripts/new_filtering_method_16S_byASV_QY.R
        │                      Remove ASVs below 2% abundance threshold
        ▼
[11] Barplots                  r_scripts/barplots.R
                               Taxonomy composition barplots with custom colour palette
```

---

## Scripts

### `scripts/raw_rename.sh` — Rename raw reads

Renames raw reads from `.raw_1.fastq.gz` format to QIIME2-compatible `CasavaOneEight` format.

```bash
# Update SOURCE_DIR and TARGET_DIR in the script, then run:
bash scripts/raw_rename.sh
```

---

### `scripts/cutadapt.sh` — Trim index bases

Trims the first 6 bases (index sequence) from all R1 and R2 reads. Generates a log file with per-sample processing details.

```bash
# Update TARGET_DIR and OUTPUT_DIR in the script, then run:
bash scripts/cutadapt.sh
```

---

### `scripts/qiime2_pipeline.sh` — Main QIIME2 pipeline

Runs the full QIIME2 pipeline: import → primer trimming → DADA2 denoising → taxonomic classification.

```bash
# Activate QIIME2 environment first
source activate /path/to/qiime2
export TMPDIR='/path/to/tmp'

# Update paths in the script, then run:
bash scripts/qiime2_pipeline.sh
```

Key parameters:
- Primers: V3-V4 (`CCTAYGGGRBGCASCAG` / `GGACTACNNGGGTATCTAAT`)
- DADA2 truncation: based on denoising.qzv from dada2 step
- Classifier: SILVA 138 SSU NR99 V3-V4

---

### `scripts/filter_and_export.sh` — Filter and export

Extracts the feature table from QIIME2, applies abundance filtering, converts to HDF5, adds taxonomy metadata, summarises at all taxonomic levels, and exports to TSV for R analysis.

```bash
bash scripts/filter_and_export.sh
```

Filtering steps applied:
1. Remove observations at < 0.001 fraction across all samples (`filter_observations_by_sample.py`)
2. Remove singleton OTUs — present in only 1 sample (`filter_otus_from_otu_table.py`)

---

### `scripts/filter_observations_by_sample.py`

Filters low-abundance OTUs from a BIOM table based on a minimum abundance threshold.

```bash
python scripts/filter_observations_by_sample.py \
  -i input.biom \
  -o filtered.biom \
  -f -n 0.001
```

*Credit: Adam Robbins-Pianka (BSD licence)*

---

### `scripts/filter_otus_from_otu_table.py`

Filters OTUs from a BIOM table based on observation counts, sample presence, or an exclusion list. Used here to remove singletons (`-s 1`).

```bash
python scripts/filter_otus_from_otu_table.py \
  -i filtered_table_hd5.biom \
  -o filtered_table_hd5_final.biom \
  -s 1
```

*Credit: Greg Caporaso, QIIME project (GPL licence)*

---
### remove any reads less than 200bp in each sample then use r script given in the next step
### `r_scripts/new_filtering_method_16S_byASV_QY.R` — ASV filtering

Removes ASVs below the 2% relative abundance threshold. Run after exporting and manually filtering the TSV in Excel.

```r
Rscript r_scripts/new_filtering_method_16S_byASV_QY.R
```

---

### `r_scripts/barplots.R` — Taxonomy barplots

Generates stacked relative abundance barplots with a custom colour palette tailored for insect endosymbiont communities. Colours can be assigned to specific endosymbiont genera (Buchnera, Spiroplasma, Hamiltonella, Wolbachia, etc.).

```r
Rscript r_scripts/barplots.R
```

---

## Environment Setup

This pipeline uses two separate environments:

**QIIME2** (Steps 3–6):
```bash
source activate /path/to/qiime2
export TMPDIR='/path/to/tmp'
```

**Old QIIME + myenv** (Steps 7–8, biom conversion):
```bash
source activate /path/to/old_qiime
cd 16S/ && source bin/activate   # myenv
```

**R** (Steps 10–11):
```r
install.packages(c("dplyr", "ggplot2", "scales", "tidyr", "readr"))
```

---

## Key Tools

| Tool | Purpose |
|---|---|
| QIIME2 | Core 16S analysis framework |
| cutadapt | Index and adapter trimming |
| DADA2 | Amplicon denoising and ASV calling |
| SILVA 138 | Taxonomic reference database (V3-V4) |
| biom-format | Feature table manipulation |
| Python | Filtering scripts |
| R (ggplot2, dplyr) | Downstream analysis and visualisation |
| Spartan HPC | University of Melbourne HPC cluster |
d…]()
