#Making PRS more efficiently from REGENIE GWAS, without running into storage issues by using large BGEN files. 
#Need to create rsidlist, chrposlist and scorefile in R from REGENIE GWAS data:

rsidlist <- data.frame(GWAS_output$ID)
write.table(rsidlist, row.names = FALSE, col.names = FALSE, quote = FALSE, file = "rsidlist.txt")

scorefile <- data.frame(GWAS_output$ID, GWAS_output$ALLELE1, GWAS_output$BETA)
colnames(scorefile) <- c("rsid", "effect_allele", "beta")
write.table(scorefile, row.names = FALSE, col.names = TRUE, quote = FALSE, file = "scorefile.txt")

chrposlist <- paste(GWAS_output$CHROM, paste(GWAS_output$GENPOS, GWAS_output$GENPOS, sep = "-"), sep = ":")
write.table(chrposlist, row.names = FALSE, col.names = FALSE, quote = FALSE, file = "chrposlist.txt")

#!/bin/bash
#SBATCH --job-name=bfiles
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --time=47:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=4
#SBATCH --account=sscm013902
#SBATCH --mem=48G
#SBATCH --partition=cpu

module load gcc/10.5.0
module load bgen/1.1.7

cd /user/work/vc23656/GWAS/bfiles_prs

for i in {01..22}
do
  bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${i}.bgen"
  output_file="/user/work/vc23656/GWAS/bfiles_prs/prs_file${i}"

bgenix -g ${bgen_file} -incl-rsids /user/work/vc23656/GWAS/rsidlist_five_yr_after.txt -incl-range /user/work/vc23656/GWAS/chrposlist_fiveyrsafter.txt > chr_${i}.bgen

done
