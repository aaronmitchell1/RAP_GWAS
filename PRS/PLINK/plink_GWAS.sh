#for individual-level PRS (i.e., to calculate R^2 of the PRS rather than just from summary GWAS) need to do GWAS in PLINK (PLINK --score doesn't seem to like REGENIE GWAS output) then calculate PRS.

module load apps/plink2/2.00a6LM

cd /user/work/vc23656/PRScs/plink

for i in {01..22}; do

plink2 --bfile /mnt/storage/private/mrcieu/users/vc23656/all_UKB_bfiles/c${i}_v3 \
       --pheno /user/work/vc23656/GWAS/fivetotenyearsafterHPC.phe --no-input-missing-phenotype --pheno-name bmi_int \
       --covar /user/work/vc23656/GWAS/fivetotenyearsafterHPC.phe --covar-name age,batch,centre,pc1,pc2,pc3,pc4,pc5,pc6,pc7,pc8,pc9,pc10,sex --covar-variance-standardize \
       --linear --out plink_res_5to10yrafter_c${i}

 done

 #Can change covar-variance-standardize to only pcs (1&2 seem to be problematic when sample includes only UK individuals).
