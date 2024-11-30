out_file="fivetotenyraftermerged.txt"
files="/user/work/vc23656/PRScs/plink/plink_res_5to10yrafter_c*.bmi_int.glm.linear"
echo -e "CHROM\tPOS\tID\tREF\tALT\tA1\tFIRTH\tTEST\tBETA\tSE\tP" > $out_file
for f in $files; do     tail -n+2 "$f" | tr " " "\t" | awk -F'\t' '$10 == "ADD"' >> "$out_file"; done
