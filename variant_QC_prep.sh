#Run this after preparing the phenotype file, UKB genotype calls are stored in seperate files per chromosome so need to be merged.
#Ensure that instance-type is mem1_ssd2_v2_x8 and priority is low or this step can get very expensive.
#Some people suggest setting HWE p-value to either very high or very low,
#0.001 or 1e-60, need to test this but shouldn't be too much of a problem in a small 10k sample.

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
#can change to covarCol pc{1:10}
#This needs to have config mem1_ssd1_v2_x16 or you will get a low memory error.

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

#Prep REGENIE step 2, loop to make per-chromosome pgens/beds

data_field="ukb21008"
file_dir="/Bulk/Imputation/Imputation from genotype (GEL)"

for i in {1..22}; do
    run_plink="plink2 --bgen ${data_field}_c${i}_b0_v1.bgen ref-first\
      --sample ${data_field}_c${i}_b0_v1.sample \
      --make-pgen --out ukbi_ch${i}_v1; \
    plink2 --pfile ukbi_ch${i}_v1 \
      --no-pheno --keep colorectal.phe \
      --maf 0.006 --mac 20 --geno 0.1 --mind 0.1 \
      --make-bed --out ${data_field}_c${i}_v1; \
     rm ukbi_ch${i}_v1* "

    dx run swiss-army-knife -iin="${file_dir}/${data_field}_c${i}_b0_v1.bgen" \
     -iin="${file_dir}/${data_field}_c${i}_b0_v1.sample" \
     -iin="/colorectal.phe" \
     -icmd="${run_plink}" --tag="Step2" --instance-type "mem1_ssd2_v2_x8" --priority "low"\
     --destination="/" --brief --yes
done
