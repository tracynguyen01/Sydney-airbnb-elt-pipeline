CREATE schema if not exists bronze;

DROP table if exists bronze.airbnb_raw;
DROP table if exists bronze.census_g01_raw;
DROP table if exists bronze.lga_suburb_mapping_raw;
DROP TABLE if exists bronze.census_g02_raw;
drop table if exists bronze.lga_code_mapping_raw;

-- create table airbnb_raw in bronze schema (05_2020.csv) 
CREATE TABLE bronze.airbnb_raw (
	"LISTING_ID" text NULL,
	"SCRAPE_ID" text NULL,
	"SCRAPED_DATE" text NULL,
	"HOST_ID" text NULL,
	"HOST_NAME" text NULL,
	"HOST_SINCE" text NULL,
	"HOST_IS_SUPERHOST" text NULL,
	"HOST_NEIGHBOURHOOD" text NULL,
	"LISTING_NEIGHBOURHOOD" text NULL,
	"PROPERTY_TYPE" text NULL,
	"ROOM_TYPE" text NULL,
	"ACCOMMODATES" text NULL,
	"PRICE" text NULL,
	"HAS_AVAILABILITY" text NULL,
	"AVAILABILITY_30" text NULL,
	"NUMBER_OF_REVIEWS" text NULL,
	"REVIEW_SCORES_RATING" text NULL,
	"REVIEW_SCORES_ACCURACY" text NULL,
	"REVIEW_SCORES_CLEANLINESS" text NULL,
	"REVIEW_SCORES_CHECKIN" text NULL,
	"REVIEW_SCORES_COMMUNICATION" text NULL,
	"REVIEW_SCORES_VALUE" text NULL
);

