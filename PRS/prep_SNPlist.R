#only need the SNPs used in the PRS to make the merged bgen file, can extract them from merged PRS using:

writeLines(merged_PRS_file$X2, "RSIDlistPRS.txt")
