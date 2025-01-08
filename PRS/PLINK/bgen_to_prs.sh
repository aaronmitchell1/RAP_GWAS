#to get individual-level PRS from PRS-CS output, based on Phil Greer, Genevieve and Ashley's scripts
#cat-bgen works quickly but is quite fiddly to use, has to have a very specific input like this:

module load gcc/10.5.0
module load bgen/1.1.7

cd /mnt/storage/private/mrcieu/users/vc23656/GIANT_PRS

cat-bgen -g chr_01.bgen chr_02.bgen chr_03.bgen chr_04.bgen chr_05.bgen chr_06.bgen chr_07.bgen chr_08.bgen chr_09.bgen chr_10.bgen chr_11.bgen chr_12.bgen chr_13.bgen chr_14.bgen chr_15.bgen chr_16.bgen chr_17.bgen chr_18.bgen chr_19.bgen chr_20.bgen chr_21.bgen chr_22.bgen -og concat.bgen
bgenix -g concat.bgen -index

#convert merged dosage BGEN into PGEN to work with --score

plink2 --bgen /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined.bgen ref-first --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample --make-pgen --out /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined

#generate the PRS from the PRS-CS output. /combined is the name of the .p files. Column 2 is the RSID, 4 is the effect allele and 6 is the PRS-CS posterior effect size estimate. The SCORE1_SUM column is the PRS output, kept by using the cols=scoresums command in PLINK2.

plink2 --pfile /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined --score /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/merged_file.txt 2 4 6 list-variants cols=maybefid,nallele,denom,dosagesum,scoreavgs,scoresums no-mean-imputation ignore-dup-ids --keep /user/home/vc23656/GWAS/fiveyearspriorHPC.phe --out PRS
