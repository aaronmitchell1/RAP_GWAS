#UKB releases diagnosis dates in instances, sometimes these are duplicates but could also reflect if a patient has been diagnosed with cancer multiple times.
#Whilst there are 21 instances, only the first 5 actually have data and numbers are very small <500 after i2 - all of these will be ones with multiple diagnoses.
#Need to filter out and keep only those cases where the patient has only 1 diagnosis, but still keep them if there is a duplication of the same date across instances.
#However in matching the first 2 columns and keeping those in a window of say 1 year (may represent artefacting) there can additionally be a date in the third column which indicates multiple diagnoses.
#Use field 40009 to filter out those who should only have 1 diagnosis, then if date in i2 is more than 1 year different from i0 or i1, remove these participants
#Then remove those where there is more than 1 year's discrepancy between i0 and i1 - after genetic QC you are left with <5000 where you can be relatively sure they have 1 diagnosis and know the date.

library(dplyr)

#We want to bin these participants by date of BMI measurement (assessment centre visit p53_i0) in relation to date of diagnosis in comparable groups
#but there are quite a few outliers as there are a lot of prevalent cases that were diagnosed historically.

#Remove any rows where participants don't have a diagnosis date after QC.

data_single_diagnosis <- data_single_diagnosis %>%
    filter(!is.na(diagnosis_date))

#Remove outliers using an IQR threshold

Q1 <- quantile(as.numeric(data_single_diagnosis$diagnosis_date - data_single_diagnosis$participant.p53_i0), 0.25, na.rm = TRUE)
Q3 <- quantile(as.numeric(data_single_diagnosis$diagnosis_date - data_single_diagnosis$participant.p53_i0), 0.75, na.rm = TRUE)
IQR <- Q3 - Q1
lower_bound <- Q1 - 1.5 * IQR
upper_bound <- Q3 + 1.5 * IQR
data_single_diagnosis$time_from_diagnosis <- (as.numeric(data_single_diagnosis$diagnosis_date - data_single_diagnosis$participant.p53_i0))
outliers_rem <- data_single_diagnosis %>%
    filter(time_from_diagnosis >= lower_bound & time_from_diagnosis <= upper_bound)
