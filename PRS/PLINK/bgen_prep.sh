#to get individual-level PRS from PRS-CS output, based on Phil Greer, Genevieve and Ashley's scripts

#couldn't get cat-bgeni in BGENIX to work but this seems to be OK instead, concat into 1 file for PLINK, generating the .bgen.bgi index file wouldn't work either but you don't seem to need it

for i in {01..22}
do
cat /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/chr_${i}.bgen >> /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined.bgen
done

#convert merged dosage BGEN into PGEN to work with --score

plink2 --bgen /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined.bgen ref-first --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample --make-pgen --out /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined

#generate the PRS from the PRS-CS output. Column 2 is the RSID, 4 is the effect allele and 6 is the PRS-CS posterior effect size estimate

plink2 --pfile /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/bgenix/combined --score /mnt/storage/private/mrcieu/users/vc23656/ind_PRS/5prior/merged_file.txt 2 4 6 no-mean-imputation ignore-dup-ids --keep /user/home/vc23656/GWAS/fiveyearspriorHPC.phe --out PRS
