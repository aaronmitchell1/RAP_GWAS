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


run regenie step1=
"regenie --step 1\
--lowmem --out diabetes results 
--bed ukb22418 c1 22 v1 merged\
--phenoFile diabetes wes 200k.phe 
--covarFile diabetes wes 200k.phe\
--extract 200K_ WES_array_ snps qc pass.splist 
--phenoCol status\
--covarCol age --covarCol sex --covarCol ethnic group --covarCol ever smoked\
--bsize 1000 --bt --loocv --gz --threads 16";

--interaction
