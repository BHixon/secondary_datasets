LOTUS Analytic Plan Template
4/2/2024

Project Title: Measurements for SDOH Adjustment in a Lung Cancer Screening Eligible Cohort

PARC Record ID: 
Analytic Plan Authors: Hixon, Brian

Writing Group Members:


Affiliation: KPCO

Original Date:

Updated:


A.	Background/Rational/Significance
 
Approximately 125,000 deaths are expected in 2024 due to lung cancer, making it the most common cause of cancer death in the United States [1 ]. The high numbers of lung cancer deaths led the United States Preventive Services Task Force (USPSTF) to develop guidelines to identify those who should be targeted for screening to help reduce this burden. These guidelines, established in 2013, identify the eligible population based upon age and smoking history. The guidelines were revised in 2021 to minimize disparities in racial and ethnic minority groups and those with lower Socioeconomic Status (SES) showing the need to consider a diverse population [2]. Additional studies have demonstrated that the updated guidelines applied to a diverse cohort is more effective at lowering barriers and increasing eligibility for screening [3] . While lung cancer screening and treatment is effective if utilized, recent studies have shown that only 6% of eligible people are screened which is in line with pre-guideline levels indicating that the USPSTF guidelines have not been effectively implemented or they are not targeting the sectors of the population who may benefit the most. This is likely due to a variety of possible factors such as barriers for physicians and patients, perspectives, shared decision making, and disparities  [4]. As such, more effort is necessary to explore elements of SDOH in need of inclusion in health research and evaluating SDOH indices to identify which are better at this task.
 
Social Determinants of Health  (SDOH) and their impact upon cancer control and outcome efforts have been extensively described in Healthy People 2030 [4-7]. These factors can include everything from education and income to the built environment and discrimination [8]. While most people understand the need to consider and adjust for SDOH when designing interventions and studies, there is still a significant amount of confusion regarding what the most impactful factors to adjust for are and often default to education and income since they logically impact so many potential factors on a person’s health and health choices. Given the complexity and interaction of the factors comprising SDOH and a recent study indicating that nearly 75% of identifiable cancers are associated with SDOH  it would appear that current efforts are not sufficient in reducing the disparities in Lung Cancer Screening (LCS) [9].. 
 
One of the most common ways to adjust for numerous SDOH without saturating a model is the use of an index [10]. There are numerous indices and measures publicly available including the Neighborhood Deprivation Index (NDI), the YOST Index, the Social Vulnerability Index (SVI), education/income.   . Each of these can be relatively similar in in terms of variables that are included but some have large differences (eg the Yost has 7 variables while the SVI contains 16) and some combine common SES measures (education and income) with less common elements such as physical infrastructure [10]. It is relatively common for a single index to be used to adjust for confounders and while a model rarely needs more than one there is little information comparing the effect of these indices on specific outcomes and if one index might be superior to another one when considering cancer screening outcomes. For this project we will evaluate five different SDOH indices to determine if one particular index is superior when predicting likelihood of cancer screening. . 

B.	Study Design: Retrospective Cohort/ Methods Paper


C.	Study Aims:
1)	Aim 1 – Assess the distribution of five different SDOH indices/ measurements (Yost, NDI, SVI, education, and income  ) in an LCS-eligible population by health system and overall population  . 

2)	Aim2 – Determine if one index is superior to others in improving model fit   and predicting the likelihood of lung cancer screening.

D.	Study Population Definitions 
1)	Inclusion Criteria
i.	Lung Cancer Screening Eligible Population as of January 1st, 2014
1.	50-80 years old
2.	Currently smokes or Formerly smoked within last 15 years
3.	20 Pack Year History
2)	Exclusion Criteria
i.	Prior history of lung cancer
ii.	Missing geocode

3)	LOTUS populations included
☒ HFHS
☒ HAP (HMO) population
☐ LCS-based population
☒ Primary Care Visit-based population
☒ KPCO
	☒ KPHI
	☒ MCRI
