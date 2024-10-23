#Running the GWAS using the DNANexus pipeline, the observed line was consistently above the expected line on QQ plot and λ was >1 indicating genomic inflation. 
#This was despite following UKB pipeline, removing unrelated individuals and adjusting for 10 PCs. This may be due to including too many variants in step 1.
#Take the QC'd merged bfiles from step 1 of Phil Greer's pipeline and run LD pruning, then check nSNPs:

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
