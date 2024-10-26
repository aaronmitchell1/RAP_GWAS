##Experimental GWAS conducted using REGENIE on full UKB sample to assess risk factor (i.e., BMI) with case status as environmental variable.
##Since conducting GWAS of risk factors measured in cohorts with the disease are small (there are <3k individuals with i.e., BMI measured after colorectal cancer diagnosis),
##testing this approach instead.

##WES or eQTL only GWAS may also reduce multiple testing burden?

#Take cohort data from UKB SQL cohort browser. Build a complete cases cohort ('not null') for the variable of interest
#Interaction variable can be specified in the GWAS covariate file

#INT BMI

qnorm((rank(data$bmi,na.last="keep")-0.5)/sum(!is.na(data$bmi)))

#Run REGENIE step 1

#Make R value for controls 0

data_regenie$status <- 0


#The --interaction is only specified in step 2.
#You need to specify the interacting variable in covarColList and catCovarList in step 1 then additionally as --interaction in step 2.

run_regenie_step1="regenie --step 1\
 --lowmem --out gxetest_results --bed ukb22418_c1_22_v2_merged\
 --phenoFile combined_qced.phe --covarFile combined_qced.phe\
 --extract snps_qc_pass.snplist --phenoCol bmi_int\
 --covarCol age --covarCol sex --covarCol pc{1:10} --covarCol batch --covarCol centre\
 --bsize 1000 --loocv --gz --threads 16"

dx run swiss-army-knife -iin="/ukb22418_c1_22_v2_merged.bed" \
   -iin="/ukb22418_c1_22_v2_merged.bim" \
   -iin="/ukb22418_c1_22_v2_merged.fam"\
   -iin="/combined_qced.phe" \
   -iin="/snps_qc_pass.snplist" \
   -icmd="${run_regenie_step1}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" --priority "low"\
   --destination="/" --brief --yes
