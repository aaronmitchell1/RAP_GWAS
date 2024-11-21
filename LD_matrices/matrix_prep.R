rm(list=ls())
setwd("/user/work/vc23656/ld_matrices/")
library(readr)
library(Matrix)

ld_matrix_controls <- read_delim("/user/work/vc23656/ld_matrices/controls/ld_matrix_controls.vcor", 
    delim = "\t", escape_double = FALSE, show_col_types = FALSE,
    trim_ws = TRUE)

ld_matrix_cases <- read_delim("/user/work/vc23656/ld_matrices/cases/ld_matrix_cases.vcor", 
    delim = "\t", escape_double = FALSE, show_col_types = FALSE,
    trim_ws = TRUE)

cases_snps <- unique(c(as.character(ld_matrix_cases$ID_A), as.character(ld_matrix_cases$ID_B)))

n_cases_snps <- length(cases_snps)

controls_snps <- unique(c(as.character(ld_matrix_controls$ID_A), as.character(ld_matrix_controls$ID_B)))

n_controls_snps <- length(controls_snps)

#Matrices using Matrix package - seems to avoid requesting ridiculous amount of RAM?
r2_matrix_cases <- Matrix(0, nrow = n_cases_snps, ncol = n_cases_snps, sparse = TRUE)
rownames(r2_matrix_cases) <- colnames(r2_matrix_cases) <- cases_snps

r2_matrix_controls <- Matrix(0, nrow = n_controls_snps, ncol = n_controls_snps, sparse = TRUE)
rownames(r2_matrix_controls) <- colnames(r2_matrix_controls) <- controls_snps

for (i in 1:nrow(ld_matrix_cases)) {
  snp1 <- as.character(ld_matrix_cases$ID_A[i])
  snp2 <- as.character(ld_matrix_cases$ID_B[i])
  r2_value_cases <- ld_matrix_cases$UNPHASED_R2[i]
  
  r2_matrix_cases[snp1, snp2] <- r2_value_cases
  r2_matrix_cases[snp2, snp1] <- r2_value_cases
}

for (i in 1:nrow(ld_matrix_controls)) {
  snp1 <- as.character(ld_matrix_controls$ID_A[i])
  snp2 <- as.character(ld_matrix_controls$ID_B[i])
  r2_value_controls <- ld_matrix_controls$UNPHASED_R2[i]
  
  r2_matrix_controls[snp1, snp2] <- r2_value_controls
  r2_matrix_controls[snp2, snp1] <- r2_value_controls
}

save(r2_matrix_cases, file = 'r2_matrix_cases_sparse.RData')
save(r2_matrix_controls, file = 'r2_matrix_controls_sparse.RData')