☒ Penn
☐ LCS-based population
☒ Primary Care Visit-based population

E.	Specific Aims and Study Outcomes
Aim 1   Assess the distribution of five different SDOH indices/ measures in an LCS eligible population by geocode and health system
Hypothesis: There will be a significant difference in the distribution of each index (eg. lowest SES will not be the same in each index) by geocode and overall by health system.

i.	Define outcome(s):
1.	Difference in mean SES by overall health system  per index.
2.	Difference in mean SES in overall LCS-eligible population  per index. 

ii.	Define exposures of interest and covariates:
1.	Yost, SVI, NDI, census education and income
a.	Yost: The Yost Index, developed in 2001, has been adopted in the US for cancer surveillance and is based on the combination of two heavily weighted (household income, poverty) and five lightly weighted (rent, home value, employment, education and working class) indicator variables
b.	SVI: The CDC/ATSDR SVI uses 16 U.S. census variables to help local officials identify communities that may need support before, during, or after disasters. There are four themes that sums flags into an overall summary.
c.	NDI: The z-score version of the Neighborhood Deprivation Index (NDI) derived from prior eight variables using a principle components analysis, then standardized across all tracts within all US States served by all regions so that the mean value is 0 and standard deviation of all values is 1. Values of less than 0 represent tracts which are less deprived than average for KP served States, while values greater than 0 are more deprived than average.
d.	Education / Median Income:  Median household income per census tract. Percent of the census block with college education or more (education6-education8). Finding a single measure is difficult if not impossible to describe an individual’s complete social health thus SDOH is commonly captured using proxy measures, most often being education and/ or income.

Aim 2: Determine if one index is superior to others in lowering the variance in the data in predicting the likelihood of lung cancer screening
Hypothesis: The probability of lung cancer screening will differ by SES and the variability regarding this predicted probability will differ in certain indices more than others.

iii.	Define outcome(s):
1.	Likelihood of receipt of a baseline LDCT for LCS based on a measure of SDOH as the sole predictor.  
2.	AIC, BIC, generalized R2, max-rescaled R2, Somer D, Gamma, Tau A, and C-index  
iv.	Define exposures of interest and covariates:
1.	Index value divided into quintiles with a lower quintile, 1, corresponding to a lower SES and a higher quintile, 5, being higher SES.
Aim 3: Using the analysis performed by the Carroll et al from 2020 entitled “Real-world Clinical Implementation of Lung Cancer Screening—Evaluating Processes to Improve Screening Guidelines-Concordance” we will replicate a previous prediction model and cycle out the indices in each model to determine if the results from aim 3 also lower the variance and improve the predictive abilities of each model.
Hypothesis: The probability of lung cancer screening will differ by SES and the variability regarding this predicted probability will differ in certain indices more than others following a similar trend to aim 2.
i.	Define outcome(s):
1.	Likelihood of receipt of a baseline LDCT for LCS based on a measure of SDOH as the sole predictor.  
2.	AIC, BIC, generalized R2, max-rescaled R2, Somer D, Gamma, Tau A, and C-index  
ii.	Define exposures of interest and covariates:
1.	Index value divided into quintiles with a lower quintile, 1, corresponding to a lower SES and a higher quintile, 5, being higher SES.
2.	Age, sex, race, Charlson score


F.	Methods  for all Aims   .
Patients eligible for LCS using 2013 USPSTF criteria  as of January 1, 2014 were identified from the Population-based Research to Optimize the Screening Process (PROSPR)-Lung Common Data Model (CDM). Specifically, we identified patients aged 50 to 80 years who had at least a 20 pack-year smoking history and currently smoked or quit within the past 15 years. The PROSPR-Lung CDM is a standardized resource based on data derived from the EHR systems of Henry Ford Health, Kaiser Permanente Colorado (KPCO), Kaiser Permanente Hawaii, Marshfield Clinic Health System, and the University of Pennsylvania Health System. Patients with a diagnosis of lung cancer prior to January 1, 2014 and patients whose address was not able to be mapped to a geocode were excluded.

