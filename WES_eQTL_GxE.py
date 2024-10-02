##Experimental GWAS conducted using REGENIE on full UKB sample to assess risk factor (i.e., BMI) with case status as environmental variable.
##Since conducting GWAS of risk factors measured in cohorts with the disease are small (there are <3k individuals with i.e., BMI measured after colorectal cancer diagnosis),
##testing this approach instead.

##WES or eQTL only GWAS may also reduce multiple testing burden.

#Take cohort data from UKB SQL cohort browser. Build a complete cases cohort ('not null') for the variable of interest
#Interaction variable can be specified in the GWAS covariate file

#Need to liftover SNP array from GRCh37 to GRCh38 using BCFtools

#Process genotype calls with PLINK

Bulk/Genotype 
Results/Genotype Calls/

#Set output directory on RAP.

data_file_dir="/Data/"

#QC filtering

covariates: age, sex, age^2 

#Run REGENIE step 1

./regenie \
  --step 1 \
  --bed example/example \
  --exclude example/snplist_rm.txt \
  --covarFile example/covariates.txt \
  --phenoFile example/phenotype_bin.txt \
  --remove example/fid_iid_to_remove.txt \
  --bsize 100 \
  --bt --lowmem \
  --lowmem-prefix tmp_rg \
  --out fit_bin_out

run regenie step1=
"regenie --step 1\
--lowmem --out diabetes results 
--bed ukb22418 c1 22 v1 merged\
--phenoFile diabetes wes 200k.phe 
--covarFile diabetes wes 200k.phe\
--extract 200K_ WES_array_ snps qc pass.splist 
--phenoCol diabetes cc\
--covarCol age --covarCol sex --covarCol ethnic group --covarCol ever smoked\
--bsize 1000 --bt --loocv --gz --threads 16";

dx run swiss-army-knife -iin="$(data file dir)/ukb22418 c1 22 v1 merged.bed" \
-iin="$ (data file dir)/ukb22418 c1 22 v1 merged.bim" \
-iin="${data file _dir)/ukb22418_c1_22_v1_merged. fam"|
-iin="$(data_file_dir)/200K_WES_array_sps_qc_pass.snplist\
-iin="$(data file dir)/diabetes wes_200k.phe" \
-icmd=$ (run regenie step1) --tag="Stepl" --instance-type
"mem1 ssd1 v2 x16"\
--destination="$ (data file dir)" --brief --yes;


--interaction


