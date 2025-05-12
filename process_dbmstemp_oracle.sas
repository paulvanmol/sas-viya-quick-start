OPTION
SASTRACE=',,,ds'
SASTRACELOC=SASLOG
NOSTSUFFIX
SQL_IP_TRACE=(note, source) msglevel=i
FULLSTIMER;
options sastrace=',,,';
%let dbpath=//server.demo.sas.com:1521/ORCL;
%let dbuser=STUDENT;
%let dbpw=Metadata0;
%let dbschema=STUDENT;

/* LIBNAME macro variables values not shown*/
LIBNAME ORAPERM oracle
path="&dbpath"
user="&dbUser"
pw="&dbPW"
schema="&dbschema"

/*bulkload=yes
bulkunload=yes*/
connection=GLOBAL
dbcommit=0;
LIBNAME oraTEMP oracle
path="&dbpath"
user="&dbUser"
pw="&dbpw"
schema="&dbSchema"

/*bulkload=yes
bulkunload=yes*/
connection=GLOBAL
dbcommit=0
dbmstemp=yes;

proc sql ; drop table oraperm.data_1m; 
quit; 

	data oraPERM.DATA_1M;
		do i=1 to 10000000;
			ID=Rand('integer', 1, 5000);
			Var2=Rand('integer', 1, 10000);
			Var3=Rand('integer', 1, 5000);
			Var4=Rand('integer', 1, 40000);
			output;
		end;
		drop i;
	run;



proc sql ; drop table work.data_100k; 
quit; 
	data work.DATA_100K;
		do i=1 to 100000;
			ID=Rand('integer', 1, 5000);
			Var2=Rand('integer', 1, 10000);
			Var3=Rand('integer', 1, 5000);
			Var4=Rand('integer', 1, 40000);
			output;
		end;
		drop i;
	run;


/*Scenario 1: Join Work table with Oracle table*/
PROC SQL;
	CREATE TABLE WORK.SCENARIO_1 AS
	SELECT
	t1.ID, (AVG(t1.Var2)) LENGTH=8 AS AVG_Var2, (MIN(t2.Var3)) LENGTH=8 AS
	MIN_Var3, (MAX(t2.Var4)) LENGTH=8 AS MAX_Var4
	FROM
	WORK.DATA_100K t1
	INNER JOIN ORAPERM.DATA_1M t2 ON (t1.ID=t2.ID) GROUP BY
	t1.ID;
QUIT;

/*Scenario 2: Copy Small table to DBMSTEMP library*/
proc sql ; drop table oratemp.data_100k; 
quit; 
DATA ORATEMP.DATA_100K;
	SET WORK.DATA_100K;
run;
 

PROC SQL;
	CREATE TABLE WORK.SCENARIO_2 AS
	SELECT
	t1.ID, (AVG(t1.Var2)) LENGTH=8 AS AVG_Var2, (MIN(t2.Var3)) LENGTH=8 AS
	MIN_Var3, (MAX(t2.Var4)) LENGTH=8 AS MAX_Var4
	FROM
	ORATEMP.DATA_100K t1
	INNER JOIN ORAPERM.DATA_1M t2 ON (t1.ID=t2.ID) GROUP BY
	t1.ID;
QUIT;

/*Step 6: Scenario 3 - Redirect query output from Scenario 2 to SNOWTEMP and run.*/
proc sql; 
drop table oratemp.scenario_3; 
quit; 
PROC SQL;
	CREATE TABLE ORATEMP.SCENARIO_3 AS
	SELECT
	t1.ID, (AVG(t1.Var2)) LENGTH=8 AS AVG_Var2, (MIN(t2.Var3)) LENGTH=8 AS
	MIN_Var3, (MAX(t2.Var4)) LENGTH=8 AS MAX_Var4
	FROM
	ORATEMP.DATA_100K t1
	INNER JOIN ORAPERM.DATA_1M t2 ON (t1.ID=t2.ID) GROUP BY
	t1.ID;
QUIT;