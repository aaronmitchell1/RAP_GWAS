#!/bin/bash
#SBATCH --job-name=survivalstep2
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --time=47:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=4
#SBATCH --account=sscm013902
#SBATCH --mem=48G
#SBATCH --partition=cpu

module load apps/regenie/4.0

cd /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS

for chr in $(seq 1 22); do
    if [ $chr -lt 10 ]; then
        bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr0${chr}.bgen"
    else
        bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${chr}.bgen"
    fi

    regenie --step 2 --out survival.c${chr} \
      --bgen ${bgen_file} --t2e \
      --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample \
      --phenoFile /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS/survival.phe \
      --covarFile /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS/survival.phe --eventColList status --phenoColList time \
      --covarColList age,pc{1:10},batch,centre --catCovarList sex \
      --bsize 200 \
      --minMAC 3 --threads 16 \
      --pred /mnt/storage/private/mrcieu/users/vc23656/survival_GWAS/survival_step1_pred.list \

done
