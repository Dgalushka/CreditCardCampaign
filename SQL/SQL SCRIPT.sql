
-- CREATE A DATA BASE AND A TABLE TO LOAD OUR DATA FILE INTO


create database if not exists
credit_card_classification;

create table if not exists 

credit_card_data
(Customer_Number INT,
Offer_Accepted VARCHAR(100),
Reward VARCHAR(100),
Mailer_Type VARCHAR(100),
Income_Level VARCHAR(100),
Bank_accounts_open INT,
Overdraft_Protection VARCHAR(100),
Credit_Rating VARCHAR(100),
Credit_Cards_Held INT,
Homes_Owned INT,
Household_Size INT,
Own_Your_Home VARCHAR(100),
Average_Balance FLOAT,
Q1_Balance FLOAT,
Q2_Balance FLOAT,
Q3_Balance FLOAT,
Q4_Balance FLOAT);

SHOW VARIABLES LIKE 'local_infile';
use credit_card_classification;


-- COMPLETE TABLE VIEW

SELECT * FROM credit_card_data;



-- DROPPING Q4

alter table credit_card_data
drop column Q4_Balance;

select * from credit_card_data limit 10;



-- CHECKING THE NUMBER OF ROWS IN OUR DATA

select count(*) as "Number of rows" from credit_card_data;



-- RECOUNT OF UNIQUE VALUES(for a quick insight on the data)

select Offer_Accepted as "(Y/N)", count(*)	as "Recount"		-- (Y/N) Offer Acceptance
from credit_card_data
group by Offer_Accepted;

select Reward, count(*)	as "Recount"					-- Type Of Reward
from credit_card_data
group by Reward;

select Mailer_Type as "Mailer Type", count(*)	as "Recount"			-- Mail Type
from credit_card_data
group by Mailer_Type;

select Income_Level as "Income Level", count(*)	as "Recount"			-- Income Level
from credit_card_data
group by Income_Level;

select Bank_accounts_open as "Number Of Bank Accounts Open", count(*)	as "Recount"		-- # Of Bank Accounts Owned
from credit_card_data
group by Bank_accounts_open;

select Overdraft_Protection as "Overdraft Protection", count(*)	as "Recount"	-- Overdraft Protection
from credit_card_data
group by Overdraft_Protection;

select Credit_Rating as "Credit Rating", count(*)	as "Recount"			-- Credit Rating
from credit_card_data
group by Credit_Rating;

select Credit_Cards_Held as "Number Of Credit Cards Owned", count(*)	as "Recount"		-- # Of Credit Cards Owned
from credit_card_data
group by Credit_Cards_Held;

select Homes_Owned as "Number Of Homes Owned", count(*)	as "Recount"			-- # Of Homes Owned
from credit_card_data
group by Homes_Owned;

select Household_Size as "Household Size", count(*)	as "Recount"			-- Household Size
from credit_card_data
group by Household_Size;

select Own_Your_Home "Home Ownership", count(*)	as "Recount"			-- Home Ownership
from credit_card_data
group by Own_Your_Home;

-- According to this data our most typical customer would have a medium income, one bank account,
-- no overdraft protection, 1-2 credit cards and owns one home with 2-4 family members.


-- Top 10 Customers (Average Balance)

select customer_number as "Top 10 Customers (Average Balance)", average_balance as "Average Balance"
from credit_card_data
order by average_balance desc
limit 10;



-- Total Avarage Balances

select avg(average_balance) as "All Clients Average Balance"
from credit_card_data;



-- Average balance of the customers grouped by `Income Level`

select Income_Level as "Income Level", avg(average_balance) as "Average Balance"
from credit_card_data
group by Income_Level;



-- average balance of the customers grouped by `number_of_bank_accounts_open`

select bank_accounts_open as "# Of Bank Accounts", avg(average_balance) as "Average Balance"
from credit_card_data
group by Bank_accounts_open;



--  average number of credit cards held by customers for each credit rating

select Credit_Rating as "Credit Rating", avg(Credit_Cards_Held) as "Average Number of Credit Cards Owned"
from credit_card_data
group by Credit_Rating;



-- correlation between the columns `credit_cards_held` and `number_of_bank_accounts_open`

select bank_accounts_open as "Number Of Bank Accounts Opened", avg(credit_cards_held) as "Average Number of Credit Cards Owned"
from credit_card_data
group by bank_accounts_open;

