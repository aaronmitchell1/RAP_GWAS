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
module load apps/plink2/2.00a6LM

cd /user/work/vc23656/GWAS/bfiles_prs

#cols 3, 5 and 10 represent RSID, effect allele and beta in a standard REGENIE 3.6 GWAS

cmd=""

for i in {01..22}; do
    cmd="$cmd /user/work/vc23656/GWAS/bfiles_prs/chr_${i}.bgen"
done

cat-bgen -g $cmd -og initial_chr.bgen -clobber

bgenix -g initial_chr.bgen -index -clobber

plink2 --bgen initial_chr.bgen ref-first --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22_plink.sample --freq --maf 0.01 --make-pgen --out prsfivetotenyrafter
plink2 --pfile prsfivetotenyrafter --score /user/work/vc23656/GWAS/step2_fivetotenyrafter1_bmi_int_merged.txt 3 5 10 --out prsfivetotenyrafterout
