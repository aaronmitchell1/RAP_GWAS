library(snpStats)

#function to get genotypes in correct format to convert to matrix
convert_genotype <- function(x) {
x <- as.character(x)  #Ensure the raw genotypes are a character vector first, then recode genotypes
ifelse(x == "03", 2, ifelse(x == "02", 1, ifelse(x == "01", 0, NA)))
}

#read in the bfiles, in this case we are using a random sample of 1000 cases and controls to keep file size manageable
plink_file <- "path_to_file"
geno_data <- read.plink(paste0(plink_file, ".bed"), paste0(plink_file, ".bim"), paste0(plink_file, ".fam"))

rawgen <- data.frame(geno_data$genotypes)

#create a string of SNP names from individual-level genotype data
SNPs <- colnames(rawgen)

rawmat <- as.matrix(rawgen)
rawmat <- apply(rawmat, 2, convert_genotype)
cormat <- cor(rawmat[, SNPs], method = "pearson", use="pairwise")
cormat[upper.tri(cormat)] <- 0
diag(cormat) <- 0
cormat <- (cormat)^2
filtered <-which(cormat > 0.01, arr.ind = T)
