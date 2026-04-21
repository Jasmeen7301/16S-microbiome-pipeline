# specify path to input file
in_fp = "D:/16S Data/For Jasmeen/Novogene_June24/Result_X201SC23122974-Z01-F002_16SV34/June_24_GPA/filtered_table_hd5_final_w_tax_200_0.01.txt"

# specify path to output file
out_fp <- "D:/16S Data/For Jasmeen/Novogene_June24/Result_X201SC23122974-Z01-F002_16SV34/June_24_GPA/filtered_table_hd5_final_w_tax_200_0.01_0.02.txt"

# specify the by-ASV filtration level (e.g. 3% = 0.03)
asvFL <- 0.02

# load the ASV table, skipping the first row which starts with #
asv_table <- read.csv(file = in_fp, sep = "\t", skip = 1)

# make a copy
asv_table_F1 <- asv_table

# filter by ASV abundance
# convert counts to zero if (sample ASV count)/(total ASV count across all samples) is >= ASV filtration threshold
# our input is a vector, must use ifelse instead of if, as ifelse = vectorised, if = not vectorised) 
asv_table_F1[2:(ncol(asv_table_F1)-1)] <- t(apply(asv_table_F1[2:(ncol(asv_table_F1)-1)], 1, function(x) {ifelse(x/sum(x) >= asvFL, x, 0)}))

# remove ASVs (rows) where all values = 0
asv_table_F1 <- asv_table_F1[rowSums(asv_table_F1[2:(ncol(asv_table_F1)-1)])>0,]

# write output table to file
write.table(asv_table_F1, file=out_fp, sep = '\t', quote = FALSE, row.names = FALSE)
