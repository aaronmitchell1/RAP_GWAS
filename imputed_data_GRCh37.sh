imp_file_dir="/Bulk/Imputation/UKB imputation from genotype/"
data_field="ukb22828"
txt_file_dir="/"
for i in {1..22}; do
    run_plink_imp="plink2 --bgen ${data_field}_c${i}_b0_v3.bgen ref-first \
      --sample ${data_field}_c${i}_b0_v3.sample \
      --make-pgen --out ukbi_ch${i}_v3; \
    plink2 --pfile ukbi_ch${i}_v3 \
      --no-pheno --keep colorectal.phe \
      --maf 0.006 --mac 20 --geno 0.1 --mind 0.1 \
      --make-bed --out ${data_field}_c${i}_v3; \
     rm ukbi_ch${i}_v3* "

    dx run swiss-army-knife -iin="${imp_file_dir}/${data_field}_c${i}_b0_v3.bgen" \
     -iin="${imp_file_dir}/${data_field}_c${i}_b0_v3.sample" \
     -iin="/colorectal.phe" \
     -icmd="${run_plink_imp}" --tag="Step2" --instance-type "mem1_ssd1_v2_x8" --priority "low" \
     --destination="/" --brief --yes
done
