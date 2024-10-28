#The GWAS output file is almost 4GB since there are 4 tests run with different hypotheses and is difficult to manipulate in R. Subset file by test to generate a file that is easier to work with:

input_file="GxE.txt"
temp_file="ADD-INT_SNPxstatus.txt"
output_file="GxE.Add-INT_SNPxstatus.txt"
match_value="ADD-INT_SNPxstatus"

awk -v value="$match_value" '$8 == value' "$input_file" > "$temp_file"

echo -e "$headers"

CHROM	GENPOS	ID	ALLELE0	ALLELE1	A1FREQ	N	TEST	BETA	SE	CHISQ	LOG10P	EXTRA

{                                                                       
    echo -e "$headers"
    cat "$temp_file"
} > "$output_file"
