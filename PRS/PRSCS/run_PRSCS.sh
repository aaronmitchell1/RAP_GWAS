#!/bin/bash
#SBATCH --job-name=PRS5to10yrafter
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=3
#SBATCH --mail-type=ALL
#SBATCH --time=47:59:59
#SBATCH --mail-user=aaron.mitchell@bristol.ac.uk
#SBATCH --nodes=2
#SBATCH --account=sscm013902
#SBATCH --mem=48G
#SBATCH --partition=cpu

cd /user/work/vc23656/PRScs/

source ~/initConda.sh

conda init
conda activate pyprscs

python PRScs.py --ref_dir=/mnt/storage/private/mrcieu/users/vc23656/PRSCS_LD/ldblk_1kg_eur --bim_prefix=/mnt/storage/private/mrcieu/users/vc23656/all_UKB_bfiles/array_bim_controls_PRSCStraining/PRSCStraining_controls_merged --sst_file=/user/work/vc23656/PRScs/fivetotenyrafter_formatted.txt --n_gwas=1618 --out_dir=/user/work/vc23656/PRScs/fivetotenyrsafter/prs --phi=1e-2
