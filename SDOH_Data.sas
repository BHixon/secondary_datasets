/*************************************************************************************************
 Project           : PROSPR LOTUS

 Program name      : Impact of organizational processes lung cancer screening outcomes (REDCAP ID 64)

 Author            : hixonb

 Date created      : 2023/29/11

 Purpose           : Pull the datasets from the CDM (3.0) for K Rendle

 Revision History  : Version-1 

 Date        Author      Ref    Revision (Date in YYYYMMDD format)
 20232911    hixonb      1      20232911

************************************************************************************************/
*START EDIT SECTION
****************************************************************************************************************
****************************************************************************************************************;
*1)---------------------------------------------------------------------------------
 Please edit pathway below to point to your copy of StdVars.sas for your site.
 Example of pathway follows.;
*%INCLUDE "//aaa/bbb/ccc/StdVars.sas"; *<==EXAMPLE;

*KPCO has a pathway that excludes patients in the VDW who declined to participate in research. 
Be sure to only include the populations allowable.;

%include '\\kpco-ihr-1.ihr.or.kp.org\vdw production\stdvars_research.sas';


*2)---------------------------------------------------------------------------------
 Please edit pathway below to point to the root directory where you expanded the
 folders in the zip file. The folders Documents, Input, Local, SAS and QA
 appear under THE ROOT NAME YOU SUPPLIED.
 Note that the macro variable, root, does NOT end with a slash.
 Example of pathway follows. ;
*%let root=//xxx/yyy/zzz/the root name you supplied; *<==example(note no quotes or ending slash);

%let root=\\ihrfs.ihr.or.kp.org\PROSPR\ETL202201;

*Date this program was run, change for each pull;
%let run_date = 12MAR24;

****************************************************************************************************************
****************************************************************************************************************
END EDIT SECTION
****************************************************************************************************************
****************************************************************************************************************;
%include vdw_macs ;
%libname_format;

*library for cdm;
libname full "&root\CDM\data\full_cdm";

/* *library for saved datasets; */
libname sets "//kpco-ihr-1.ihr.or.kp.org/Analytic_Projects_2016/2018_Ritzwoller_PROSPR_EX/Study Projects/20240312_Hixon_SDOH/data";
/*  */
/* *library for saved QA; */
/* libname qa "&root/Study Projects/20232911_Rendle_OrgProcesses\qa"; */

proc sql;
	select count(distinct studyid) into: water1 from full.demographics;
quit;

proc sql;
	create table demog_pull as select distinct
		a.studyid,
		a.birth_date,
		floor ((intck('month',a.birth_date,'01JAN2014'd) - (day('01JAN2014'd) < day(a.birth_date))) / 12) as age14,
		floor ((intck('month',a.birth_date,'31DEC2019'd) - (day('31DEC2019'd) < day(a.birth_date))) / 12) as age19,
		a.race1,
		a.race2,
		a.race3,
		a.race4,
		a.race5,
		a.hispanic,
		a.gender,
		a.marital_status,
		a.motherlung_yn,
		a.fatherlung_yn,
		a.sisterlung_yn,
		a.brotherlung_yn,
		a.providingsite
			from full.demographics a
			where (calculated age14 between 50 and 80) or (calculated age19 between 50 and 80);
quit;

proc sql;
	select count(distinct studyid) into: water2 from demog_pull;
quit;

proc sql;
	create table smoking_data as select distinct
		a.*,
		b.contact_date,
		b.tobacco_use,
		b.tobacco_smoking_use,
		b.tobacco_packs_day,
		b.tobacco_use_years,
		b.tobacco_smoking_quit_date
			from demog_pull a 
				left join full.smoking_history b on a.studyid = b.studyid
				where tobacco_smoking_use in ('C', 'Q') and b.contact_date le '31DEC2019'd
					 order by a.studyid, b.contact_date;
;
quit;

proc sql;
	create table easy_smoke as select distinct
		a.*,
		c.ct_date,
		c.cpt_code,
		c.lung_rads,
		c.other_lung_rads,
		c.smoking_status,
		c.pack_years, /*pack_years_ 1='>= 30' 2='< 30' 3='Missing';*/
		c.time_since_quit,
		c.baseline_scan
		from smoking_data a
		left join full.screenings c on a.studyid = c.studyid
				where a.providingsite in ('KPCO', 'KPHI');

quit;

proc sql;
	create table additional_smoke as select distinct
		a.*,
		d.exam_date,
		d.smoking_status as acr_status,
		d.pack_years as acr_pack_yrs,
		d.years_since_quit as acr_years_quit,	
		c.ct_date,
		c.cpt_code,
		c.lung_rads,
		c.other_lung_rads,
		c.smoking_status,
		c.pack_years, /*pack_years_ 1='>= 30' 2='< 30' 3='Missing';*/
		c.time_since_quit,
		c.baseline_scan
		from smoking_data a
		left join full.screenings c on a.studyid = c.studyid
		left join full.acr d on a.studyid = d.studyid and c.ct_date = d.exam_date
				where a.providingsite in ('MCRF', 'HFHS', 'PENN');

