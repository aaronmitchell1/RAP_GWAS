White_patients_with_BMI_diagnosis_date_known$status <- 0
#This is the censoring date for UKB deaths as of January 2025
reference_date <- as.Date("2024-07-08")
White_patients_with_BMI_diagnosis_date_known$time <- difftime(reference_date, White_patients_with_BMI_diagnosis_date_known$participant.p40005_i0, units = "weeks")
White_patients_with_BMI_diagnosis_date_known$time <- (White_patients_with_BMI_diagnosis_date_known$time/52)
White_patients_with_BMI_diagnosis_date_known$time <- as.numeric(White_patients_with_BMI_diagnosis_date_known$time)
cases_alive <- White_patients_with_BMI_diagnosis_date_known[, c("participant.eid", "status", "time")]
#Only first 4 instances have any meaningful amount of data for date of cancer diagnosis, of these take the first date that occurred to calculate survival time. 
#If you try to exclude multiple cancer diagnoses to look at deaths (as I have done with case and stratified date of diagnosis previously) then number of deaths goes from 1900 to 1200 so this isn't really an option as number of deaths is so limited and there is a lot of missing data on date of diagnosis. 
#So some of these will be individuals with multiple different cancers.
White_patients_with_BMI_deaths_date_known$diagnosis <- pmin(White_patients_with_BMI_deaths_date_known$participant.p40005_i0,
                                                            White_patients_with_BMI_deaths_date_known$participant.p40005_i1,
                                                            White_patients_with_BMI_deaths_date_known$participant.p40005_i2,
                                                            White_patients_with_BMI_deaths_date_known$participant.p40005_i3,
                                                            na.rm = TRUE)
White_patients_with_BMI_deaths_date_known$status <- 1
White_patients_with_BMI_deaths_date_known$time <- difftime(White_patients_with_BMI_deaths_date_known$participant.p40000_i0, White_patients_with_BMI_deaths_date_known$participant.p40005_i0, units = "weeks")
White_patients_with_BMI_deaths_date_known$time <- (White_patients_with_BMI_deaths_date_known$time/52)
White_patients_with_BMI_deaths_date_known$time <- as.numeric(White_patients_with_BMI_deaths_date_known$time)
cases_dead <- White_patients_with_BMI_deaths_date_known[, c("participant.eid", "status", "time")]
df_combined <- rbind(cases_alive, cases_dead)

#Merge these with covariates from full UKB phenotypic file
#Format the file, rename PC columns
for (i in 1:10) {
  old_name <- paste0("participant.p22009_a", i)
  new_name <- paste0("pc", i)
  
  if (old_name %in% colnames(full_UKB)) {
    colnames(full_UKB)[which(colnames(full_UKB) == old_name)] <- new_name
  }
}

#Format standard covariates

full_UKB <- full_UKB %>%
  rename(
    IID = participant.eid,
    sex = participant.p31,
    age = participant.p21022,
    batch = participant.p22000,
    centre = participant.p54_i0
  )

#Merge the covariate and formatted survival files.

common <- intersect(df_combined$participant.eid, full_UKB$participant.eid)

df_merged <- df_combined %>%
  left_join(full_UKB %>% select(participant.eid, sex, age, batch, centre, starts_with("pc")), 
            by = "participant.eid")

df_merged <- df_merged %>%
  rename(
    IID = participant.eid
  )

df_merged$FID <- df_merged$IID

survival_formatted <- df_merged %>%
  select(FID, IID, status, time, sex, bmi, age, pc1:pc10, batch, centre)

survival_formatted <- na.omit(survival_formatted)

#Change RAP IDs to 81499 IDs to use genetic data on HPC if needed

common_participants <- intersect(survival_HPC$FID, linker_81499$app)
linker_81499 <- linker_81499 %>% filter(app %in% common_participants)
survival_HPC <- survival_HPC %>%
  left_join(linker_81499, by = "FID")
survival_HPC <- survival_HPC %>% select(-app)
survival_HPC$FID <- survival_HPC$ieu
survival_HPC$IID <- survival_HPC$ieu

write.table(survival_HPC,
            file = 'survival.phe',
            sep = "\t",
            row.names = FALSE,
            quote = FALSE)
