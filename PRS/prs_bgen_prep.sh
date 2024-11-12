#Making PRS more efficiently from REGENIE GWAS, without running into storage issues by using large BGEN files. 
#Need to create rsidlist, chrposlist and scorefile in R from REGENIE GWAS data:

rsidlist <- data.frame(GWAS_output$ID)
write.table(rsidlist, row.names = FALSE, col.names = FALSE, quote = FALSE, file = "rsidlist.txt")

scorefile <- data.frame(GWAS_output$ID, GWAS_output$ALLELE1, GWAS_output$BETA)
colnames(scorefile) <- c("rsid", "effect_allele", "beta")
write.table(scorefile, row.names = FALSE, col.names = TRUE, quote = FALSE, file = "scorefile.txt")

chrposlist <- paste(GWAS_output$CHROM, paste(GWAS_output$GENPOS, GWAS_output$GENPOS, sep = "-"), sep = ":")
write.table(chrposlist, row.names = FALSE, col.names = FALSE, quote = FALSE, file = "chrposlist.txt")

module load gcc/10.5.0
module load bgen/1.1.7

cd /user/work/vc23656/GWAS/bfiles_prs

for i in {01..22}
do
  bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${i}.bgen"
  output_file="/user/work/vc23656/GWAS/bfiles_prs/prs_file${i}"

bgenix -g ${bgen_file} -incl-rsids /user/home/vc23656/GWAS/snps_qc_pass.snplist > chr_${i}.bgen

done