quit;

data all_smoke;
	set easy_smoke additional_smoke;
run;

proc sort data = all_smoke;
	by studyid;
run;

data site_to_site_remap;	
	set all_smoke;
	format tobacco_smoking_quit_date2 date9.;
	by studyid;
		if tobacco_use_years ne '' then do;
					use_years = input(compress(strip(tobacco_use_years),"ABCDEFGHIJKLMNOPQRSTUVWXYZ/+-"), 8.);
    			end;
     				else use_years = .;
     	if tobacco_packs_day ne '' then
       				packs_day = input(compress(tobacco_packs_day,"ABCDEFGHIJKLMNOPQRSTUVWXYZ/+-"), 8.);
		if packs_day ne . and use_years ne . then social_packyrs = packs_day*use_years;
			/*('MCRF acr then screening then social', 'PENN acr then social', 'HFHS acr then social') */
		if providingsite ='MCRF' then do;
			if acr_years_quit ne . then tobacco_smoking_quit_date2 = INTNX('YEAR',ct_date,-acr_years_quit,'SAME');
			else if time_since_quit = '>=15 years' then tobacco_smoking_quit_date2 = INTNX('YEAR',ct_date,-16,'SAME');
			else if time_since_quit = '<15 years' then tobacco_smoking_quit_date2 = ct_date;
			else if time_since_quit = 'Missing' then tobacco_smoking_quit_date2 = tobacco_smoking_quit_date;
			else tobacco_smoking_quit_date2 =tobacco_smoking_quit_date;
			
			if acr_status = 1 then tobacco_smoking_use2 = 'C';
			else if acr_status = 2 then tobacco_smoking_use2 = 'Q';
			else if upcase(smoking_status) =: 'CU' then tobacco_smoking_use2 = 'C';
			else if upcase(smoking_status) =: 'FOR' then tobacco_smoking_use2 = 'Q';
			else tobacco_smoking_use2 =tobacco_smoking_use;
			
			/*Set pack years to 15 if less than 30 for screenings table*/
			if acr_pack_yrs ne . then pack_years2 = acr_pack_yrs;
			else if pack_years = 1 then pack_years2 = 30;
			else if pack_years = 2 then pack_years2 = 15;
			else if pack_years = 3 then pack_years2 = social_packyrs;
			else pack_years2 = social_packyrs;
		end;
		if providingsite ='PENN' then do;
			if acr_years_quit ne . then tobacco_smoking_quit_date2 = INTNX('YEAR',ct_date,-acr_years_quit,'SAME');
			else tobacco_smoking_quit_date2 =tobacco_smoking_quit_date;
			
			if acr_status = 1 then tobacco_smoking_use2 = 'C';
			else if acr_status = 2 then tobacco_smoking_use2 = 'Q';
			else tobacco_smoking_use2 =tobacco_smoking_use;
			
			if acr_pack_yrs ne . then pack_years2 = acr_pack_yrs;
			else pack_years2 = social_packyrs;
		end;
		if providingsite ='HFHS' then do;
			if acr_years_quit ne . then tobacco_smoking_quit_date2 = INTNX('YEAR',ct_date,-acr_years_quit,'SAME');
			else tobacco_smoking_quit_date2 =tobacco_smoking_quit_date;

			if acr_status = 1 then tobacco_smoking_use2 = 'C';
			else if acr_status = 2 then tobacco_smoking_use2 = 'Q';
			else tobacco_smoking_use2 =tobacco_smoking_use;
			
			if acr_pack_yrs ne . then pack_years2 = acr_pack_yrs;
			else pack_years2 = social_packyrs;
		end;	
		if providingsite ='KPCO' then do;
		
			tobacco_smoking_quit_date2 =tobacco_smoking_quit_date;
			
			tobacco_smoking_use2 =tobacco_smoking_use;
			
			pack_years2 = social_packyrs;
		end;
		if providingsite ='KPHI' then do;
			tobacco_smoking_quit_date2 =tobacco_smoking_quit_date;
			
			tobacco_smoking_use2 =tobacco_smoking_use;
			
			pack_years2 = social_packyrs;
		end;
		
;
run;

proc sql;
	create table quitters as select 
	*,
	min(contact_date) as min_quit format=date9.
	from site_to_site_remap
	where tobacco_smoking_use2 = 'Q'
	group by studyid
	order by studyid, contact_date;
quit;
data quitters;
	set quitters;
		by studyid;
			if last.studyid then output;
run;
	
