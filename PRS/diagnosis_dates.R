#UKB releases diagnosis dates in instances, sometimes these are duplicates but could also reflect if a patient has been diagnosed with cancer multiple times.
#Need to filter out and keep only those cases in the 21 instances where the patient has only 1 diagnosis, but still keep them if there is a duplication of the same date across instances.

library(dplyr)

data_single_diagnosis <- data %>%
    rowwise() %>%
    mutate(diagnosis_date = case_when(
        sum(!is.na(c_across(participant.p40005_i0:participant.p40005_i21))) == 1 ~
            first(c_across(participant.p40005_i0:participant.p40005_i21)[!is.na(c_across(participant.p40005_i0:participant.p40005_i21))]),
        all(c_across(participant.p40005_i0:participant.p40005_i21) == first(na.omit(c_across(participant.p40005_i0:participant.p40005_i21)))) ~
            first(na.omit(c_across(participant.p40005_i0:participant.p40005_i21))),
        TRUE ~ as.Date(NA)
    ))

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