select credit_cards_held as "Number of Credit Cards Owned", avg(bank_accounts_open) as "Average Number Of Bank Accounts Opened"
from credit_card_data
group by credit_cards_held;

SELECT 
    (COUNT(*) * SUM(credit_cards_held * bank_accounts_open) - SUM(credit_cards_held) * SUM(bank_accounts_open)) /
    (SQRT((COUNT(*) * SUM(credit_cards_held * credit_cards_held) - POW(SUM(credit_cards_held), 2)) *
          (COUNT(*) * SUM(bank_accounts_open * bank_accounts_open) - POW(SUM(bank_accounts_open), 2)))) AS correlation_coefficient
FROM
    credit_card_data;

-- They show a positive correlation of '0.7592342137339895'.


-- CUSTOMERS OF INTEREST

select *
from credit_card_data
where (Credit_Rating = "medium" OR Credit_Rating = "high")
	AND (credit_cards_held <= 2)
    AND (own_your_home = "yes")
    AND (household_size >= 3)
    AND (Offer_accepted = "Yes");
    
    
    
-- customers whose average balance is less than the average balance

create view below_avg_balance_customers as
select customer_number as "Customer Number", average_balance as "Average Balance"
from credit_card_data
where average_balance < (select avg(average_balance) from credit_card_data);

select * from below_avg_balance_customers;		-- VIEW OF CUSTOMERS THAT MEET CRITERIA



-- List of customers with High/Medium Credit Rating.

select customer_number as "Customers With Medium/High Credit Rating" from credit_card_data
where Credit_Rating = "High" OR Credit_Rating = "Medium";



-- Difference in average balance of high credit rating vs low credit rating.

select 
    avg(case when Credit_Rating = 'High' then average_balance end) as "Average Balance (High Credit Score)",
    avg(case when Credit_Rating = 'Low' then average_balance end) as "Average Balance (Low Credit Score)",
		avg(case when Credit_Rating = 'High' then average_balance end) 
        -
        avg(case when Credit_Rating = 'Low' then average_balance end) 
        as "Average Balance Difference"
from credit_card_data
where Credit_Rating in ('High', 'Low');



-- Specific Customer Insight -- 11th Least "Q1 Balance"

SELECT *
FROM credit_card_data
WHERE Q1_Balance IS NOT NULL
ORDER BY Q1_Balance
LIMIT 1 OFFSET 10;






-- ADDITIONAL EXPLORATION

-- YES vs NO Recount

SELECT
    Mailer_Type as "Mailer Type",					-- MAILER TYPE
    count(*) as "Recount",
    CONCAT(ROUND((count(*) / (SELECT count(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / count(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / count(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT count(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Mailer_Type;


SELECT
    Reward as "Reward",					                -- REWARD
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Reward;


SELECT
    Income_Level as "Income Level",			            -- INCOME LEVEL
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Income_Level;


SELECT
    Bank_accounts_open as "# Of Bank Accounts Open",       -- NUMBER OF BANK ACCOUNTS OPEN
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Bank_accounts_open;


SELECT
    Overdraft_Protection as "Overdraft Protection",       -- OVERDRAFT PROTECTION
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Overdraft_Protection;


SELECT
    Credit_Rating as "Credit Rating",                   -- CREDIT RATING
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Credit_Rating;


SELECT
    Credit_Cards_Held as "Number Of Credit Cards Owned",   -- NUMBER OF CREDIT CARDS OWNED
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Credit_Cards_Held;


SELECT
    Homes_Owned as "Number Of Homes Owned",                -- NUMBER OF HOMES OWNED
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount ( % )",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Homes_Owned;


SELECT
    Household_Size as "Household Size",                   -- HOUSEHOLD SIZE
    COUNT(*) as "Recount",
    CONCAT(ROUND((COUNT(*) / (SELECT COUNT(*) FROM credit_card_data)) * 100, 2), '%') as "Recount (%)",
    SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) as "Recount ( Yes )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (Yes -%)",
    SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) as "Recount ( No )",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'No' THEN 1 ELSE 0 END) / COUNT(*) * 100), 2), '%') as "Recount (No-%)",
    CONCAT(ROUND((SUM(CASE WHEN Offer_Accepted = 'Yes' THEN 1 ELSE 0 END) / (SELECT COUNT(*) FROM credit_card_data WHERE Offer_Accepted = 'Yes') * 100), 2), '%') as "Percentage of accepted offers"
FROM credit_card_data
GROUP BY Household_Size;