proc sql;
	create table inclusion_start as select 	
	a.* 		
	, b.min_quit,
	case 
			when a.tobacco_smoking_use2 = 'Q' and a.tobacco_smoking_quit_date2 = . and (a.ct_date< max(a.tobacco_smoking_quit_date2) or max(a.tobacco_smoking_quit_date2) = .) then a.ct_date
			when a.tobacco_smoking_use2 = 'Q' and a.tobacco_smoking_quit_date2 = . and a.ct_date ge max(a.tobacco_smoking_quit_date2) then max(a.tobacco_smoking_quit_date2)
			when a.tobacco_smoking_use2 = 'Q' and a.tobacco_smoking_quit_date2 = . then a.contact_date		
			else a.tobacco_smoking_quit_date2
		end as max_quit format=date9.,
	case when 
		a.tobacco_smoking_use2 in ('Q', 'C') then a.tobacco_smoking_use2
		when a.tobacco_smoking_use2 in ('U','N') and a.tobacco_smoking_quit_date2 ne . then 'Q'
		when a.tobacco_smoking_use2 in ('N', 'U') and (a.tobacco_smoking_quit_date2 = . and a.pack_years2 ne .) then 'C'
		else a.tobacco_smoking_use2
	end as smoking_use_revised
		from site_to_site_remap a
		left join quitters b on a.studyid = b.studyid
			group by a.studyid;
quit;

data inclusion_start2;
	set inclusion_start;
		by studyid ;
     			if  max_quit  ne . and smoking_use_revised = 'Q' then
     				quit_years = floor((intck('month',max_quit, '31DEC2019'd) - (day('31DEC2019'd) < day(max_quit))) / 12);
     			else if	max_quit  = . and smoking_use_revised = 'Q' and min_quit ne . then
     				quit_years = floor((intck('month',min_quit, '31DEC2019'd) - (day('31DEC2019'd) < day(min_quit))) / 12);
     		else if smoking_use_revised = 'Q' then
     				quit_years = floor((intck('month',contact_date, '31DEC2019'd) - (day('31DEC2019'd) < day(contact_date))) / 12);
run;


proc sql;
title 'Total LOTUS population';
	select count(distinct studyid), providingsite from full.demographics
		group by providingsite;
quit;

proc sql;
title 'Total Screening population';
	select count(distinct studyid), providingsite from full.screenings
		group by providingsite;
quit;

proc sql;
select count(distinct studyid), providingsite from inclusion_start
where baseline_scan =1
group by providingsite;

quit;

/*counts distinct studyid*/

proc sql;
    title 'Adults With Baseline CT between 2014 and 2019';
	select count(distinct studyid) 
    	from inclusion_start
    	group by providingsite;
quit;


proc sql;
	create table inclusion_start3 as
		select *
	from inclusion_start2
			group by studyid
			order by studyid, contact_date;
quit;


data inclusion_start4;
	set inclusion_start3;
		by studyid;
			if last.studyid then output;
run;
	
/*Strict Criteria*/

data sets.inclusion_strict nope;
	set inclusion_start4;

     			if quit_years lt 0 then quit_years = .;
*calculate ic1 = age;
     			if (age19 >= 50 and age19 <= 80) or (age14 >= 50 and age14 <= 80)  then ic1 = 1; 
     			else ic1 = 0; 
*ic2 - Current smoker or Quit in the last 15;
     			if smoking_use_revised = 'C' then ic2 = 1;
     			else if smoking_use_revised = 'Q' and quit_years le 15 then ic2 =1;
				else ic2 =0;
*ic3 - pack years greater than 30;
    			if pack_years2 >= 30 then ic3 = 1;
      			else ic3 = 0;
*LCS ELIGIBLE - IF YOU MEET ALL THREE INCLUSION CRITERIA YOU ELIGIBLE;
				if ic3 = 1 and ic2 = 1 and ic1 = 1 then LCS_ELG = 'Y'; 
				else LCS_ELG = 'N';

if lcs_elg='Y' then output sets.inclusion_strict;
else output nope;
run;

proc sql;
title 'Strict LCS Eligible only population';
	select count(distinct studyid), providingsite
	from sets.inclusion_strict
    	group by providingsite;
quit;
title;

proc sql;
title 'Strict LCS Eligible only population';
	select count(distinct studyid) into:water3
	from sets.inclusion_strict;
quit;
title;

/*****************************************************************
EXCLUSION
*****************************************************************/
/*
Exclude-
Never Smokers
Unknown smokers status
lung rads = 0 or missing baseline lungrads
no lcs only patients 
Anyone with fewer than 12 months of enrollment following ldct when they have had no lung cancer (allow 90 day gaps)
Anyone in primary care who doesnt not have any screens or pc visits in a two year period and have not had lung cancer
Anyone who's baseline ldct was not within an engagement period (allow 90 day gaps)
No lung cancer and death within 12 months of baseline
*/

%let strict_loose = sets.inclusion_strict;

