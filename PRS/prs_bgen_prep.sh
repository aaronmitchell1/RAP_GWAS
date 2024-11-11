#Making PRS more efficiently from REGENIE GWAS, without running into storage issues by using large BGEN files. Keep SNPs from SNPlist of all colorectal patients, then generate smaller bgen files for subsequent PLINK PRS analysis.

module load gcc/10.5.0
module load bgen/1.1.7

cd /user/work/vc23656/GWAS/bfiles_prs

for i in {01..22}
do
  bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${i}.bgen"
  output_file="/user/work/vc23656/GWAS/bfiles_prs/prs_file${i}"

bgenix -g ${bgen_file} -incl-rsids /user/home/vc23656/GWAS/snps_qc_pass.snplist > chr_${i}.bgen

done
