create database data_science_jobs;
select * from salaries;

/*1.	You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, 
for the title 'managers’ Paying salaries Exceeding $90,000 USD*/
select distinct (company_location) from salaries where job_title like '%Manager%' and remote_ratio = 100 and salary_in_usd > 90000; 

/*2.	AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms.
 you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.*/
 select distinct(company_location), count(*) from salaries where experience_level = 'EN' and company_size = 'L'
group by company_location order by count(*) desc limit 5; 

/*3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees,
 Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/
 /* we will solve this particular problem using variables.*/
 set @count = (select count(*) from salaries where remote_ratio=100 and salary_in_usd>100000);
 set @total = (select count(*) from salaries where salary_in_usd > 100000);
SELECT ROUND(((@count) / (@total)) * 100, 2) AS percentage_working_remotely;
 
 /*4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average
 salaries exceed the average salary for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities.*/
with cte as (select t.job_title, t.global_average, a.company_location, a.avg_per_cntry 
from (select job_title, avg(salary_in_usd) as 'global_average' from salaries where experience_level = 'EN' group by job_title) as t
inner join (select job_title, company_location, avg(salary_in_usd) as 'avg_per_cntry' from salaries where experience_level='EN' group by job_title, company_location) as a
on t.job_title = a.job_title)
select distinct(company_location), job_title from cte where avg_per_cntry>global_average;

/*5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which,
 Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/
 select company_location, job_title 
 from
 (select company_location, job_title, avg_salary, rank( ) over(partition by job_title order by avg_salary desc) as rn from 
 (
 select company_location, job_title, avg(salary) as avg_salary from salaries group by job_title, company_location 
 ) as a
 ) as b where rn=1;
 
 /*6.AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 
 3 years Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.*/
 
with cte as ( select * from salaries where company_location in (select company_location from (select company_location, avg(salary_in_usd), count(distinct work_year) 
 from salaries where work_year >= (year(current_date())-2) group by company_location having count(distinct work_year)=3) as a))
 
 select 
    company_locatiON,
    max(case when work_year = 2022 then  average end) as AVG_salary_2022,
    max(case when work_year = 2023 then average end) as AVG_salary_2023,
    max(case when work_year = 2024 then average end) as AVG_salary_2024
from 
(
select company_locatiON, work_year, avg(salary_IN_usd) as average from cte group by company_locatiON, work_year 
)q group by company_locatiON having AVG_salary_2024 > AVG_salary_2023 and AVG_salary_2023 > AVG_salary_2022;

/*7. Picture yourself AS a workforce strategist employed by a global HR tech startup. Your Mission is to Determine the percentage of fully remote work
 for each experience level IN 2021 and compare it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases IN 
 remote work Adoption over the years.*/
 with cte1 as
 (select experience_level, round((remote/total)*100,2) as perc_2021 from 
 (select a.experience_level, remote, total from
 (select experience_level, count(remote_ratio) as total from salaries where work_year = '2021' group by experience_level)as a
 inner join
 (select experience_level, count(remote_ratio) as remote from salaries where work_year = '2021' and remote_ratio=100 group by experience_level) as b
 on a.experience_level = b.experience_level) as t),
 
 cte2 as 
 (select experience_level, round((remote/total)*100,2) as perc_2024 from 
 (select a.experience_level, remote, total from
 (select experience_level, count(remote_ratio) as total from salaries where work_year = '2024' group by experience_level)as a
 inner join
 (select experience_level, count(remote_ratio) as remote from salaries where work_year = '2024' and remote_ratio=100 group by experience_level) as b
 on a.experience_level = b.experience_level) as t)
 select cte1.experience_level, cte1.perc_2021, cte2.perc_2024 from cte1 inner join cte2 on cte1.experience_level = cte2.experience_level;

/*8.AS a Compensation specialist at a Fortune 500 company, you're tasked WITH analyzing salary trends over time. Your objective is to calculate the
 average salary increase percentage for each experience level and job title between the years 2023 and 2024, helping the company stay competitive IN the talent market.*/
 
