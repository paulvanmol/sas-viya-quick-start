proc fedsql sessref=mysession; 

SELECT fat_content
         FROM ( SELECT DISTINCT fat_content
                FROM caspubli.product_dimension
                WHERE department_description
                IN ('Dairy') ) AS food
         ORDER BY fat_content
         LIMIT 5;
quit; 

proc sql;
connect using vrtpubli as vertica; 
execute (
create view public.TotalVacationDays as 
SELECT s.store_region, SUM(e.vacation_days) as TotalVacationDays
   FROM public.employee_dimension e
   JOIN store.store_dimension s ON s.store_region=e.employee_region
   GROUP BY s.store_region ORDER BY TotalVacationDays) by vertica;
disconnect from vertica; 
quit; 
proc sql; 
select * from vrtpubli.Totalvacationdays; 

quit;