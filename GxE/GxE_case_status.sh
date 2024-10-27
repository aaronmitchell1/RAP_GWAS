array_file_dir="/Bulk/Genotype Results/Genotype calls/"
data_field="ukb22418"
data_file_dir="/GxE"
txt_file_dir="/GxE"

#step 1, needs mem1_ssd1_v2_x16 config or you will get a low storage error

run_merge="cp /mnt/project/Bulk/Genotype\ Results/Genotype\ calls/ukb22418_c[1-9]* . ;\
        ls *.bed | sed -e 's/.bed//g'> files_to_merge.txt; \
        plink --merge-list files_to_merge.txt --make-bed\
        --out ukb22418_all_v2_merged;\
        rm files_to_merge.txt;\
        rm ukb22418_c*"

dx run swiss-army-knife -iin="${txt_file_dir}/combined_qced.phe" \
   -icmd="${run_merge}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" --priority "low"\
   --destination="/GxE" --brief --yes

#step 2

run_plink_qc="plink2 --bfile ${data_field}_all_v2_merged\
 --maf 0.01 --mac 20 --geno 0.1 \
 --mind 0.1 --make-bed\
 --out  ${data_field}_allQC_v2_merged"

dx run swiss-army-knife -iin="${data_file_dir}/${data_field}_all_v2_merged.bed"\
   -iin="${data_file_dir}/${data_field}_all_v2_merged.bim" \
   -iin="${data_file_dir}/${data_field}_all_v2_merged.fam"\
   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x8" --priority "low"\
   --destination="/GxE" --brief --yes

#step 3 - doesn't seem to be too much slower if you don't set keep

run_plink_qc="plink2 --bfile ${data_field}_allQC_v2_merged \
 --indep-pairwise 1000 50 0.4  --out ukb-pruning ;\
ls *bed; \
plink2 --bfile ${data_field}_allQC_v2_merged --extract ukb-pruning.prune.in \
--make-bed --out ${data_field}_allQC_v2_mrg_prun_cohort ;\
wc *.bim "

dx run swiss-army-knife -iin="${data_file_dir}/${data_field}_allQC_v2_merged.bed" \
   -iin="${data_file_dir}/${data_field}_allQC_v2_merged.bim" \
   -iin="${data_file_dir}/${data_field}_allQC_v2_merged.fam"\
   -icmd="${run_plink_qc}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" --priority "low"\
   --destination="/GxE/" --brief --yes

#step 4 

run_regenie_cmd="regenie --step 1 --out GxE_results \
 --bed ${data_field}_allQC_v2_mrg_prun_cohort \
 --phenoFile combined_qced.phe \
 --covarFile combined_qced.phe \
 --phenoCol bmi_int --covarCol age --covarCol batch --covarCol centre \
 --covarCol status --covarCol sex \
 --covarCol pc{1:10} \
 --bsize 1000 --loocv --gz --threads 16"

dx run swiss-army-knife -iin="${data_file_dir}/${data_field}_allQC_v2_mrg_prun_cohort.bed"\
   -iin="${data_file_dir}/${data_field}_allQC_v2_mrg_prun_cohort.bim"\
   -iin="${data_file_dir}/${data_field}_allQC_v2_mrg_prun_cohort.fam"\
   -iin="${txt_file_dir}/combined_qced.phe" \
   -icmd="${run_regenie_cmd}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16" --priority "low" \
   --destination="/GxE/" --brief --yes

#step 5

data_field="ukb22828"
data_file_dir="/GxE"
txt_file_dir="/GxE"
imp_file_dir="/Bulk/Imputation/UKB imputation from genotype/"

   for i in {1..22}; do
    run_plink_imp="plink2 --bgen ${data_field}_c${i}_b0_v3.bgen ref-first\
      --sample ${data_field}_c${i}_b0_v3.sample \
      --make-pgen --out ukbi_ch${i}_v3; \
    plink2 --pfile ukbi_ch${i}_v3 \
      --no-pheno \
      --maf 0.006 --mac 20 --geno 0.1 --mind 0.1 \
      --make-bed --out ${data_field}_c${i}_v3; \
     rm ukbi_ch${i}_v3*"

    dx run swiss-army-knife -iin="${imp_file_dir}/${data_field}_c${i}_b0_v3.bgen" \
     -iin="${imp_file_dir}/${data_field}_c${i}_b0_v3.sample" \
     -icmd="${run_plink_imp}" --tag="Step2" --instance-type "mem1_ssd2_v2_x8" --priority "low"\
     --destination="/GxE/" --brief --yes
done

#step 6

for chr in {1..22}; do
  run_regenie_cmd="regenie --step 2 --out assoc.c${chr} \
     --bed ${data_field}_c${chr}_v3 \
     --phenoFile combined_qced.phe --covarFile combined_qced.phe --bsize 200 --pred GxE_results_pred.list \
     --phenoCol bmi_int --covarCol age --covarCol batch --covarCol centre \
     --covarCol status --covarCol sex \
     --covarCol pc{1:10} \
     --interaction status \
     --minMAC 3 --threads 16 --gz"

  dx run swiss-army-knife -iin="${data_file_dir}/${data_field}_c${chr}_v3.bed" \
   -iin="${data_file_dir}/${data_field}_c${chr}_v3.bim" \
   -iin="${data_file_dir}/${data_field}_c${chr}_v3.fam" \
   -iin="${txt_file_dir}/combined_qced.phe" \
   -iin="${data_file_dir}/GxE_results_pred.list" \
   -iin="${data_file_dir}/GxE_results_1.loco.gz" \
   -icmd="${run_regenie_cmd}" --tag="Step2" --instance-type "mem1_ssd2_v2_x8" --priority "low" \
   --destination="/GxE/" --brief --yes

done
