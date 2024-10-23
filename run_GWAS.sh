txt_file_dir=""
data_file_dir=""
data_field="ukb22828"

for chr in {1..22}; do
  run_regenie_cmd="regenie --step 2 --out assoc.c${chr} \
    --bed ${data_field}_c${chr}_v1 \
    --phenoFile colorectal.phe --covarFile colorectal.phe \
    --phenoCol bmi --covarCol age --covarCol sex \
    --covarCol pc{1:10} --pred colorectal_results_pred.list --bsize 200 \
    --minMAC 3 --threads 16 --gz"

  dx run swiss-army-knife -iin="${data_file_dir}/${data_field}_c${chr}_v1.bed" \
   -iin="${data_file_dir}/${data_field}_c${chr}_v1.bim" \
   -iin="${data_file_dir}/${data_field}_c${chr}_v1.fam" \
   -iin="${txt_file_dir}/colorectal.phe" \
   -iin="${data_file_dir}/colorectal_results_pred.list" \
   -iin="${data_file_dir}/colorectal_results_1.loco.gz" \
   -icmd="${run_regenie_cmd}" --tag="Step2" --instance-type="mem1_ssd1_v2_x8" --priority="normal"\
   --destination="/" --brief --yes

done

#Regenie will output log10p so to convert to p-value in R you can use:
gwas_output$P <- 10^-gwas_output$LOG10P
