/* Program Name: DDeFrayne_HW15_prog 											 */
/* Program Location: C:\Users\defraydz\Documents\School Work 					 */
/* Creation Date: 4/24/2019														 */
/* Author: Don DeFrayne															 */
/* Purpose: Experiment with efficiency and data combination methods				 */
/* Inputs: tourney18															 */
/* Outputs: DDeFrayne_HW15_output.pdf 											 */
/*********************************************************************************/

*Library definitions;
libname hwref 'C:\Users\defraydz\Documents\School Work\SAS\HWREF' access=readonly;
libname orion 'C:\Users\defraydz\Documents\School Work\SAS\Data';
libname myhw 'C:\Users\defraydz\Documents\School Work\SAS\MYHW'; /*1 Permanent personal data*/
filename hw "C:\Users\defraydz\Documents\School Work\SAS\MYHW\DDeFrayne_HW15_output.pdf";

*Open a pdf output destination;
ods pdf file=hw;

*1 Read tourney18 into memory;
SASFILE hwref.tourney18 LOAD;

*2 Print the descriptor portion of the SASHELP.ZIPCODE data set;
title 'Properties of SASHELP.ZIPCODE for Baseline';
proc contents data=sashelp.zipcode;
run;

*2a Proc means on all numeric variables in SASHELP.ZIPCODE;
title 'Statistics on Numeric Variables from SASHELP.ZIPCODE for Baseline';
proc means data=sashelp.zipcode;
	var zip x y state county MSA areacode gmtoffset;
run;

/*COMMENT OUT - EXPERIMENTATION RECORD
*Saved Space = 36274176 - 35024896 = 1249280 bytes;
NOTE: Compressing data set WORK.ZIPCODE decreased size by 83.18 percent.
      Compressed is 90 pages; un-compressed would require 535 pages.
*2b Copy SASHELP.ZIPCODE to the Work library;
data zipcode;
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;

*3c Experiment with compression;
data zipcode(COMPRESS=CHAR);
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;
data zipcode(COMPRESS=BINARY);
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;
data zipcode(COMPRESS=YES);
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;

data zipcode(COMPRESS=CHAR POINTOBS=NO);
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;

data zipcode(COMPRESS=CHAR POINTOBS=YES);
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;
*/

*2c Create the optimally compressed set;
data zipcode(COMPRESS=CHAR POINTOBS=NO);
	set sashelp.zipcode;
	length zip 5;
	length state 3;
	length county 3;
	length msa 4;
	length areacode 3;
	length gmtoffset 3;
run;

*2b Examine descriptor portion of zipcode to see the space that was saved;
title 'Properties of New ZIPCODE for Comparison';
proc contents data=zipcode;
run;

*2e Proc means on SASHELP.ZIPCODE again to ensure no statistics were altered;
title 'Statistics on Numeric Variables from ZIPCODE for Comparison';
proc means data=zipcode;
	var zip state county MSA areacode gmtoffset x y;
run;

*3a Create a copy of mbbteams18 in my myhw library and index it on Institution;
data myhw.mbbteams18(index=(Institution));
	set hwref.mbbteams18;
run;

*3b Combine myhw.mbbteams18 with hwref.tourney18;
data teamtourney18 (drop=AST TO);
	set hwref.tourney18 (rename=(School=Institution));
	set myhw.mbbteams18(keep=Institution FG_pct FG3_pct FT_pct PPG Avg_Reb AST TO) Key=Institution ;
	label Institution=Institution;
	ASTO_ratio = AST/TO;
	format ASTO_ratio 4.2;
run;

*3c Remove tourney18 from the memory load;
SASFILE hwref.tourney18 CLOSE;

*3d Change orientation to landscape and print teamtourney18;
options orientation=landscape;

title 'Data from Combined 2018 Basketball Data Sets';
proc print data=teamtourney18 label noobs;
run;

*Close the pdf output;
title;
options orientation=portrait;
ods pdf close;
