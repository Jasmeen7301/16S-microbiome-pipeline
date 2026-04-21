#!/bin/bash
# ============================================================
# filter_and_export.sh
# Extract feature table from QIIME2, filter, convert to HDF5,
# add taxonomy metadata, summarise, and export to TSV for R
#
# Usage: bash filter_and_export.sh
# Requires: QIIME2 env, old QIIME env, and myenv activated as needed
# ============================================================

# ── Step 1: Extract feature table from QIIME2 artifact ───────────────────────
cd dada2/
unzip table.qza
cd ..

BIOM_FILE=$(find dada2/ -name "feature-table.biom" | head -1)
echo "Feature table: $BIOM_FILE"

# ── Step 2: Activate myenv and filter low-abundance observations ──────────────
# Removes observations present at < 0.001 fraction in all samples
cd 16S/
source bin/activate

python scripts/filter_observations_by_sample.py \
  -i "$BIOM_FILE" \
  -o filtered_table.biom \
  -f -n 0.001

deactivate

# ── Step 3: Switch to old QIIME and convert to HDF5 ──────────────────────────
source activate /path/to/old_qiime
source bin/activate   # reactivate myenv

biom convert \
  -i filtered_table.biom \
  -o filtered_table_hd5.biom \
  --table-type="OTU table" \
  --to-hdf5

# ── Step 4: Remove singleton OTUs ────────────────────────────────────────────
python scripts/filter_otus_from_otu_table.py \
  -i filtered_table_hd5.biom \
  -o filtered_table_hd5_final.biom \
  -s 1

deactivate

# ── Step 5: Extract representative sequences and taxonomy ─────────────────────
cd dada2/
unzip representative_sequences.qza
cd ..

cd feature_taxonomy/
unzip classification.qza
cd ..

TAXONOMY=$(find feature_taxonomy/ -name "taxonomy.tsv" | head -1)
echo "Taxonomy file: $TAXONOMY"

# ── Step 6: Add taxonomy to biom table ───────────────────────────────────────
source bin/activate

biom add-metadata \
  -i filtered_table_hd5_final.biom \
  -o filtered_table_hd5_final_w_tax.biom \
  --observation-metadata-fp "$TAXONOMY" \
  --sc-separated taxonomy \
  --observation-header OTUID,taxonomy

# ── Step 7: Summarise taxonomy at levels L2–L7 ───────────────────────────────
summarize_taxa.py \
  -i filtered_table_hd5_final_w_tax.biom \
  -L 2,3,4,5,6,7 \
  -o summarize_taxonomy/

# ── Step 8: Export final table to TSV for R ───────────────────────────────────
biom convert \
  -i filtered_table_hd5_final_w_tax.biom \
  -o filtered_table_final.txt \
  --to-tsv \
  --table-type="OTU table" \
  --header-key taxonomy

deactivate

echo "Done. Outputs:"
echo "  filtered_table_final.txt  — open in Excel, remove reads < 200, save as TSV"
echo "  summarize_taxonomy/       — taxonomy summaries L2-L7"
echo ""
echo "Next: run r_scripts/new_filtering_method_16S_byASV_QY.R"
