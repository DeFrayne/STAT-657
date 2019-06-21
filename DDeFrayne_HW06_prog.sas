/* Program Name: DDeFrayne_HW06_prog											   */
/* Program Location: D:\School\TAMU\SAS\										   */
/* Creation Date: 2/9/2019 													       */
/* Author: Don DeFrayne 														   */
/* Purpose: Work with SQL prompts												   */
/* Inputs: D:\School\TAMU\SAS\HWREF\ncaam2003.sas7bdat							   */
/*	D:\School\TAMU\SAS\HWREF\ncaam2004.sas7bdat									   */
/*	D:\School\TAMU\SAS\HWREF\ncaam2006.sas7bdat									   */
/*	D:\School\TAMU\SAS\HWREF\mbbteams18.sas7bdat								   */
/*	D:\School\TAMU\SAS\HWREF\tourney18.sas7bdat									   */
/* Outputs: DDeFrayne_HW06_output.pdf 											   */
/***********************************************************************************/

*Create library and file references;
libname orion 'D:\School\TAMU\SAS\Data\' access=readonly;
libname hwref 'D:\School\TAMU\SAS\HWREF\' access=readonly; *I will be using this for the permanent data sets;
libname myhw 'D:\School\TAMU\SAS\MYHW\';
filename hw 'D:\School\TAMU\SAS\DDeFrayne_HW06_output.pdf';

*Open the pdf output;
ods pdf file=hw;

*1 Show the teams and number of players for each team for all 3 years of player data;
proc sql;
SELECT Team, COUNT(Player)
FROM hwref.ncaam2003
GROUP BY Team;

SELECT Team, COUNT(Player)
FROM hwref.ncaam2004
GROUP BY Team;

SELECT School, COUNT(Player)
FROM hwref.ncaam2006
GROUP BY School;

*2 Join queries from step 1 into a single query using inline views;
SELECT d.Team, SUM(d.aPlayer) AS Count03, SUM(d.bPlayer) AS Count04, SUM(d.cPlayer) AS Count06
FROM
(SELECT a.Team, COUNT(a.Player) AS aPlayer, . AS bPlayer, . AS cPlayer
	FROM hwref.ncaam2003 a
	GROUP BY a.Team
		UNION
SELECT b.Team, . AS aPlayer, COUNT(b.Player) AS bPlayer, . AS cPlayer
	FROM hwref.ncaam2004 b
	GROUP BY b.Team
		UNION
SELECT c.School, . AS aPlayer, . AS bPlayer, COUNT(c.Player) AS cPlayer
	FROM hwref.ncaam2006 c
	GROUP BY c.School) d
GROUP BY 1;
quit;

*3 Write expanded queries to the log for 2004 and 2006 data - do not output to ods;
proc sql feedback noexec;
SELECT *
FROM hwref.ncaam2003;
SELECT *
FROM hwref.ncaam2006;
quit;

*4 
