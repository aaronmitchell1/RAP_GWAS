#This method is simpler and cheaper than using Jupyter notebook
#Extract data from command line: run dx login then:

dx extract_dataset White_patients_with_BMI --entities "participant" --fields "participant.eid,participant.p31,participant.p22001,participant.p22006,participant.p22019,participant.p22021,participant.p21022,participant.p23104_i0,participant.p22020,participant.p22009_a1,participant.p22009_a2,participant.p22009_a3,participant.p22009_a4,participant.p22009_a5,participant.p22009_a6,participant.p22009_a7,participant.p22009_a8,participant.p22009_a9,participant.p22009_a10"

#This selects EIDs, self-reported sex, genetic ethnic grouping, sex chromosome aneuploidy, genetic kinship to other participants, age at baseline, BMI, used in genetic principal components, first 10 PCs

#Process phenotype file in R

#Impute missing BMIs with mean value

mean_bmi <- mean(data$bmi, na.rm = TRUE)
data$bmi[is.na(data$bmi)] <- mean_bmi

#QC
data_qced <- data[data$sex == data$participant.p22001 &    #Self-reported sex and genetic sex are the same
data$participant.p22006 == 1 &          #Only white British individuals
is.na(data$participant.p22019) &                    #No sex chromosome aneuploidy
data$participant.p22020 == 1,                        #Participant used to calculate PCs (only non-relatives included)
]

#Select only columns needed and format column names for REGENIE

data_regenie <- data_qced %>%
select(eid, sex, bmi, age, pc1:pc10)
names(data_qced)[names(data_qced) == "participant.p21022"] <- "age"

#Remove rows with any missing data following QC
data_regenie <- na.omit(data_regenie)

#Add FID column needed for REGENIE, N.B. the file needs to start FID IID or REGENIE step 1 won't run
names(data_regenie_clean)[names(data_regenie_clean) == "iid"] <- "IID"
data_regenie_clean$FID <- data_regenie_clean$IID

#Write to TSV in required format (no quotes)
write.table(data_regenie_clean,
file = 'colorectal.phe',
sep = "\t",
row.names = FALSE,
quote = FALSE)