data last_record;
	set &strict_loose;
	by studyid;
		if last.studyid then output;
run;

/*Filtering allowable lung rads*/
data exclude_start;
	set last_record;
run;

proc sql;
select count(distinct studyid), providingsite from exclude_start
group by providingsite;

quit;
title;
/* Bringing in cancer data*/

%seer_site_recode(inds=full.cancercase, outds=vtr);
data lungca; set vtr;
  where site_recode = 22030 and behav in ('2','3') and dxdate < '01jan2021'd ;  
run;

proc sort data=lungca ;
  by studyid dxdate ;
run;

data lungca2; 
	set lungca;
		by studyid dxdate ;
			if first.studyid ;
		lungca = 1;
run;

proc sql;
	create table exclude_start2a as select 
		a.*,
		b.icdosite,
		b.dxdate,
		b.lungca
			from exclude_start a
			left join lungca2 b on a.studyid = b.studyid;
quit; 

data exclude_start2;
	set exclude_start2a;
		by studyid;
			if lungca = 1 and dxdate lt '01JAN2014'd then delete;
run;

proc sql;
title 'Strict LCS Eligible only population with no prior history of lung cancer';
	select count(distinct studyid) into:water4
	from exclude_start2;
quit;
title;

/* Bringing in engagement information with no ins_lcs people*/

proc sql;
	create table exclude_start3_noinslcs as select distinct
		a.studyid,
		a.birth_date,
		a.age14,
		a.age19,
		a.race1,
		a.race2,
		a.race3,
		a.race4,
		a.race5,
		a.hispanic,
		a.gender,
		a.marital_status,
		a.motherlung_yn,
		a.fatherlung_yn,
		a.sisterlung_yn,
		a.brotherlung_yn,
		a.ct_date as first_ct_date,
		a.lung_rads as first_rads,
		a.quit_years,
		a.smoking_use_revised,
		a.pack_years2,
		a.icdosite,
		a.dxdate,
		a.lungca,
		a.providingsite,
		b.eng_start,
		b.eng_end,
		b.ins_lcs,
		b.ins_pc
			from exclude_start2 a 
			left join full.engagement b on a.studyid = b.studyid 
				where ('01JAN2014'd between b.eng_start and b.eng_end) or ('31DEC2019'd between b.eng_start and b.eng_end);
quit;

		
data exclude_start3_lcs_free;
	set exclude_start3_noinslcs;
		if ins_lcs = 'Y' then delete;
run;

proc sql;
title 'Strict LCS Eligible only population with sufficient engagement';
	select count(distinct studyid) into:water5
	from exclude_start3_lcs_free;
quit;
title;

proc sql;
	create table exclude_start3 as select distinct
		a.studyid,
		a.birth_date,
		a.age14,
		a.age19,
		a.race1,
		a.race2,
		a.race3,
		a.race4,
		a.race5,
		a.hispanic,
		a.gender,
		a.marital_status,
		a.motherlung_yn,
		a.fatherlung_yn,
		a.sisterlung_yn,
		a.brotherlung_yn,
		a.first_ct_date,
		a.first_rads,
		a.quit_years,
		a.smoking_use_revised,
		a.pack_years2,
		a.icdosite,
		a.dxdate,
		a.lungca,
		a.providingsite,
		b.eng_start,
		b.eng_end,
		b.ins_pc,
		c.ct_date
			from exclude_start3_lcs_free a
			left join full.engagement b on a.studyid = b.studyid
			left join full.screenings c on a.studyid = c.studyid;
quit;


proc sql;
select count(distinct studyid), providingsite from exclude_start3
group by providingsite;

quit;
title;


*Collapes periods so there are no gaps smoothed out
This dataset was used to calculate the number of years enr in raw number of days
It also calculated the maximum possible enrollment duration;

%COLLAPSEPERIODS(LIB=work,
                 DSET = exclude_start3,
                 RECSTART=eng_start,
                 RECEND = eng_end,
                 PERSONID = studyid,
                 DAYSTOL = 90,
                 OUTSET = exclude_start4_eng);          

proc sort data = exclude_start4_eng;
	by studyid eng_end;
run;

proc sql;
	create table exclude_start4 as select distinct
		a.studyid,
		a.birth_date,
		a.age14,
		a.age19,
		a.race1,
		a.race2,
		a.race3,
		a.race4,
		a.race5,
		a.hispanic,
		a.gender,
		a.marital_status,
		a.motherlung_yn,
		a.fatherlung_yn,
		a.sisterlung_yn,
		a.brotherlung_yn,
		a.first_ct_date,
		a.first_rads,
		a.quit_years,
		a.smoking_use_revised,
		a.pack_years2,
		a.icdosite,
		a.dxdate,
		a.lungca,
		b.ins_pc,
		a.providingsite
			from exclude_start3 a 
			left join full.engagement b on a.studyid = b.studyid;
quit;

