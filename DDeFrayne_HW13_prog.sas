/* Program Name: DDeFrayne_HW13_prog											 */
/* Program Location: C:\Users\defraydz\Documents\School Work					 */
/* Creation Date: 4/8/2019 														 */
/* Author: Don DeFrayne 														 */
/* Purpose: Work with Indexes and Formats										 */
/* Inputs: mbbteams18, tourney18												 */
/* Outputs: DDeFrayne_HW14_output.pdf 											 */
/*********************************************************************************/

*Library definitions;
libname hwref 'C:\Users\defraydz\Documents\School Work\SAS\HWREF' access=readonly;
libname orion 'C:\Users\defraydz\Documents\School Work\SAS\Data';
libname myhw 'C:\Users\defraydz\Documents\School Work\SAS\MYHW';
filename hw "C:\Users\defraydz\Documents\School Work\SAS\MYHW\DDeFrayne_HW12_output.pdf";

*Open the pdf output;
ods pdf file=hw;

*Set options to remove page number and date, and list all index information to write to the log;
options nonumber nodate msglevel=i fullstimer;

*1 Convert the given code to SQL;
/* Given code:
data teams;
	keep Start Label FmtName;
	retain FmtName '$Seedy';
	set hwref.tourney18(rename=(School=Start
	Seed = Label));
run;
*/
proc sql;
CREATE TABLE teams AS
	SELECT 	'$Seedy' AS FmtName,
			put(Seed, 2.) AS Label, /*1c Use seed as label*/
			School AS Start /*1b Start comes from school*/
	FROM hwref.tourney18;
quit;

*1e Insert a new row of values to Teams;
proc sql;
	INSERT INTO Teams (Start, Label) VALUES ('Other', 'NA');
quit;

*1f Use the format procedure to create a user format from the data set in 1;
proc format cntlin=teams;
run;

*1g Write the contents to the output document;
proc format fmtlib;
run;



*Close the ods output;
ods pdf close;