Each index will be calculated for all individuals based on census data for their address as of January 1, 2014at the tract level and mapped using R, and color coded to represent the index value represented. Indices are often calculated as a Z-score or a weighted propensity  score but can be translated into quintiles to improve interpratability with a 1 being the lowest level of SES and 5 being the highest level of SES. Mean values will be calculated for each index at the site and overall level then compared using the student T-test.
We will estimate the likelihood of lung cancer screening using five separate logistic regression models. Each of the five SDOH indices will be used separately as the independent variable for each model. Model fit will be assessed by comparing the AIC, BIC, generalized R2, max-rescaled R2, Somer D, Gamma, Tau A, and C-index. Lower AIC and BIC indicate a better model fit with the remaining measures indicating a improved predictive power. 

G.	Describe Tables that will summarize your analyses:
1)	Table 1: Demographic and clinical characteristics of individuals eligible for LCS as of January 1, 2014
2)	Table 2: Quintile Distribution of SDOH indices overall and by health system
3)	Table 3. Likelihood of lung cancer screening by SDOH index overall and by health system.

H.	Describe Figures that will accompany your analyses:
1)	Maps of each site with tract color code based upon quintile levels of each index.

I.	References

[1] Siegel RL, Giaquinto AN, Jemal A. Cancer statistics, 2024. CA: A Cancer Journal for Clinicians. Published online January 17, 2024. doi:https://doi.org/10.3322/caac.21820 

[2] Marshall RC, Tiglao SM, Thiel D. Updated USPSTF screening guidelines may reduce lung cancer deaths. J Fam Pract. 2021;70(7):347-349. doi:10.12788/jfp.0257 

[3] Ritzwoller DP, Meza R, Carroll NM, et al. Evaluation of Population-Level Changes Associated With the 2021 US Preventive Services Task Force Lung Cancer Screening Recommendations in Community-Based Health Care Systems. JAMA Netw Open. 2021;4(10):e2128176. Published 2021 Oct 1. doi:10.1001/jamanetworkopen.2021.28176 

[4] Sorscher S. Inadequate Uptake of USPSTF-Recommended Low Dose CT Lung Cancer Screening. J Prim Care Community Health. 2024;15:21501319241235011. doi:10.1177/21501319241235011 

[5] Williams PA, Zaidi SK, Sengupta R. AACR Cancer Disparities Progress Report 2022. Cancer Epidemiology, Biomarkers & Prevention. 2022;31(7):1249-1250. doi:https://doi.org/10.1158/1055-9965.epi-22-0542 

[6] Korn AR, Walsh‐Bailey C, Correa‐Mendez M, et al. Social determinants of health and US cancer screening interventions: A systematic review. CA: A Cancer Journal for Clinicians. 2023;73(5):461-479. doi:https://doi.org/10.3322/caac.21801 

[7] U.S. Department of Health and Human Services. Social determinants of health. Healthy People 2030. Published 2020. https://health.gov/healthypeople/priority-areas/social-determinants-health 

[8] Korn AR, Walsh-Bailey C, Pilar M, et al. Social determinants of health and cancer screening implementation and outcomes in the USA: a systematic review protocol. Syst Rev. 2022;11(1):117. Published 2022 Jun 8. doi:10.1186/s13643-022-01995-4 

[9] Akushevich I, Kravchenko J, Akushevich L, Ukraintseva S, Arbeev K, Yashin A. Cancer Risk and Behavioral Factors, Comorbidities, and Functional Status in the US Elderly Population. ISRN Oncol. 2011;2011:415790. doi:10.5402/2011/415790 

[10] Hinnant L, Hairgrove S, Kane H, et al. Social Determinants of Health: A Review of Publicly Available Indices [Internet]. Research Triangle Park (NC): RTI Press; 2022 Dec. Available from: https://www.ncbi.nlm.nih.gov/books/NBK592585/ doi: 10.3768/rtipress.2022.op.0081.2212