proc sql;
	create table exclude_start7 as select
		a.*,
		b.deathdt,
		b.confidence,
		c.cod
			from exclude_start4 a 
			left join full.death b on a.studyid = b.studyid and confidence in ('E','F')
			left join full.cod c on b.studyid = c.studyid and cod like 'C34%';
quit;

proc sql;
	create table sets.sdoh_set as select distinct
		studyid,
		birth_date,
		age14,
		age19,
		race1,
		race2,
		race3,
		race4,
		race5,
		hispanic,
		gender,
		marital_status,
		motherlung_yn,
		fatherlung_yn,
		sisterlung_yn,
		brotherlung_yn,
		first_ct_date,
		first_rads,
		quit_years,
		smoking_use_revised,
		pack_years2,
		icdosite,
		dxdate,
		lungca,
		deathdt,
		providingsite
			from exclude_start7
			order by studyid;
quit;

proc sql;
	create table demographics as select distinct
		a.studyid,
		a.birth_date,
		a.age14,
		a.age19,
		a.race1,
		a.race2,
		a.race3,
		a.race4,
		a.race5,
		a.hispanic,
		a.gender,
		a.marital_status,
		a.motherlung_yn,
		a.fatherlung_yn,
		a.sisterlung_yn,
		a.brotherlung_yn,
		a.quit_years,
		a.smoking_use_revised,
		a.pack_years2 ,
		a.providingsite
			from sets.sdoh_set a;
quit;

proc sql;
	create table census as select distinct
		a.studyid,
		b.geocode,
		c.yost_overall_quintile,
		c.educ_somecoll,
		c.educ_assocdeg,
		c.educ_bachdeg,
		c.educ_mastprofdeg,
		c.educ_doctdeg,
		c.ruca4a,
		d.medhousincome
			from sets.sdoh_set a
			left join full.census_location b on a.studyid = b.studyid
			left join full.census_detail c on b.geocode = c.geocode
			left join vdw.census_demog_acs d on b.geocode = d.geocode

					where (b.loc_start le '31DEC2019'd and b.loc_end ge '01JAN2014'd)
					order by studyid;
quit;

data census;
	set census;
		by studyid;
			if last.studyid then output;
run;

proc sql;
	create table bmi as select distinct
		a.studyid,
		b.bmi,
		b.measure_date
			from sets.sdoh_set a
			left join full.bmi b on a.studyid = b.studyid 
				where measure_date ge '01JAN2014'd 
				order by studyid, measure_date;
quit;

data bmi;
	set bmi;
		by studyid;
			if last.studyid then output;
run;

proc sql;
	create table charlson as select distinct
		a.studyid,
		b.charlson_score
			from sets.sdoh_set a
			left join full.comorbidity b on a.studyid = b.studyid 
				where year between 2014 and 2019
				order by studyid, year;
quit;

data charlson;
	set charlson;
		by studyid;
			if first.studyid then output;
run;

proc sql;
	create table screening as select distinct
		studyid,
		first_ct_date,
		first_rads
		from sets.sdoh_set;
quit;

FILENAME REFFILE '//kpco-ihr-1.ihr.or.kp.org/Analytic_Projects_2016/2018_Ritzwoller_PROSPR_EX/Study Projects/20240312_Hixon_SDOH/data/indices/SVI_2014_US.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.SVI;
	GETNAMES=YES;
RUN;

FILENAME REFFILE '//kpco-ihr-1.ihr.or.kp.org/Analytic_Projects_2016/2018_Ritzwoller_PROSPR_EX/Study Projects/20240312_Hixon_SDOH/data/indices/NDI_USA_2014.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=WORK.ndi;
	GETNAMES=YES;
RUN;


data svi_data;
	set svi;
		char_geo=put(FIPS, z11.);
		if st_abbr = 'AL' then svi_fips = cats('0',FIPS);
			else if st_abbr = 'AZ' then svi_fips = cats('0',FIPS);
			else if st_abbr = 'AK' then svi_fips = cats('0',FIPS);
			else if st_abbr = 'AR' then svi_fips = cats('0',FIPS);
			else if st_abbr = 'CA' then svi_fips = cats('0',FIPS);
			else if st_abbr = 'CO' then svi_fips = cats('0',FIPS);
			else if st_abbr = 'CT' then svi_fips = cats('0',FIPS);
			else svi_fips = cats(' ',FIPS);			
run;

data ndi_data;
	set ndi;
		char_geo=put(geoid, z11.);
run;	

proc rank data=ndi_data out=ndi_out1 groups=5;                               
    var ndi_raw;                                                          
    ranks ndi_rank;                                                      
run; 

