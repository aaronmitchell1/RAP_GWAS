Calculate individual-level PRS (to calculate variance explained in phenotype). You need to:

Ensure you are using plink2 (not plink1) otherwise there are issues with duplicate SNPs
Make sure there are no duplicate SNPs in the summary GWAS data you are inputting into --score;
There can be duplicates in the bfiles, these are dealt with by specifying ignore-dup-ids in --score which means you don't get an error which stops the calculation
Specify header in --score if the summary GWAS file has a header
Make sure you are using imputed data if the summary GWAS was done on imputed data, which means you need to use individual chromosome bfiles, remove duplicate SNPs from each chromosome summary GWAS separately and run separate jobs
