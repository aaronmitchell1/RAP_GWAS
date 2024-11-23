library(dplyr)

#Keep only pairs of SNPs where both appear in GIANT 2015, this reduces nSNPs from >10m to ~550k

ld_matrix_cases <- ld_matrix_cases %>%
  filter(ID_A %in% GIANT$SNP & ID_B %in% GIANT$SNP)

#Convert the PLINK long-form pairwise correlations into nxn matrix (this requires 250GB RAM for 550k SNPs) 

create_ld_matrix <- function(data) {
    snps <- unique(c(as.character(data$ID_A), as.character(data$ID_B)))
    ld_matrix <- matrix(0, nrow = length(snps), ncol = length(snps))
    rownames(ld_matrix) <- colnames(ld_matrix) <- snps
    
    for (i in 1:nrow(data)) {
        snp1 <- as.character(data$ID_A[i])
        snp2 <- as.character(data$ID_B[i])
        r2_value <- data$UNPHASED_R2[i]
        
        ld_matrix[snp1, snp2] <- r2_value
        ld_matrix[snp2, snp1] <- r2_value
    }
    return(ld_matrix)
}