proc sql;
	create table put_together as select distinct
		a.*,
		b.geocode,
		b.yost_overall_quintile,
		b.educ_somecoll,
		b.educ_assocdeg,
		b.educ_bachdeg,
		b.educ_mastprofdeg,
		b.educ_doctdeg,
		b.ruca4a,
		b.medhousincome,
		c.bmi,
		d.first_rads,
		d.first_ct_Date,
		f.charlson_score,
		g.rpl_themes as svi_score,
		h.ndi_rank
			from demographics a 
			left join census b on a.studyid = b.studyid
			left join bmi c on a.studyid = c.studyid
			left join screening d  on a.studyid = d.studyid
			left join charlson f on a.studyid = f.studyid
			left join svi_data g on b.geocode = g.char_geo 
			left join ndi_out1 h on b.geocode = h.char_geo 
				order by studyid;
quit;

data sets.final_set;
	set put_together;
		by studyid;
		if yost_overall_quintile = 5 then yost = 1; /*High SES Status*/
			else if yost_overall_quintile = 4 then yost = 2;
			else if yost_overall_quintile = 3 then yost = 3;
			else if yost_overall_quintile = 2 then yost = 4;
			else if yost_overall_quintile = 1 then yost = 5; /*Low SES Status*/
		if svi_score lt 0.2 then svi = 1; /*High SES Status*/
			else if svi_score ge 0.2 and svi_score lt 0.4 then svi = 2;
			else if svi_score ge 0.4 and svi_score lt 0.6 then svi = 3;
			else if svi_score ge 0.6 and svi_score lt 0.8 then svi = 4;
			else if svi_score ge 0.8 then svi = 5;/*Low SES Status*/
		if ndi_rank =0  then  ndi =1; /*High SES Status*/
			else if ndi_rank=1 then ndi=2;
			else if ndi_rank=2 then ndi=3;
			else if ndi_rank=3 then ndi=4;
			else if ndi_rank=4 then ndi=5;/*Low SES Status*/
		if age14 ge 50 and age14 le 80 then age = age14;
			else if age19 ge 50 and age19 le 80 then age = age19;
		  asian=0; black=0; hawpi=0; amind=0; white=0; unkrace=0; mult=0; Othrace=0;
		  Asian = whichc('AS', of race:)>0;
		  Black = whichc('BA', of race:)>0;
		  HawPI = whichc('HP', of race:)>0;
		  AmInd = whichc('IN', of race:)>0;
		  White = whichc('WH', of race:)>0;
		  Mult  = whichc('MU', of race:)>0;
		  Othrace=whichc('OT', of race:)>0;
		  if race1='UN' and race2='UN' and race3='UN' and race4='UN' and race5='UN' then unkrace=1;
 		 multsum=sum(asian,black,hawpi,amind,white,othrace);
 		 if hawpi=1 then newrace='HawPI';
  else if amind=1 then newrace='AmInd';
  else if Hispanic = 'Y' then newrace ='Hisp';
  else if mult=1 then newrace='Mult';
  else if multsum > 1 then newrace='Mult';
  else if asian=1 then newrace='Asian';
  else if black=1 then newrace='Black';
  else if white=1 then newrace='White';
  else if othrace=1 then newrace='Other';
  else if unkrace=1 then newrace='Unk';
  else newrace='???'; 
  
  
  assoc_college_plus= educ_assocdeg + educ_bachdeg + educ_mastprofdeg + educ_doctdeg;
  
  if medhousincome le 28000 then income =5;
if medhousincome gt 28000 and medhousincome le 56000 then income = 4;
if medhousincome gt 56000 and medhousincome le 83000 then income = 3;
if medhousincome gt 83000 and medhousincome le 111000 then income = 2;
if medhousincome gt 111000 then income = 1;

if assoc_college_plus le 20 then education =5;
if assoc_college_plus gt 20 and assoc_college_plus le 40 then education = 4;
if assoc_college_plus gt 40 and assoc_college_plus le 60 then education = 3;
if assoc_college_plus gt 60 and assoc_college_plus le 80 then education = 2;
if assoc_college_plus gt 80 then education = 1;

  if geocode = ' ' or NDI = . or svi = . or svi = -999 or medhousincome = . or assoc_college_plus = . or yost_overall_quintile = . then delete;
  drop hawpi amind mult multsum asian black white othrace unkrace;  
	
run;

proc sql;
title 'Strict LCS Eligible only population with sufficient engagement and data for analysis';
	select count(distinct studyid) into:water6
	from  sets.final_set;
quit;
title;

data water1;
  row="Full Lotus Population";
    count=&water1;
    removed = 0;
run;

data water2;
  row="Number of People With Proper Age Distribution";
    count=&water2;
    removed = &water1-&water2;
run;

data water3;
  row="Population who meets criteria (Full LCS)";
    count=&water3;
    removed = &water2-&water3;
run;

data water4;
  row="Strict LCS Eligible only population with no prior history of lung cancer";
    count=&water4;
   	removed = &water3-&water4;
run;

