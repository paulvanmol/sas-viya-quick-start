options sastrace=",,t,d" sastraceloc=saslog nostsuffix;
libname vrtpubli vertica dsn=VerticaDSN user=student password=Metadata0 
	schema='public';
libname vrtstore vertica dsn=VerticaDSN user=student password=Metadata0 
	schema='store';
libname vrtonlin vertica dsn=VerticaDSN user=student password=Metadata0 
	schema='online_Sales';

proc datasets library=vrtpubli;
run;

proc datasets library=vrtstore;
run;

proc datasets library=vrtonlin;
run;

quit;
cas mysession;
caslib caspubli desc='Vertica public'
dataSource=(srctype='vertica', server='server.demo.sas.com'
username='student', password='Metadata0', database='VMart', schema='public') global;
caslib casstore desc='Vertica store'
dataSource=(srctype='vertica', server='server.demo.sas.com'
username='student', password='Metadata0', database='VMart', schema='store') global;
caslib casonlin desc='Vertica Online Sales'
dataSource=(srctype='vertica', server='server.demo.sas.com'
username='student', password='Metadata0', database='VMart', schema='store') global;

proc casutil;
	list files incaslib="caspubli";
quit;

proc casutil;
	list files incaslib="casstore";
quit;

proc casutil;
	list files incaslib="casonlin";
quit;