#!/bin/bash
#SBATCH --job-name=ldmatrixcontrols
#SBATCH --cpus-per-task=3
#SBATCH --mail-type=ALL
#SBATCH --time=71:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=2
#SBATCH --account=sscm013902
#SBATCH --mem=48G
#SBATCH --partition=mrcieu

module load apps/plink2/2.00a6LM

cd /user/work/vc23656/ld_matrices/controls

plink2 --bfile /mnt/storage/private/mrcieu/users/vc23656/all_UKB_bfiles/array_bim_controls_PRSCStraining/PRSCStraining_controls_merged --r2-unphased --out ld_matrix_controls
