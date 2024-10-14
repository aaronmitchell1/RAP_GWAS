#Set up the Python library

import dxpy
import numpy as np
import pandas as pd
import re
import subprocess
import glob
import os
import pyspark
import dxdata

#Initialise Spark

sc = pyspark.SparkContext()
spark = pyspark.sql.SparkSession(sc)

#Library for genetic data, using Genomics England reference panel for now (TOPMED also available)

genotype_folder = 'Genotype calls'
genotype_field_id = '22418'
output_dir = '/'
field_name ="ukb81499"

imputation_folder = 'Imputation from genotype (GEL)'
imputation_field_id = '21008'

#Automatically discover dispensed database name and dataset id
dispensed_database_name = dxpy.find_one_data_object(classname="database", name="app*", folder="/", name_mode="glob", describe=True)["describe"["name"]
dispensed_dataset_id = dxpy.find_one_data_object(typename="Dataset", name="app*.dataset", folder="/", name_mode="glob")["id"]

#Automatically discover dispensed dataset ID

#dispensed_dataset = dxpy.find_one_data_object(
    typename='White_patients_with_BMI', name='app*.White_patients_with_BMI', folder='/Aaron_PhD_inc_genetic_data/', name_mode='glob'
)
#dispensed_dataset_id = dispensed_dataset['id']

#Get project ID

project_id = dxpy.find_one_project()['id']
dataset = (':').join([project_id, dispensed_dataset_id])
participant = dataset['participant']
cohort = dxdata.load_cohort("/White_patients_with_BMI")  

#Load dictionary files from project ID

cmd = ['dx', 'extract_dataset', dataset, '-ddd', '--delimiter', ',']
subprocess.check_call(cmd)

#Discover cohort data - N.B. change name field if needed

colorectal_id = list(
    dxpy.find_data_objects(
        typename='CohortBrowser',
        folder='/',
        name_mode='exact',
        name='White_patients_with_BMI',
    )
)[0]['id']
colorectal_dataset = (':').join([project_id, colorectal_id])

#Specify relevant field IDs - sex, genetic sex, genetic ethnic grouping, sex chromosome aneuploidy, genetic kinship to other participants, age at baseline, BMI, used in genetic principal components, genetic principal components. Could potentially include smoking status?

field_ids = [
    '31',
    '22001',
    '22006',
    '22019',
    '22021',
    '21022',
    '23104',
    '22020',
    '22009',
]

path = os.getcwd()
data_dict_csv = glob.glob(os.path.join(path, '*.data_dictionary.csv'))[0]
data_dict_df = pd.read_csv(data_dict_csv)
data_dict_df.head()

def fields_for_id(field_id):
    '''Collect all field names (e.g. 'p<field_id>_iYYY_aZZZ') given a list of field IDs and return string to pass into extract_dataset'''
    field_names = ['eid']
    for _id in field_id:
        select_field_names = list(
            data_dict_df[
                data_dict_df.name.str.match(r'^p{}(_i\d+)?(_a\d+)?$'.format(_id))
            ].name.values
        )

#Select the first ten PCs, otherwise for all other variables check field names then only select instance 1

if _id == '22009':
    field_names += select_field_names[:10]
else:
    if len(select_field_names) > 0:
        field_names.append(select_field_names[0])

field_names = [f'participant.{f}' for f in field_names]
return ','.join(field_names)

#Select phenotypes

cmd = [
    'dx',
    'extract_dataset',
    colorectal_dataset,
    '--fields',
    field_names,
    '--delimiter',
    ',',
    '--output',
    'colorectal_dictionary.csv',
]
subprocess.check_call(cmd)

colorectal_dict_csv = 'colorectal_dictionary.csv'
colorectal_df = pd.read_csv(colorectal_dict_csv)
print(colorectal_df.shape)
colorectal_df.head()

#Rename column headers

colorectal_df = colorectal_df.rename(columns=lambda x: re.sub('participant.', '', x))
colorectal_df.head()

colorectal_df_qced = colorectal_df[
    (colorectal_df['p31'] == df['p22001']) # Keep only individuals whose self-reported genetic sex are the same
    & (colorectal_df['p22006'] == 1)  # Only include White British ancestry (In_white_british_ancestry_subset)
    & (  
        colorectal_df['p22019'].isnull() # No Sex chromosome aneuploidy
    )
    & (  
        colorectal_df['p22020'] == 1 # Participant was used to calculate PCA (only non-relatives were included)
    )  
].copy()

#Impute any missing BMI values with mean (shouldn't be any as they were removed at cohort browser stage but keep for later)

colorectal_df_qced['p23104_i0'].fillna(colorectal_df_qced['p23104_i0'].mean(), inplace=True)

#Tidy up dfs in REGENIE format, number each PC

colorectal_df_qced = colorectal_df_qced.rename(columns=lambda x: re.sub('p22009_a','pc',x))
colorectal_df_qced = colorectal_df_qced.rename(
    columns={
        'eid': 'IID',
        'p31': 'sex',
        'p21022': 'age',
        'p23104_i0': 'bmi',
    }
)

#Add FID column in required input format for REGENIE

colorectal_df_qced['FID'] = colorectal_df_qced['IID']

#Create a phenotype table from the QC'd data

cols = [
        'FID',
        'IID',
        'sex',
        'age',
        'bmi',
]
cols.extend([col for col in colorectal_df_qced if 'pc' in col])
colorectal_df_phenotype = colorectal_df_qced[cols]

#Z-transform BMI so it is per SD change

mean_bmi = np.mean(colorectal_df_phenotype['bmi'])
std_bmi = np.std(colorectal_df_phenotype['bmi'])
bmi_transformed = (colorectal_df_phenotype['bmi'] - mean_bmi) / std_bmi
bmi_df = pd.DataFrame({
    'bmi_transformed': bmi_transformed
})
colorectal_df_phenotype['bmi_transformed'] = bmi_df

#Select participants who are imputed to the Genomics England reference panel - genotype calls in format ukb22418_c1_b0_v2.bed +
#imputation in format ukb21008_c1_b0_v1.sample

path_to_impute_file = f'/mnt/project/Bulk/Imputation/Imputation from genotype (GEL)/ukb21008_c1_b0_v1.sample'
sample_file = pd.read_csv(
    path_to_impute_file,
    delimiter='\s',
    header=0,
    names=['FID', 'IID', 'missing', 'sex'],
    engine='python',
)

#Generate the phenotype file and the imputed .sample file for those included in the Genomics England imputed data

phenotype_df = colorectal_df_phenotype.join(
    sample_file.set_index('IID'), on='IID', rsuffix='_sample', how='inner'
)

#Remove redundant columns from .fam file

phenotype_df.drop(
    columns=['FID_sample', 'missing', 'sex_sample'],
    axis=1,
    inplace=True,
    errors='ignore',
)

#Write phenotype file to TSV

phenotype_df.to_csv('phenotype_df.phe', sep='\t', na_rep='NA', index=False, quoting=3)

#Save to RAP

%%bash -s "$output_dir"
dx upload phenotype_df.phe -p --path $1 --brief