-- create table census_g01_raw in bronze schema (2016Census_G01_NSW_LGA.csv)
	"LGA_CODE_2016" text NULL,
	"Tot_P_M" text NULL,
	"Tot_P_F" text NULL,
	"Tot_P_P" text NULL,
	"Age_0_4_yr_M" text NULL,
	"Age_0_4_yr_F" text NULL,
	"Age_0_4_yr_P" text NULL,
	"Age_5_14_yr_M" text NULL,
	"Age_5_14_yr_F" text NULL,
	"Age_5_14_yr_P" text NULL,
	"Age_15_19_yr_M" text NULL,
	"Age_15_19_yr_F" text NULL,
	"Age_15_19_yr_P" text NULL,
	"Age_20_24_yr_M" text NULL,
	"Age_20_24_yr_F" text NULL,
	"Age_20_24_yr_P" text NULL,
	"Age_25_34_yr_M" text NULL,
	"Age_25_34_yr_F" text NULL,
	"Age_25_34_yr_P" text NULL,
	"Age_35_44_yr_M" text NULL,
	"Age_35_44_yr_F" text NULL,
	"Age_35_44_yr_P" text NULL,
	"Age_45_54_yr_M" text NULL,
	"Age_45_54_yr_F" text NULL,
	"Age_45_54_yr_P" text NULL,
	"Age_55_64_yr_M" text NULL,
	"Age_55_64_yr_F" text NULL,
	"Age_55_64_yr_P" text NULL,
	"Age_65_74_yr_M" text NULL,
	"Age_65_74_yr_F" text NULL,
	"Age_65_74_yr_P" text NULL,
	"Age_75_84_yr_M" text NULL,
	"Age_75_84_yr_F" text NULL,
	"Age_75_84_yr_P" text NULL,
	"Age_85ov_M" text NULL,
	"Age_85ov_F" text NULL,
	"Age_85ov_P" text NULL,
	"Counted_Census_Night_home_M" text NULL,
	"Counted_Census_Night_home_F" text NULL,
	"Counted_Census_Night_home_P" text NULL,
	"Count_Census_Nt_Ewhere_Aust_M" text NULL,
	"Count_Census_Nt_Ewhere_Aust_F" text NULL,
	"Count_Census_Nt_Ewhere_Aust_P" text NULL,
	"Indigenous_psns_Aboriginal_M" text NULL,
	"Indigenous_psns_Aboriginal_F" text NULL,
	"Indigenous_psns_Aboriginal_P" text NULL,
	"Indig_psns_Torres_Strait_Is_M" text NULL,
	"Indig_psns_Torres_Strait_Is_F" text NULL,
	"Indig_psns_Torres_Strait_Is_P" text NULL,
	"Indig_Bth_Abor_Torres_St_Is_M" text NULL,
	"Indig_Bth_Abor_Torres_St_Is_F" text NULL,
	"Indig_Bth_Abor_Torres_St_Is_P" text NULL,
	"Indigenous_P_Tot_M" text NULL,
	"Indigenous_P_Tot_F" text NULL,
	"Indigenous_P_Tot_P" text NULL,
	"Birthplace_Australia_M" text NULL,
	"Birthplace_Australia_F" text NULL,
	"Birthplace_Australia_P" text NULL,
	"Birthplace_Elsewhere_M" text NULL,
	"Birthplace_Elsewhere_F" text NULL,
	"Birthplace_Elsewhere_P" text NULL,
	"Lang_spoken_home_Eng_only_M" text NULL,
	"Lang_spoken_home_Eng_only_F" text NULL,
	"Lang_spoken_home_Eng_only_P" text NULL,
	"Lang_spoken_home_Oth_Lang_M" text NULL,
	"Lang_spoken_home_Oth_Lang_F" text NULL,
	"Lang_spoken_home_Oth_Lang_P" text NULL,
	"Australian_citizen_M" text NULL,
	"Australian_citizen_F" text NULL,
	"Australian_citizen_P" text NULL,
	"Age_psns_att_educ_inst_0_4_M" text NULL,
	"Age_psns_att_educ_inst_0_4_F" text NULL,
	"Age_psns_att_educ_inst_0_4_P" text NULL,
	"Age_psns_att_educ_inst_5_14_M" text NULL,
	"Age_psns_att_educ_inst_5_14_F" text NULL,
	"Age_psns_att_educ_inst_5_14_P" text NULL,
	"Age_psns_att_edu_inst_15_19_M" text NULL,
	"Age_psns_att_edu_inst_15_19_F" text NULL,
	"Age_psns_att_edu_inst_15_19_P" text NULL,
	"Age_psns_att_edu_inst_20_24_M" text NULL,
	"Age_psns_att_edu_inst_20_24_F" text NULL,
	"Age_psns_att_edu_inst_20_24_P" text NULL,
	"Age_psns_att_edu_inst_25_ov_M" text NULL,
	"Age_psns_att_edu_inst_25_ov_F" text NULL,
	"Age_psns_att_edu_inst_25_ov_P" text NULL,
	"High_yr_schl_comp_Yr_12_eq_M" text NULL,
	"High_yr_schl_comp_Yr_12_eq_F" text NULL,
	"High_yr_schl_comp_Yr_12_eq_P" text NULL,
	"High_yr_schl_comp_Yr_11_eq_M" text NULL,
	"High_yr_schl_comp_Yr_11_eq_F" text NULL,
	"High_yr_schl_comp_Yr_11_eq_P" text NULL,
	"High_yr_schl_comp_Yr_10_eq_M" text NULL,
	"High_yr_schl_comp_Yr_10_eq_F" text NULL,
	"High_yr_schl_comp_Yr_10_eq_P" text NULL,
	"High_yr_schl_comp_Yr_9_eq_M" text NULL,
	"High_yr_schl_comp_Yr_9_eq_F" text NULL,
	"High_yr_schl_comp_Yr_9_eq_P" text NULL,
	"High_yr_schl_comp_Yr_8_belw_M" text NULL,
	"High_yr_schl_comp_Yr_8_belw_F" text NULL,
	"High_yr_schl_comp_Yr_8_belw_P" text NULL,
	"High_yr_schl_comp_D_n_g_sch_M" text NULL,
	"High_yr_schl_comp_D_n_g_sch_F" text NULL,
	"High_yr_schl_comp_D_n_g_sch_P" text NULL,
	"Count_psns_occ_priv_dwgs_M" text NULL,
	"Count_psns_occ_priv_dwgs_F" text NULL,
	"Count_psns_occ_priv_dwgs_P" text NULL,
	"Count_Persons_other_dwgs_M" text NULL,
	"Count_Persons_other_dwgs_F" text NULL,
	"Count_Persons_other_dwgs_P" text NULL
);

-- create table census_g02_raw in bronze schema (2016Census_G02_NSW_LGA.csv)
CREATE TABLE bronze.census_g02_raw (
	"LGA_CODE_2016" text NULL,
	"Median_age_persons" text NULL,
	"Median_mortgage_repay_monthly" text NULL,
	"Median_tot_prsnl_inc_weekly" text NULL,
	"Median_rent_weekly" text NULL,
	"Median_tot_fam_inc_weekly" text NULL,
	"Average_num_psns_per_bedroom" text NULL,
	"Median_tot_hhd_inc_weekly" text NULL,
	"Average_household_size" text NULL
);

-- create table lga_suburb_mapping_raw in bronze schema (NSW_LGA_SUBURB.csv)
CREATE TABLE bronze.lga_suburb_mapping_raw (
	"SUBURB_NAME" text NULL,
	"LGA_NAME" text NULL
);

-- create table lga_code_mapping_raw in bronze schema (NSW_LGA_CODE.csv)
CREATE TABLE bronze.lga_code_mapping_raw (
	"LGA_CODE" text NULL,
	"LGA_NAME" text NULL
);

select count(*) from bronze.airbnb_raw;