with cte as ( select a.experience_level, a.job_title, avg_salary_2023, avg_salary_2024 from 
 (select experience_level, job_title, avg(salary_in_usd) as avg_salary_2023 from salaries where work_year = 2023 group by experience_level, job_title) as a
 inner join 
 (select experience_level, job_title, avg(salary_in_usd) as avg_salary_2024 from salaries where work_year = 2024 group by experience_level, job_title) as b 
 on a.experience_level = b.experience_level and a.job_title = b.job_title)
 select experience_level, job_title, avg_salary_2023, avg_salary_2024, round(((avg_salary_2024-avg_salary_2023)/avg_salary_2023)*100, 2) as perc_increase from cte;
 
 /*9.	You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement a security measure where
 employees in different experience level (e.g. Entry Level, Senior level etc.) can only access details relevant to their respective experience level, ensuring data 
 confidentiality and minimizing the risk of unauthorized access. */
 
 select * from salaries;
 select distinct experience_level from salaries;
 Show privileges;
 
create user 'Entry_level'@'%' identified by 'EN';
create  user 'Junior_Mid_level'@'%' identified by ' MI '; 
create user 'Intermediate_Senior_level'@'%' identified by 'SE';
create user 'Expert Executive-level '@'%' identified by 'EX ';


create view entry_level as
select * from salaries where experience_level='EN';
grant select on data_science_jobs.entry_level to 'Entry_level'@'%';

create view junior_mid_level as
select * from salaries where experience_level = 'MI';
grant select on data_science_jobs.junior_mid_level to 'Junior_Mid_level'@'%';  

create view Intermediate_senior_level as
select * from salaries where experience_level = 'SE';
grant select on data_science_jobs.Intermediate_senior_level to 'Intermediate_Senior_level'@'%'; 

create view Expert_executive_level as
select * from salaries where experience_level = 'EX';
grant select on data_science_jobs.Expert_executive_level to 'Expert Executive-level '@'%' ;  


/* 10.	You are working with an consultancy firm, your client comes to you with certain data and preferences such as 
( their year of experience , their employment type, company location and company size )  and want to make an transaction into different domain in data industry
(like  a person is working as a data analyst and want to move to some other domain such as data science or data engineering etc.)
your work is to  guide them to which domain they should switch to base on  the input they provided, so that they can now update thier knowledge as  per the suggestion/.. 
The Suggestion should be based on average salary.*/

DELIMITER //
create procedure GetAverageSalary(in exp_lev varchar(2), in emp_type varchar(3), in comp_loc varchar(2), in comp_size varchar(2))
begin
    select job_title, experience_level, company_location, company_size, employment_type, round(avg(salary), 2) as avg_salary 
    from salaries 
    where experience_level = exp_lev and company_location = comp_loc and company_size = comp_size and employment_type = emp_type 
    group by experience_level, employment_type, company_location, company_size, job_title order by avg_salary desc ;
end//
DELIMITER ;
-- Deliminator  By doing this, you're telling MySQL that statements within the block should be parsed as a single unit until the custom delimiter is encountered.

call GetAverageSalary('EN','FT','AU','M');

/*11.As a market researcher, your job is to Investigate the job market for a company that analyzes workforce data. Your Task is to know how many people were
 employed IN different types of companies AS per their size IN 2021.*/
 select company_size, count(company_size) as employee_count from salaries where work_year = 2021 group by company_size;  
 
 /*12. Imagine you are a talent Acquisition specialist Working for an International recruitment agency. Your Task is to identify the top job 2 title that command
 the highest average salary Among part-time Positions IN the year 2023. However, you are Only Interested IN Countries WHERE there are more than 50 employees,
 Ensuring a robust sample size for your analysis.*/
 
 select job_title, avg(salary_in_usd) as 'average_salary' from salaries where employment_type = 'PT' and work_year = '2023' and company_location in
(select company_location from(select company_location, count(*) as employee_count from salaries group by company_location having employee_count >50) as a) 
group by job_title order by average_salary desc limit 2; 

/*13. As a database analyst you have been assigned the task to Select Countries where average mid-level salary is higher than overall mid-level
 salary for the year 2023.*/
 
select company_location, avg(salary_in_usd) as cntry_avg_salary 
from salaries where experience_level = 'MI' and work_year = 2023 group by company_location
having avg(salary_in_usd) > (select avg(salary_in_usd) from salaries where experience_level = 'MI' and work_year = 2023);  

/*14. As a database analyst you have been assigned the task to Identify the company locations with the highest and lowest
 average salary for senior-level (SE) employees in 2023.*/
 
DELIMITER //

