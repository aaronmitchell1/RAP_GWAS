#create a matrix in plink of individuals x SNPs to make an LD matrix in R

module load apps/plink2/2.00a6LM
module load gcc/10.5.0
module load bgen/1.1.7

#create 22 bgens containing only the SNPs you want (in a plain .txt with no header)

for i in {01..22}; do

bgenix -g "/mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr${i}.bgen" -incl-rsids "/mnt/storage/private/mrcieu/users/vc23656/matrices/random_SNPs.txt" > "chr_${i}.bgen"

done

#merge them into 1 bgen

cat-bgen -g chr_01.bgen chr_02.bgen chr_03.bgen chr_04.bgen chr_05.bgen chr_06.bgen chr_07.bgen chr_08.bgen chr_09.bgen chr_10.bgen chr_11.bgen chr_12.bgen chr_13.bgen chr_14.bgen chr_15.bgen chr_16.bgen chr_17.bgen chr_18.bgen chr_19.bgen chr_20.bgen chr_21.bgen chr_22.bgen -og concat.bgen

#create index file

bgenix -g concat.bgen -index

#convert that into a pgen

plink2 --bgen /mnt/storage/private/mrcieu/users/vc23656/matrices/random/concat.bgen ref-first --sample /mnt/storage/private/mrcieu/data/ukbiobank/genetic/variants/arrays/imputed/released/2018-09-18/data/dosage_bgen/data.chr1-22.sample --make-pgen --out /mnt/storage/private/mrcieu/users/vc23656/matrices/combined

#create the bfiles for subsequent analysis

plink2 --pfile /mnt/storage/private/mrcieu/users/vc23656/matrices/combined --keep /mnt/storage/private/mrcieu/users/vc23656/matrices//mnt/storage/private/mrcieu/users/vc23656/matrices/cases_1000_random.phe --make-bed --out cases
