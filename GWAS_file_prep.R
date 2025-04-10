#This method is simpler and cheaper than using Jupyter notebook
#Extract data from command line: run dx login then:

dx extract_dataset White_patients_with_BMI --entities "participant" --fields "participant.eid,participant.p31,participant.p22001,participant.p22006,participant.p22019,participant.p22021,participant.p21022,participant.p23104_i0,participant.p22020,participant.p22009_a1,participant.p22009_a2,participant.p22009_a3,participant.p22009_a4,participant.p22009_a5,participant.p22009_a6,participant.p22009_a7,participant.p22009_a8,participant.p22009_a9,participant.p22009_a10"

#This selects EIDs, self-reported sex, genetic ethnic grouping, sex chromosome aneuploidy, genetic kinship to other participants, age at baseline, BMI, used in genetic principal components, first 10 PCs
#Can ignore 22021 (genetic kinship to other participants) as none were >10.

#Process phenotype file in R

#Impute missing BMIs with mean value

mean_bmi <- mean(data$bmi, na.rm = TRUE)
data$bmi[is.na(data$bmi)] <- mean_bmi

#QC - if you have already filtered on the RAP I don't think filtering for the same terms is necessary - but some will appear as NA in the phenotype data even if you use the 'is not null' filter on RAP.
data_qced <- data[data$participant.p31 == data$participant.p22001 &    #Self-reported sex and genetic sex are the same
data$participant.p22006 == 1 &          #Only white British individuals
is.na(data$participant.p22019) &                    #No sex chromosome aneuploidy
is.na(data$participant.p22020),                        #Participant used to calculate PCs (only non-relatives included)
]

#Rename PC columns
for (i in 1:10) {
  old_name <- paste0("participant.p22009_a", i)
  new_name <- paste0("pc", i)
  
  if (old_name %in% colnames(data_qced)) {
    colnames(data_qced)[which(colnames(data_qced) == old_name)] <- new_name
  }
}

#Rename other columns
library(dplyr)

data_qced <- data_qced %>%
  rename(
    IID = participant.eid,
    sex = participant.p31,
    age = participant.p21022,
    bmi = participant.p23104_i0,
    batch = participant.p22000,
    centre = participant.p54_i0
  )

#Select only columns needed and format column names for REGENIE

data_regenie <- data_qced %>%
select(IID, sex, bmi, age, pc1:pc10, batch, centre)

#Remove rows with any missing data following QC
data_regenie <- na.omit(data_regenie)

#Add FID column needed for REGENIE, N.B. the file needs to start FID IID or REGENIE step 1 (and PLINK QC) won't run
names(data_regenie_clean)[names(data_regenie_clean) == "iid"] <- "IID"
data_regenie_clean$FID <- data_regenie_clean$IID
data_regenie_clean <- data_regenie_clean[, c("FID", setdiff(names(data_regenie_clean), "FID"))]

#Write to TSV in required format (no quotes)
write.table(data_regenie_clean,
file = 'colorectal.phe',
sep = "\t",
row.names = FALSE,
quote = FALSE)
