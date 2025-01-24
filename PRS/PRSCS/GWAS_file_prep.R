#Convert REGENIE GWAS into PRSCS format
#N.B., Allele letters have to be in capitals or they won't be recognised by PRSCS (it will run but output is empty)

library(dplyr)
library(readr)

colnames(gwas)[which(names(gwas) == "ID")] <- "SNP"
colnames(gwas)[which(names(gwas) == "ALLELE1")] <- "A1"
colnames(gwas)[which(names(gwas) == "ALLELE0")] <- "A2"
gwas_formatted_PRSCS <- dplyr::select(gwas, c("SNP", "A1", "A2", "BETA", "SE"))

write.table(gwas_formatted_PRSCS,
            file = "gwas_formatted_PRSCS.txt",
            sep = "\t",
            row.names = FALSE,
            quote = FALSE)