create procedure GetSeniorSalaryStats()
begin
    -- Query to find the highest average salary for senior-level employees in 2023
    select company_location as highest_location, avg(salary_in_usd) as highest_avg_salary
    from  salaries
    where work_year = 2023 and experience_level = 'SE'
    group by company_location
    order by highest_avg_salary desc
    limit 1;

    -- Query to find the lowest average salary for senior-level employees in 2023
    select company_location as lowest_location, avg(salary_in_usd) as lowest_avg_salary
    from salaries
    where work_year = 2023 and experience_level = 'SE'
    group by company_location
    order by lowest_avg_salary asc
    limit 1;
end //

-- Reset the delimiter back to semicolon
DELIMITER ;

-- Call the stored procedure to get the results
call GetSeniorSalaryStats();

/*15.You're a Financial analyst Working for a leading HR Consultancy, and your Task is to Assess the annual salary growth rate for
 various job titles. By Calculating the percentage Increase IN salary FROM previous year to this year, you aim to provide valuable 
 Insights Into salary trends WITHIN different job roles.*/
 with cte as 
 (select a.job_title, average_2023, average_2024 from 
 (select job_title, avg(salary_in_usd) as average_2023 from salaries where work_year = 2023 group by job_title ) as a
 inner join
(select job_title, avg(salary_in_usd) as average_2024 from salaries where work_year = 2024 group by job_title ) as b
on a.job_title = b.job_title)
select job_title, average_2023, average_2024, round(((average_2024-average_2023)/average_2023)*100, 2) as perc_inc from cte order by job_title;
 
/*16. Picture yourself as a data architect responsible for database management. Companies in US and AU(Australia) decided to create a hybrid model for
 employees they decided that employees earning salaries exceeding $90000 USD, will be given work from home. You now need to update the remote work ratio
 for eligible employees, ensuring efficient remote work management while implementing appropriate error handling mechanisms for invalid input parameters.*/
 
-- creating a temporary table hybrid which contains data related to the given company location and meeting the salary criteria
 create table hybrid as select * from salaries where company_location = 'US' or company_location = 'AU' and salary_in_usd > 90000;
 select * from hybrid;
 SET SQL_SAFE_UPDATES = 0;
update hybrid set remote_ratio = 100;
select * from hybrid;
set SQL_SAFE_UPDATES = 1;


/*17. In the year 2024, due to increased demand in the data industry, there was an increase in salaries of data field employees.
a.	Entry Level-35% of the salary.
b.	Mid junior – 30% of the salary.
c.	Immediate senior level- 22% of the salary.
d.	Expert level- 20% of the salary.
e.	Director – 15% of the salary.
You must update the salaries accordingly and update them back in the original database.*/

-- creating a temporary table increased_salary to make the required changes in that instead of original one
set SQL_SAFE_UPDATES = 0;
create table increased_salary select * from salaries;
update increased_salary 
set salary_in_usd = 
case when experience_level = 'EN' then salary_in_usd * 1.35
when experience_level = 'MI' then salary_in_usd * 1.30
when experience_level = 'SE' then salary_in_usd * 1.22
when experience_level = 'EX' then salary_in_usd * 1.20
when experience_level = 'DX' then salary_in_usd * 1.50
else salary_in_usd
end 
where work_year = '2024';
select * from increased_salary;

/*18. You are a researcher and you have been assigned the task to Find the year with the highest average salary for each job title.*/

with cte1 as 
(select job_title, work_year, avg(salary_in_usd) as avg_Salary from salaries group by work_year, job_title),
cte2 as (select job_title, work_year, avg_Salary, rank() over(partition by job_title order by avg_salary desc) as rnk from cte1)
select cte2.job_title, cte2.work_year, avg_Salary from cte2 where rnk =1;

/*19.You have been hired by a market research agency where you been assigned the task to show the percentage of different employment type
 (full time, part time) in Different job roles, in the format where each row will be job title, each column will be type of employment type
 and cell value for that row and column will show the % value.*/
 select job_title, 
 round((sum(case when employment_type = 'FT' then 1 else 0 end)/count(*))*100, 2) as full_time_percentage,
 round((sum(case when employment_type = 'CT' then 1 else 0 end)/count(*))*100, 2) as contract_type_percentage,
 round((sum(case when employment_type = 'PT' then 1 else 0 end)/count(*))*100, 2) as part_time_percentage, 
 round((sum(case when employment_type = 'FL' then 1 else 0 end)/count(*))*100, 2) as freelance_percentage
 from salaries group by job_title;
 
/*---------------------------------FINISH--------------------------*/











 
 
 
 
 
 
 
 
 
