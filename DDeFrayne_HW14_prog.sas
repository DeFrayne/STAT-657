/* Program Name: DDeFrayne_HW14_prog 											 */
/* Program Location: C:\Users\defraydz\Documents\School Work 					 */
/* Creation Date: 4/12/2019														 */
/* Author: Don DeFrayne															 */
/* Purpose: Work with Functions													 */
/* Inputs: tourney18															 */
/* Outputs: DDeFrayne_HW14_output.pdf 											 */
/*********************************************************************************/

*Library definitions;
libname hwref 'C:\Users\defraydz\Documents\School Work\SAS\HWREF' access=readonly;
libname orion 'C:\Users\defraydz\Documents\School Work\SAS\Data';
libname myhw 'C:\Users\defraydz\Documents\School Work\SAS\MYHW'; /*1 Permanent personal data*/
filename hw "C:\Users\defraydz\Documents\School Work\SAS\MYHW\DDeFrayne_HW14_output.pdf";

*1 Open a pdf output destination;
ods pdf file=hw;

*2 Tell SAS where to look for permanent personal functions;
proc fcmp outlib=myhw.functions.calcs;
	function winrate(record $);
		IF find(record,'-')=0 then return ('.');
			ELSE return ((input(scan(record,1,'-'),10.))/((input(scan(record,1,'-'),10.))+(input(scan(record,2,'-'),10.))));
			*3a Return the win percentage as a decimal;
	endsub;
	*3b Subroutine returns win percent as a decimal, win number, and loss number;
	subroutine w2p(record $, winpct, win, loss);
		outargs winpct, win, loss;
		IF find(record,'-')=0 then winpct='.';
			ELSE winpct=((input(scan(record,1,'-'),10.))/((input(scan(record,1,'-'),10.))+(input(scan(record,2,'-'),10.))));
		IF find(record,'-')=0 then win='.';
			ELSE win = input(scan(record,1,'-'),10.);
		IF find(record,'-')=0 then loss='.';
			ELSE loss = input(scan(record,2,'-'),10.);
	endsub;
run;

/*4 Create a copy of tourney18 in the work library, and replace the hyphen of the first
record with a comma*/
data tourney18;
	set hwref.tourney18;
	IF _N_=1 THEN record = translate(record,',','-');
run;

*Include the function library;
options cmplib=myhw.functions;

*5 Create tourney18 with the calculated statistics from step 2;
data myhw.t18mod;
	set tourney18;
	call missing(winpct); *Initialize variables;
	call missing(win);
	call missing(loss);
	call w2p(record, winpct, win, loss);
	label winpct = 'Win %' win = 'Wins' loss = 'Losses'; *Apply labels;
	format winpct PERCENT10.1; *Format winpct as a percentage;
run;

*6 Print the first 25 observations of the t18mod data set;
title 'Sample Wins, Losses, and Win Percentage for 2018 NCAA Tournament Teams';
proc print data=myhw.t18mod (obs=25) label ;
run;

*7 Use SQL to output the winningest teams;
title 'Winningest Teams in the 2018 NCAA Tournament';
proc sql;
	SELECT School, Record, winrate(record) AS wr label 'Win %' format PERCENT10.1, Overall_rank
	FROM tourney18
	ORDER BY wr desc;
quit;

*Close the pdf output;
ods pdf close;
