#!/bin/bash
#SBATCH --job-name=survivalstep1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --time=47:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=2
#SBATCH --account=sscm013902
#SBATCH --mem=48G
#SBATCH --partition=cpu

module load apps/regenie/4.0

cd /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS

regenie --step 1 --out /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS/survival_step1 --t2e \
 --bed /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/directly_genotyped/released/2017-07-04/data/derived/merged_chr1-22/chr1-22_merged \
 --phenoFile /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS/survival.phe \
 --covarFile /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS/survival.phe --eventColList status --phenoColList time \
 --covarColList age,pc{1:10},batch,centre --catCovarList sex \
 --extract /user/home/vc23656/GWAS/snps_qc_pass.snplist \
 --bsize 1000 --loocv --threads 16
