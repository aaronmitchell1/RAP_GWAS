#When working on the HPC, REGENIE 3.6 is installed which has an additional column compared to the version on SwissArmyKnife, this causes an issue when merging the 22 assoc files.
#Fix this using:

out_file="assoc.regenie.merged.txt"

echo -e "CHROM\tGENPOS\tID\tALLELE0\tALLELE1\tA1FREQ\tINFO\tN\tTEST\tBETA\tSE\tCHISQ\tLOG10P\tEXTRA" > $out_file

files="assoc*_bmi_int.regenie"
for f in $files
do
   tail -n+2 $f | tr " " "\t" >> $out_file
done
