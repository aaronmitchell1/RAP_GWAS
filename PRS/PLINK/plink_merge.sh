out_file="fivetotenyraftermerged.txt"
files="/user/work/vc23656/PRScs/plink/plink_res_5to10yrafter_c*.bmi_int.glm.linear"
#copy all output from linear regression PLINK GWAS
echo -e "CHROM\tPOS\tID\tREF\tALT\tPROVISIONAL_REF?\tA1\tOMITTED\tA1_FREQ\tTEST\tOBS_CT\tBETA\tSE\tT_STAT\tP\tERRCODE" > $out_file
for f in $files; do     tail -n+2 "$f" | tr " " "\t" | awk -F'\t' '$10 == "ADD"' >> "$out_file"; done
