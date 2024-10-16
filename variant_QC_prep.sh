#Run this after preparing the phenotype file, UKB genotype calls are stored in seperate files per chromosome so need to be merged.

#Make merged bfile including 22 chromosomes
run_merge="cp /mnt/project/Bulk/Genotype\ Results/Genotype\ calls/ukb22418_c[1-9]* . ;\
        ls *.bed | sed -e 's/.bed//g'> files_to_merge.txt; \
        plink --merge-list files_to_merge.txt --make-bed\
        --autosome-xy --out ukb22418_c1_22_v2_merged;\
        rm files_to_merge.txt;"

dx run swiss-army-knife -iin="/Data/diabetes_wes_200k.phe" \
   -icmd="${run_merge}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="/Data/" --brief --yes 

#Make SNP and ID list from merged chromosome file

run_plink_qc="plink2 --bfile ukb22418_c1_22_v2_merged --autosome --maf 0.01 --mac 20 --geno 0.1 --hwe 1e-15 --mind 0.1 --write-snplist --write-samples --no-id-header --out snps_qc_pass"

dx run swiss-army-knife -iin="/ukb22418_c1_22_v2_merged.bed" \
   -iin="/ukb22418_c1_22_v2_merged.bim" \
   -iin="/ukb22418_c1_22_v2_merged.fam"\
   -iin="/colorectal.phe" \
   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="/" --brief --yes

#Step 1 REGENIE

run_regenie_step1="regenie --step 1\
 --lowmem --out colorectal_results --bed ukb22418_c1_22_v2_merged\
 --phenoFile colorectal.phe --covarFile colorectal.phe\
 --extract snps_qc_pass.snplist --phenoCol bmi\
 --covarCol age --covarCol sex --covarCol pc1 --covarCol pc2 --covarCol pc3 --covarCol pc4 --covarCol pc5 --covarCol pc6 --covarCol pc7 --covarCol pc8 --covarCol pc9 --covarCol pc10\
 --bsize 1000 --loocv --gz --threads 16"

dx run swiss-army-knife -iin="/ukb22418_c1_22_v2_merged.bed" \
   -iin="/ukb22418_c1_22_v2_merged.bim" \
   -iin="/ukb22418_c1_22_v2_merged.fam"\
   -iin="/colorectal.phe" \
   -iin="/snps_qc_pass.snplist" \
   -icmd="${run_regenie_step1}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="/" --brief --yes
