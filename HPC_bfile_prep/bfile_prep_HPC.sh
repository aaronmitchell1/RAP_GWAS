module load apps/plink2/2.00a6LM

cd /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/directly_genotyped/released/2017-07-04/data/derived/merged_chr1-22

plink2 --bfile chr1-22_merged\
 --maf 0.01 --mac 20 --geno 0.1 \
 --mind 0.1 --make-bed\
 --out /out_dir/all_UKB_bfiles/allQC_v2_merged

cd /out_dir

for i in {01..22}; do

 plink2 --bgen /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${i}.bgen ref-first \
      --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample \
      --make-pgen --out ukb_ch${i}_v3; \
 
 plink2 --pfile ukb_ch${i}_v3 \
      --no-pheno \
      --maf 0.006 --mac 20 --geno 0.1 --mind 0.1 --max-maf 0.994 \
      --make-bed --out /out_dir/c${i}_v3; \

done
