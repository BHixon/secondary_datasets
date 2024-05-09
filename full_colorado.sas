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
	create table demog_pull as select distinct
		a.mrn,
		a.birth_date,
		a.race1,
		a.race2,
		a.race3,
		a.race4,
		a.race5,
		a.hispanic,
		a.sex_admin,
		b.enr_start,
		b.enr_end
			from vdw.demographics a
			inner join vdw.enrollment b on a.mrn = b.mrn
			where enr_end ge '01APR2024'd
			order by a.mrn;
quit;

data demog_pull2;
	set demog_pull;
		by mrn;
		if last.mrn then output;
run;

proc sql;
	create table census as select distinct
		a.*,
		b.geocode,
		b.geocode_boundary_year,
		b.zip,
		c.yost_state_quintile,
		c.ruca4a,
		c.educ_assocdeg,
		c.educ_bachdeg,
		c.educ_mastprofdeg,
		c.educ_doctdeg,
		d.medhousincome
			from demog_pull2 a
			left join vdw.census_location b on a.mrn = b.mrn
			left join full.census_detail c on b.geocode = c.geocode
			left join vdw.census_demog_acs d on b.geocode = d.geocode

					where (b.loc_start le '01APR2024'd and b.loc_end ge '01APR2024'd) and b.geocode_boundary_year = 2010 and b.geocode like '08%' and d.census_year = 2014
					order by a.mrn;
quit;

data census;
	set census;
		by mrn;
			if last.mrn then output;
run;


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
    var ndi_std;                                                          
    ranks ndi_rank;                                                      
run; 

proc sql;
	create table put_together as select distinct
		b.*,
		g.rpl_themes as svi_score,
		h.ndi_rank
			from census b 
			left join svi_data g on b.geocode = g.char_geo 
			left join ndi_out1 h on b.geocode = h.char_geo 
				order by mrn;
quit;

data sets.full_colorado_pop;
	set put_together;
		by mrn;
		if geocode = ' ' then delete;
		if svi_score lt 0.2 then svi_quintile = 5;
			else if svi_score ge 0.2 and svi_score lt 0.4 then svi_quintile = 4;
			else if svi_score ge 0.4 and svi_score lt 0.6 then svi_quintile = 3;
			else if svi_score ge 0.6 and svi_score lt 0.8 then svi_quintile = 2;
			else if svi_score ge 0.8 then svi_quintile = 1;
	if ndi_rank =0  then  NDI =1;
	else if ndi_rank=1 then NDI=2;
	else if ndi_rank=2 then NDI=3;
	else if ndi_rank=3 then NDI=4;
	else if ndi_rank=4 then NDI=5;
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
  drop hawpi amind mult multsum asian black white othrace unkrace;  
	
run;

data last_location;
	set sets.full_colorado_pop;
		by mrn;
		if geocode not =: '08' then delete;
			if last.mrn then output;
run;

proc sql;
	create table sets.geos_only_all as select distinct
		geocode,
		zip,
		svi_quintile,
		ndi,
		yost_state_quintile,
		assoc_college_plus,
		medhousincome,
		count(mrn) as count

			from sets.full_colorado_pop
			group by zip;
quit;
		

proc freq data = last_location;
	table zip/ out =test;
run;


proc freq data = last_location;
	table zip*svi_quintile/ out =svi_quintile;
run;

proc sql;
	create table zips_only as select
		a.zip,
		a.count,
		b.count as svi
		from test a
		left join svi_quintile b on a.zip = b.zip;
quit;
