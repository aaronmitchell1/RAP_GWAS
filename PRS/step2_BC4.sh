#!/bin/bash
#SBATCH --job-name=GWAS
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=4
#SBATCH --mail-type=ALL
#SBATCH --time=47:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=4
#SBATCH --account=sscm013902
#SBATCH --mem=48G
#SBATCH --partition=cpu

module load apps/regenie/3.6

cd /user/work/vc23656/GWAS/

for chr in $(seq 1 22); do
    if [ $chr -lt 10 ]; then
        bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr0${chr}.bgen"
    else
        bgen_file="/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${chr}.bgen"
    fi

    regenie --step 2 --out assoc_fiveyearsafter.c${chr} \
      --bgen ${bgen_file} \
      --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample \
      --phenoFile /user/home/vc23656/GWAS/fiveyearsafterHPC.phe \
      --phenoCol bmi_int --covarCol age --covarCol batch --covarCol centre \
      --covarCol sex \
      --covarCol pc{1:10} \
      --covarFile /user/home/vc23656/GWAS/fiveyearsafterHPC.phe \
      --bsize 200 \
      --minMAC 3 --threads 16 \
      --pred fiveyrafter_pred.list \
      --out step2_fiveyrafter${chr}
done
