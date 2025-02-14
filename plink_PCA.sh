#generate 10 PCs in PLINK, REGENIE lets you use relateds but they won't be included in UKB PCs so have to calculate them manually. bfile used here is array data filtered using
#--maf 0.01 --mac 20 --geno 0.1 \
#--mind 0.1 --make-bed \

#!/bin/bash
#SBATCH --job-name=plinkpca
#SBATCH --cpus-per-task=3
#SBATCH --mail-type=ALL
#SBATCH --time=47:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=1
#SBATCH --account=sscm013902
#SBATCH --mem=64G
#SBATCH --partition=mrcieu

module load apps/plink2/2.00a6LM

cd /mnt/storage/private/mrcieu/users/vc23656/PCAs

plink2 --bfile /mnt/storage/private/mrcieu/users/vc23656/bfiles/UKB --keep /mnt/storage/private/mrcieu/users/vc23656/PCAs/colorectalids.txt --pca 10 --out PCs