data water5;
  row="Strict LCS Eligible only population no history of lung cancer and with sufficient engagement";
    count=&water5;
    removed = &water4-&water5;
run;

data water6;
  row="Full Population with Sufficient Data for Analysis";
    count=&water6;
    removed = &water5-&water6;
run;

/* data water7; */
/*   row="Removed Those With No Screens or PC Visits Within 2 Year Period"; */
/*     count=&water7; */
/*     removed = &water6-&water7; */
/* run; */
/*  */
/* data water8; */
/*   row="Removed Those Who Died Within 12 Months of Baseline Who Did Not Have Lung Cancer"; */
/*     count=&water8; */
/*     removed = &water7-&water8; */
/* run; */

/*Final waterfall table*/
data waterfall_sdoh_set;
  length row $110.;
    set water1-water6;
      label row="Inclusion Criteria";
      label count="Count of Distinct Patients";
      label removed="Count of Distinct Patients Removed at Each Step";
run;

proc print data=waterfall_sdoh_set noobs label;
	title "Cancer Yield Cohort Waterfall";
run;
title;

options errors=0 formchar="|----|+|---+=|-/\<>*" mprint nodate nofmterr
  nomlogic nonumber noquotelenmax nosymbolgen
;
/*formats for aggregation*/
proc format;

   value agefmt
	50 - 54 = '50-54 yrs old'
	55 - 59 = '55-59 yrs old'
	60 - 64 = '60-64 yrs old'
	65 - 69 = '65-69 yrs old'
	70 - high = '70+'
;

  value $ gender
    'F' = 'Female'
    'M' = 'Male'
	other = 'Other/Unknown'
  ;

  value $ race
  	'WH'='Non-Hispanic White'
	'BA'='Non-Hispanic Black'
	'IN'='Native American/ Alaskan Native'
	'HP'='Hawaiian/ Pacific Islander'
	'AS'='Non-Hispanic Asian'
	'HS'='Hispanic'
	'UN'='Unknown'
	other='Multiple/Other'
  ;

  value $ raceeth
  	'WH'='White'
	'BA'='Black'
	'IN'='Native American/ Alaskan Native'
	'HP'='Hawaiian/ Pacific Islander'
	'AS'='Asian'
	'UN'='Unknown'
	other='Multiple/Other'
  ;
  
  value $ hisp
  	'Y'='Hispanic'
	other='Non-Hispanic/Unknown'
;

  value copd  
	. = 'No COPD'
    1 = 'COPD Diagnosis'
;

  value bmi  
	low - 24.99 = 'BMI <25'
    25 - 29.99 = 'BMI 25-29.99'
    30 - high = 'BMI >30'
;

  value $ evernever  
	'C' = 'Current Smoker'
    'Q' = 'Former Smoker'
;

  value pack_years  
	low-39.99 = 'Less than 40 Pack Years'
    40- high = 'More than 40 Pack Years'
;

  value quit  
	low-4 = 'Less than 5 Years Quit'
    5-10 = '5-10 Years Quit'
    10.01 - 15 = '10-15 Years Quit'
    15.01 - high = 'More than 15 years'
;

	value edu
	.="Missing Geocode"
	low-<20="<20% of Adults in Census Tract"
	20-<40="20-39.99% of Adults"
	40-<60="40-59.99% of Adults"
	60-<80="60-79.99% of Adults"
	80-high="80%+ of Adults"
;

	value income
	.="Missing Geocode"
	low-28000="<= $28,000 (approx. US poverty threshold for family of 4 in 2019)"
	28001-56000="$28,001-$56,000"
	56001-83000="$56,001-$83,000"
	83001-111000="$83,001-$111,000"
	111001-high=">$111,000"
;

  value $ marry
'Common Law' = 'Domestic Partner'
'Domestic Partner'='Domestic Partner'
'Partner'='Domestic Partner'
'Partner in a Civil Union'='Domestic Partner'
'Registered Domestic Partner'='Domestic Partner'
'Significant Other'='Domestic Partner'

'Divorced'='Divorced'
'Separated'='Divorced'
'Separated/Parted'='Divorced'
'Legally Separated'='Divorced'

'Married'='Married'

'Single' = 'Single'
'Single/Never Married' = 'Single'

'Other' = 'Other'
' ' = 'Unknown'
'Unknown' = 'Unknown'
'Unreported' ='Unknown'

'Widowed' = 'Widowed'
;

value yost
. = "Missing"
1 = "Yost 1: SES High"
2 = "Yost 2: SES 2"
3 = "Yost 3: SES 3"
4 = "Yost 4: SES 4"
5 = "Yost 5: SES Low"
;

value ndi
. = "Missing"
1 = "NDI 1: SES High"
2 = "NDI 2: SES 2"
3 = "NDI 3: SES 3"
4 = "NDI 4: SES 4"
5 = "NDI 5: SES Low"
;


