#Make merged bfile including 22 chromosomes
run_merge="cp /mnt/project/Bulk/Genotype\ Results/Genotype\ calls/ukb22418_c[1-9]* . ;\
        ls *.bed | sed -e 's/.bed//g'> files_to_merge.txt; \
        plink --merge-list files_to_merge.txt --make-bed\
        --autosome-xy --out ukb22418_c1_22_v2_merged;\
        rm files_to_merge.txt;"

dx run swiss-army-knife -iin="/Data/diabetes_wes_200k.phe" \
   -icmd="${run_merge}" --tag="Step1" --instance-type "mem1_ssd1_v2_x16"\
   --destination="/Data/" --brief --yes 

#Keep participants from .phe from previous script
plink2 --bfile ukb_c1-22_merged 
--keep colorectal_df.phe 
--autosome --maf 0.01 --mac 100 --geno 0.1 --hwe 1e-15 --mind 0.1 --write-snplist --write-samples --no-id-header --out imputed_array_snps_qc_pass

#Then run bgens_qc.wdl on RAP, specify -folder

#Make SNP and ID list from merged chromosome file

plink2 \ 
--bfile ukb_c1-22_hs38DH_merged \ 
--out final_array_snps_CRCh38_qc_pass \ 
--mac 100 --maf 0.01 --hwe 1e-15 --mind 0.1 --geno 0.1 \ 
--write-snplist --write-samples --no-id-header \ 
--threads $(nproc)
