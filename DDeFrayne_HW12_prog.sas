/* Program Name: DDeFrayne_HW12_prog 											   */
/* Program Location: C:\Users\defraydz\Documents\School Work 					   */
/* Creation Date: 3/25/2019													 	   */
/* Author: Don DeFrayne															   */
/* Purpose: Work with SAS Macros												   */
/* Inputs: N/A 																	   */
/* Outputs: DDeFrayne_HW12_output.pdf 											   */
/***********************************************************************************/

*Library definitions;
libname hwref 'C:\Users\defraydz\Documents\School Work\SAS\HWREF' access=readonly;
libname orion 'C:\Users\defraydz\Documents\School Work\SAS\Data';
libname myhw 'C:\Users\defraydz\Documents\School Work\SAS\MYHW';
filename hw "C:\Users\defraydz\Documents\School Work\SAS\MYHW\DDeFrayne_HW12_output.pdf";

*Set options to write macro resolution, macro code, and macro execution info to the log;
options mlogic mprint symbolgen;

ods pdf file=hw;

*1 Reproduce the macro code from step 8, assignment 9;
%macro teamcall(fullname,playermin=1);
%if &playermin < 1 %then %let playermin=1; 
%if &playermin = 1 %then %let play = Player;
	%else %let play = Players;
proc sql;
title "Number of Players per Team in %substr(&fullname,%sysfunc(length(&fullname))-3) Data";
title2 "Teams with at Least &playermin &play in the Data Set";
SELECT Team, COUNT(Player)
	FROM &fullname
 	GROUP BY Team
 	HAVING COUNT(Player) >= &playermin;
quit;
title;
%mend teamcall;

*2 Call teamcall with ncaam2004 and playermin=-2;
%teamcall(hwref.ncaam2004, playermin=-2);

*2 Call teamcall with ncaam2003 and playermin=5;
%teamcall(hwref.ncaam2003, playermin=5);

*3 Create a new data set using mbbteams18 and tourney18;
proc sql;
CREATE TABLE data2018 AS
SELECT t18.seed, t18.school, t18.regional, t18.conference,
	m18.ppg, m18.avg_reb AS RPG,
	input(scan(t18.record,1),BEST12.)/m18.g format PERCENT10.1 AS win_pct label "Win %"
	FROM hwref.tourney18 t18
	JOIN hwref.mbbteams18 m18
		ON t18.school=m18.institution;
quit;



*4d Use a macro to process the below report once for each region;
%macro datareport(data, year);
title "&year NCAA Men's Basketball Championship"; *4c Set the title;

proc sort data=data2018 out=regionval(keep=regional) nodupkey; *4a Create a data set of regional values;
	by regional;
run;

data _null_; *4b Use a data step to create a macro variable for each region;
	set regionval end=final;
	call symputx('region'||left(_n_),regional);
	if final then call symputx('totalregion',_n_);
run;

%local i;
%do i=1 %to &totalregion; /*Loop for each region*/
	proc report data=&data nowd;
		where regional="&&region&i";
		columns ("Region = &&region&i" conference seed=nseed seed win_pct ppg rpg);
		define conference /group 'Conference';
		define nseed /N '# Teams';
		define seed /mean format=8.2 'Avg. Seed';
		define win_pct /mean 'Avg. Win %';
		define ppg /mean format=8.1 'Avg. Points';
		define rpg /mean format=8.1 'Avg. Rebounds';
	run;
%end;
%mend;

*5 Call the macro in 4 using data2018;
%datareport(data2018, 2018);

*6 Rewrite the macro in 4 using SQL;
%macro sqlreport(data, year);
title1 "&year NCAA Men's Basketball Championship";
proc sql number noprint; /*6a Create the table of regions*/
CREATE TABLE regions AS			
	SELECT distinct regional
		FROM &data;

SELECT COUNT(*) /*6b Create the macro variable for the total number of regions*/
	INTO :totalregion TRIMMED
	FROM regions;

SELECT regional /*6c Create the macro variables for each region*/
	INTO :region1 - :region&totalregion
	FROM regions;

reset print; /*Enable printing for the reports*/

%local i;
%do i=1 %to &totalregion; /*6e Loop so each region gets a printed data set*/
title2 "Team Statistics for the &&region&i Regional"; /*6d Team Report for each region*/
	SELECT conference AS Conference, 
			COUNT(regional) AS Teams,
			AVG(seed) label 'Avg. Seed' format 5.2,
			AVG(win_pct) label 'Avg. Win %' format PERCENT10.1,
			AVG(PPG) label 'Avg. Points' format 4.1,
			AVG(RPG) label 'Avg. Rebounds' format 4.1
		FROM &data
		WHERE regional="&&region&i"
		GROUP BY Conference;
%end;
quit;
%mend;

*6f Call the macro using data2018 and 2018;
%sqlreport(data2018, 2018);

*7 Create a macro to report rebounds per team above a given value - by region;
%macro rebounds(region, limit=35);

%let region = %sysfunc(propcase(&region)); /*7a Fix the casing of the input to proper*/

data subset; /*7b Create a data set that is a subset of data2018 based on the macro parameters*/
	set data2018;
	IF rpg GE &limit;
	IF regional = "&region";
run;

proc sql noprint; /*7c Save the number of rows in subset as a macro variable*/
SELECT COUNT(regional)
	INTO :nrows
	FROM subset;
quit;

proc sql number; /*7e Print the subset data set*/
title "Teams from the &region Region Averaging &limit or More Rebounds Per Game";
SELECT School label 'Team', Conference, rpg label 'Rebounds' format 4.1, Seed
	FROM subset
	ORDER BY rpg desc;
quit;

%if &nrows=0 %then %do; /*7d Print a statement if no teams are GE limit*/
	ods pdf text="No teams from Midwest regional average &limit or more rebounds per game.";
%end;
%mend;

*7f Call rebounds using midwest as the regional and 45 as the rebounding limit;
%rebounds(midwest, limit=45);

*7g Call rebounds using SOUTH as the regional;
%rebounds(SOUTH);

*Housecleaning;
title;
footnote;
ods pdf close;