value svi
. = "Missing"
1 = "SVI 1: SES High"
2 = "SVI 2: SES 2"
3 = "SVI 3: SES 3"
4 = "SVI 4: SES 4"
5 = "SVI 5: SES Low"
;

value charlson
. = "Missing"
0 = "Charlson 0"
1 = "Charlson 1"
2 = "Charlson 2"
3 - high = "Charlson 3+"
;

run;
quit;

proc tabulate data= sets.final_set missing /*format=mask.*/;
  title 'Cancer Yield Descriptive';
  *rows;
  class age gender newrace hispanic bmi first_rads bmi  pack_years2 smoking_use_revised quit_years marital_status
  yost svi charlson_score assoc_college_plus providingsite medhousincome ndi
/ order=internal
  ;
  *columns;
  format age agefmt. gender $gender.  bmi bmi.  pack_years2 pack_years. smoking_use_revised $evernever. medhousincome income.
  quit_years quit. yost yost. ndi ndi. svi svi. charlson_score charlson. assoc_college_plus edu. marital_status $marry.
 
  ;
  classlev age gender newrace first_rads bmi pack_years2 smoking_use_revised quit_years ndi marital_status
  yost svi charlson_score providingsite assoc_college_plus medhousincome
/ style=data[indent=2]
  ;
  table all
		age="Age as of Cohort Entry."
		gender='Sex'
		newrace='Race'
		bmi = 'Body Mass Index'
		pack_years2 = 'Pack Years'
		smoking_use_revised = 'Current or Former Smoker'
		quit_years = 'Years Since Quit'
		marital_status = 'Marital Status'
		charlson_score = 'Charlson Score'
		yost = 'Yost Index'
		svi = 'SVI Index'
		ndi = 'NDI Index'
		assoc_college_plus = 'Received a Degree (Assoc. or Higher)'
		medhousincome = 'Median Household Income'
/* 		providingsite = 'Site' */
		, (n  colpctn='PERCENT OF TOTAL')
    / misstext="."
  ;

run;


data analytic_set;
	set sets.final_set;
		if first_ct_date ne . then ctyn = "1";
		else ctyn = "0";
		if gender = 'M' then sex = 1;
		else sex = 0;

run;

proc means data = analytic_set;

	var yost svi education income ndi;
quit;

proc sort data = analytic_set;
	by providingsite;
run;
proc means data = analytic_set;
by providingsite;
	var yost svi education income ndi;
quit;

ods graphics on;
proc logistic data=analytic_set;
title 'Crude Yost';
class ctyn(ref="0") yost (ref="5")/ param=glm;
   model ctyn=yost / rsq lackfit;
      score fitstat;
run;
ods graphics on;
proc logistic data=analytic_set;
title 'Replication Yost';
class ctyn(ref="0") newrace yost (ref="5")/ param=glm;
   model ctyn=yost age sex newrace charlson_score/ rsq lackfit;
      score fitstat;
run;

ods graphics on;
proc logistic data=analytic_set;
title 'Crude NDI';
class ctyn(ref="0") ndi (ref="5")/ param=glm;
   model ctyn=ndi/ rsq lackfit;
         score fitstat;
run;
ods graphics on;
proc logistic data=analytic_set;
title 'Replication NDI';
class ctyn(ref="0") newrace ndi (ref="5")/ param=glm;
   model ctyn=ndi age sex newrace charlson_score/ rsq lackfit;
         score fitstat;
run;

ods graphics on;
proc logistic data=analytic_set;
title 'Crude SVI';
class ctyn(ref="0") svi (ref="5")/ param=glm;
   model ctyn=svi/ rsq lackfit;
            score fitstat;
run;
ods graphics on;
proc logistic data=analytic_set;
title 'Replication SVI';
class ctyn(ref="0") newrace svi (ref="5")/ param=glm;
   model ctyn=svi age sex newrace charlson_score/ rsq lackfit;
            score fitstat;
run;

ods graphics on;
proc logistic data=analytic_set;
title 'Crude Education';
class ctyn(ref="0") education (ref="5")/ param=glm;
   model ctyn=education/ rsq lackfit;
               score fitstat;
run;
ods graphics on;
proc logistic data=analytic_set;
title 'Replication Education';
class ctyn(ref="0") newrace education (ref="5")/ param=glm;
   model ctyn=education age sex newrace charlson_score/ rsq lackfit;
   score fitstat;
run;

ods graphics on;
proc logistic data=analytic_set;
title 'Crude Median Income';
class ctyn(ref="0") income (ref="5")/ param=glm;
   model ctyn=income/ rsq lackfit;
      score fitstat;
run;
ods graphics on;
proc logistic data=analytic_set;
title 'Replication Income';
class ctyn(ref="0") newrace income (ref="5")/ param=glm;
   model ctyn=income age sex newrace charlson_score/ rsq lackfit;
      score fitstat;
run;