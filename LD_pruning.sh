#Run the LD pruning step for array variants before step 1, this can reduce the number of SNPs from 10m to 500k if needed to save time/money on RAP.

data_field="ukb22418_c1_22"

run_plink_qc="plink2 --bfile ${data_field}_v2_merged \
 --indep-pairwise 1000 50 0.4  --out ukb-pruning ;\
ls *bed; \
plink2 --bfile ${data_field}_v2_merged --extract ukb-pruning.prune.in \
 --keep colorectal.phe --make-bed --out ${data_field}_v2_mrg_prun_cohort ;\
wc *.bim "

dx run swiss-army-knife -iin="ukb22418_c1_22_v2_merged.bed" \
   -iin="ukb22418_c1_22_v2_merged.bim" \
   -iin="/ukb22418_c1_22_v2_merged.fam" \
   -iin="/colorectal.phe" \
   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" --priority "low" \
   --destination="/" --brief --yes
