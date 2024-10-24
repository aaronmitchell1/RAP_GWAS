#Calculating a PRS from GWAS results on RAP

#Clump

plink \
    --bfile merged.QC \
    --clump-p1 1 \
    --clump-r2 0.1 \
    --clump-kb 250 \
    --clump bmi_int \
    --clump-snp-field SNP \
    --clump-field P \
    --out merged_clumped

awk 'NR!=1{print $3}' merged_clumped.clumped > clumped_list.snp
  
#Calculate PRS

plink \
    --bfile merged.QC \
    --score bmi_int 3 4 12 header no-mean-imputation list-variants \
    --extract clumped_list.snp \
    --out PRS
