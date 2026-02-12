create database aml_monitoring;
use aml_monitoring;
select database();
create table customers (
customerID int auto_increment primary key,
firstname varchar (50),
lastname varchar (50),
country varchar (50)
);
describe customers;
insert into customers (firstname, lastname, country)
values ('Jan', 'Kowalski', 'PL');
insert into customers (firstname, lastname, country)
values ('Marco', 'Reus', 'DE');
insert into customers (firstname, lastname, country)
values ('Damiano', 'David', 'IT');
select * from customers;
select * from customers
where country='PL';
select firstname, lastname
from customers;
select * from customers
where country = 'DE' or country = 'IT';
select * from customers 
where country = 'PL'
and firstname = 'Jan';
alter table customers
add risk_rating varchar (10);
describe customers;
update customers
set risk_rating = 'LOW'
where country = 'PL';
update customers
set risk_rating = 'LOW'
where customerid = 1;
update customers
set risk_rating = 'LOW'
where customerid = 2;
update customers
set risk_rating = 'MEDIUM'
where customerid = 3;
select * from customers;
alter table customers
change customerid customer_id int auto_increment;
alter table customers
change firstname first_name varchar (50);
alter table customers
change lastname last_name varchar (50);
select customer_id, first_name, last_name, country, risk_rating
from customers
order by customer_id
limit 2;
select count(*) as total_customers
from customers;
select country, count(*) as customer_count
from customers
group by country;
select risk_rating, count(*) as customer_count
from customers
group by risk_rating
order by customer_count desc;
select country, count(*) as customers_count
from customers
group by country
having count(*) > 1;
select risk_rating, count(*) as customers_count
from customers
group by risk_rating
having count(*) < 1;
select country, count(*) as customers_count
from customers
where risk_rating <> 'LOW'
group by country
having count(*) >= 1;
create table accounts (
account_id int auto_increment primary key,
customer_id int,
account_type varchar(20),
balance decimal(12,2),
currency char(3),
open_date date,
foreign key (customer_id) references customers(customer_id)
);
show tables;
describe accounts;
select * from accounts;
select customer_id, first_name from customers;
insert into accounts (customer_id, account_type, balance, currency, open_date)
values (99, 'personal', 100000.00, 'EUR', '2026-03-27');
select * from accounts;
select
c.customer_id,
c.first_name,
c.last_name,
a.account_id,
a.account_type,
a.balance,
a.currency
from customers c
join accounts a
on c.customer_id = a.customer_id;
SELECT
    c.first_name,
    c.last_name,
    c.risk_rating,
    a.account_type,
    a.balance,
    a.currency
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
WHERE c.risk_rating = 'MEDIUM';
SELECT
    c.first_name,
    c.last_name,
    a.balance,
    a.currency
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
ORDER BY a.balance DESC;
SELECT
    c.first_name,
    c.last_name,
    c.country,
    a.balance,
    a.currency
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
WHERE a.balance > 10000;
create table transactions (
transaction_id int auto_increment primary key,
account_id int,
transaction_date datetime,
amount decimal(12,2),
currency char(3),
transaction_type varchar(10),
country char(2),
foreign key (account_id) references accounts(account_id)
);
show tables;
describe transactions;
select account_id, customer_id from accounts;
insert into transactions (account_id, transaction_date, amount, currency, transaction_type, country)
values
(1, '2026-01-02 10:15:43', 400.00, 'PLN', 'OUT', 'PL'),
(1, '2026-01-05 16:45:21', 1100.00, 'PLN', 'OUT', 'PL'),
(1, '2026-01-06 12:01:33', 70.00, 'PLN', 'IN', 'PL');
insert into transactions (account_id, transaction_date, amount, currency, transaction_type, country)
values
(3, '2026-04-04 14:44:44', 9800.00, 'EUR', 'OUT', 'IT'),
(3, '2026-04-06 09:21:18', 9200.00, 'EUR', 'OUT', 'IT'),
(3, '2026-04-07 20:05:59', 9450.00, 'EUR', 'OUT', 'IT');
select * from transactions
where account_id = 3;
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.risk_rating,
    a.account_id,
    t.transaction_id,
    t.transaction_date,
    t.amount,
    t.currency,
    t.country
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id;
SELECT
    c.first_name,
    c.last_name,
    t.amount,
    t.currency,
    t.country,
    t.transaction_date
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.amount > 9000;
SELECT
    c.first_name,
    c.last_name,
    COUNT(t.transaction_id) AS tx_count,
    SUM(t.amount) AS total_amount
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
WHERE t.amount < 10000
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(t.transaction_id) >= 3;
create table high_risk_countries (
country_code char(2) primary key,
country_name varchar(100)
);
describe high_risk_countries;
select * from high_risk_countries;
insert into high_risk_countries (country_code, country_name) values
('IR', 'Iran'),
('NK', 'North Korea'),
('SY', 'Syria'),
('RU', 'Russia'),
('AS', 'Afghanistan'),
('HT', 'Haiti'),
('MN', 'Monaco');
update high_risk_countries
set country_code = 'KP'
where country_code = 'NK';
update high_risk_countries
set country_code = 'AF'
where country_code = 'AS';
update high_risk_countries
set country_code = 'MC'
where country_code = 'MN';
select
t.transaction_id,
t.amount,
t.currency,
t.country
from transactions t
left join high_risk_countries h
on t.country = h.country_code;
SELECT
    c.first_name,
    c.last_name,
    c.risk_rating,
    t.amount,
    t.currency,
    t.country,
    h.country_name
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
LEFT JOIN high_risk_countries h
    ON t.country = h.country_code
WHERE h.country_code IS NOT NULL;
create table aml_alerts (
	alert_id int auto_increment primary key,
    customer_id int,
    account_id int,
    transaction_id int,
    alert_type varchar(50),
    alert_reason varchar(255),
    created_at datetime default current_timestamp
    );
    select * from aml_alerts;
    INSERT INTO aml_alerts (
    customer_id,
    account_id,
    transaction_id,
    alert_type,
    alert_reason
)
SELECT
    c.customer_id,
    a.account_id,
    t.transaction_id,
    'HIGH_RISK_COUNTRY',
    CONCAT('Transaction to high-risk country: ', h.country_name)
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
JOIN high_risk_countries h
    ON t.country = h.country_code;
select * from aml_alerts
order by created_at desc;
select * from aml_alerts;
INSERT INTO transactions (account_id, transaction_date, amount, currency, transaction_type, country)
VALUES
(1, '2026-01-16 10:00:00', 5000.00, 'USD', 'OUT', 'IR'),
(2, '2026-01-16 11:00:00', 7000.00, 'EUR', 'OUT', 'RU'),
(3, '2026-01-16 12:00:00', 3000.00, 'EUR', 'OUT', 'SY'),
(1, '2026-01-16 13:00:00', 8000.00, 'USD', 'OUT', 'IR');
select * from transactions
where country in ('IR', 'RU', 'SY');
select * from aml_alerts;
insert into aml_alerts (
customer_id,
account_id,
transaction_id,
alert_type,
alert_reason
)
select
c.customer_id,
a.account_id,
t.transaction_id,
'HIGH_RISK_COUNTRY',
CONCAT('Transaction to high-risk country: ', h.country_name)
from customers c
join accounts a
	on c.customer_id = a.customer_id
join transactions t
	on a.account_id = t.account_id
join high_risk_countries h
	on t.country = h.country_code;
select * from aml_alerts;
show tables;
select * from aml_alerts;
select
	customer_id,
    account_id,
    transaction_id,
    alert_type
    from aml_alerts;
    INSERT INTO aml_alerts (
    customer_id,
    account_id,
    transaction_id,
    alert_type,
    alert_reason
)
SELECT
    c.customer_id,
    a.account_id,
    t.transaction_id,
    'HIGH_RISK_COUNTRY',
    CONCAT('Transaction to high-risk country: ', h.country_name)
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
JOIN high_risk_countries h
    ON t.country = h.country_code
WHERE NOT EXISTS (
    SELECT 1
    FROM aml_alerts al
    WHERE al.transaction_id = t.transaction_id
      AND al.alert_type = 'HIGH_RISK_COUNTRY'
);
SELECT COUNT(*) FROM aml_alerts;
select * from aml_alerts;
INSERT INTO aml_alerts (
    customer_id,
    account_id,
    transaction_id,
    alert_type,
    alert_reason
)
SELECT
    c.customer_id,
    a.account_id,
    t.transaction_id,
    'HIGH_RISK_COUNTRY',
    CONCAT('Transaction to high-risk country: ', h.country_name)
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
JOIN transactions t
    ON a.account_id = t.account_id
JOIN high_risk_countries h
    ON t.country = h.country_code
WHERE NOT EXISTS (
    SELECT 1
    FROM aml_alerts al
    WHERE al.transaction_id = t.transaction_id
      AND al.alert_type = 'HIGH_RISK_COUNTRY'
);
select count(*) from aml_alerts;
create table aml_cases (
	case_id int auto_increment primary key,
    alert_id int,
    case_status varchar(20),
    analyst_name varchar(100),
    decision varchar(50),
    decision_reason varchar(255),
    created_at datetime default current_timestamp,
    closed_at datetime
    );
    insert into aml_cases (
		alert_id,
        case_status,
        analyst_name
        )
        values (
        1,
        'OPEN',
        'Liam Brady'
        );
        select * from aml_cases
        where case_status = 'OPEN';
        update aml_cases
        set
		case_status = 'CLOSED',
        decision = 'FALSE_POSITIVE',
        decision_reason = 'Customer activity consistent with profile',
        closed_at = current_timestamp
	where case_id = 1;
    select * from aml_cases
    where case_id = 1;
    select * from aml_alerts;
    insert into aml_cases (
    alert_id,
    case_status,
    analyst_name
    )
    values (
    2,
    'OPEN',
    'Jakub Kopiejka'
    );
    select * from aml_cases;
    update aml_cases
    set
		case_status = 'CLOSED',
        decision = 'FALSE POSITIVE',
        decision_reason = 'The Customer transfers funds to a family member',
        closed_at = current_timestamp
	where case_id = 2;
    select * from aml_cases;
    select * from aml_alerts;
    select * from transactions;
    select * from accounts;
    select * from aml_alerts;
    select * from transactions;
    select * from accounts;
    select * from aml_alerts;
    insert into aml_cases (
    alert_id,
    case_status,
    analyst_name
    )
    values (
    3,
    'OPEN',
    'Dmitri Pirog'
    );
    update aml_cases
    set
		case_status = 'CLOSED',
        decision = 'TRUE POSITIVE',
        decision_reason = 'The counterparty is a sanctioned entity',
        closed_at = current_timestamp
	where case_id = 3;
    select * from aml_cases;
    insert into aml_cases (
    alert_id,
    case_status,
    analyst_name
    )
    values (
    4,
    'OPEN',
    'Gennady Golovkin'
    );
    select * from aml_cases;
    select * from aml_alerts;
    select * from transactions;
    update aml_cases
    set
		case_status = 'CLOSED',
        decision = 'FALSE POSITIVE',
        decision_reason = 'Transaction amount significantly lower than previous TRX. The counterparty matches the profile',
        closed_at = current_timestamp
	where case_id = 4;
    select * from aml_cases;
    update aml_cases
    set case_status = 'ESCALATED'
    where case_id = 3;
    select * from aml_cases;
    update aml_cases
    set
		decision_reason = 'Customer activity consistent with profile'
	where case_id = 4;
    select * from aml_cases;
    insert into aml_cases (
    alert_id,
    case_status,
    analyst_name
    )
    select
		a.alert_id,
        'OPEN',
        'UNASSIGNED'
	from aml_alerts a
    where not exists (
    select 1
    from aml_cases c
    where c.alert_id = a.alert_id
    );
    select * from aml_cases;
    select * from aml_alerts;
    select * from transactions;
    select * from aml_alerts;
    alter table aml_alerts
    add column transaction_ids JSON;
    select * from aml_alerts;
    insert into aml_alerts (
    customer_id,
    account_id,
    transaction_ids,
    alert_type,
    alert_reason
    )
    values (
    3,
    3,
    JSON_ARRAY(4,5,6),
    'STRUCTURING',
    'MULTIPLE OUTGOING TRX JUST UNDER THE THRESHOLD'
    );
    select * from aml_alerts;
    update aml_alerts
    set alert_reason = 'Multiple outgoing TRX just under the reporting threshold'
    where alert_id = 5;
    select * from aml_alerts;
    alter table aml_alerts
    drop column transaction_ids;
    select * from aml_alerts;
    delete from aml_alerts
    where alert_id = 5;
    select * from aml_alerts;
    select * from transactions;
    select * from aml_alerts;
    create table alert_transactions (
    alert_id int not null,
    transaction_id int not null,
    primary key (alert_id, transaction_id),
    foreign key (alert_id) references aml_alerts(alert_id),
    foreign key (transaction_id) references transactions(transaction_id)
    );
    insert into aml_alerts (
    alert_id,
    customer_id, 
    account_id, 
    alert_type,
    alert_reason)
    values (
    5,
    3,
    3,
    'STRUCTURING',
    'Multiple TRX just under the reporting threshold'
    );
    select * from alert_transactions;
    insert into alert_transactions (alert_id, transaction_id)
    values (5,4), (5,5), (5,6);
    select * from alert_transactions;
    create table case_transactions (
    case_id int not null,
    transaction_id int not null,
    primary key (case_id, transaction_id),
    foreign key (case_id) references aml_cases(case_id),
    foreign key (transaction_id) references transactions(transaction_id)
    );
    show tables;
    select * from aml_alerts;
    select * from alert_transactions;
    insert into aml_cases (alert_id, case_status, analyst_name, created_at)
    select a.alert_id, 'OPEN', 'UNASSIGNED', NOW()
    from aml_alerts a
    left join aml_cases c on a.alert_id = c.alert_id
    where c.alert_id is null;
    SELECT *
FROM aml_cases
WHERE analyst_name = 'UNASSIGNED';
select case_id
from aml_cases
where analyst_name = 'UNASSIGNED';
delete from aml_cases
where case_id in (5);
select * from aml_cases;
select * from aml_alerts;
alter table aml_alerts
add column transaction_ids JSON;
show tables;
select * from case_transactions;
select * from aml_alerts;
delete from aml_alerts
where alert_id = 5;
select * from alert_transactions;
delete from alert_transactions
where alert_id = 5;
delete from aml_alerts
where alert_id = 5;
select * from aml_alerts;
select * from aml_cases;
select * from transactions;
select * from accounts;
alter table accounts
add column customer_name varchar(100);
update accounts a
join customers c on a.customer_id = c.customer_id
set a.customer_name = CONCAT(c.first_name, ' ' ,c.last_name);
select * from accounts;
select * from transactions;
alter table transactions
add column customer_name varchar(100);
UPDATE transactions t
JOIN accounts a ON t.account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
SET t.customer_name = CONCAT(c.first_name, ' ', c.last_name)
WHERE t.transaction_id IS NOT NULL;
select * from transactions;
select * from customers;
insert into customers (
first_name,
last_name,
country,
risk_rating)
values (
'Fidel',
'Castro',
'Cuba',
'HIGH'
);
insert into customers (
first_name,
last_name,
country,
risk_rating
) values (
'Khabib',
'Nurmagomedov',
'Russia',
'HIGH'
);
insert into customers (
first_name,
last_name,
country,
risk_rating)
values (
'Luiz Nazario',
'de Lima',
'Brasil',
'MEDIUM'
);
select * from accounts;
insert into accounts (customer_id, account_type, balance, customer_name)
select customer_id, 'personal', 1000000.00, CONCAT(first_name, ' ' , last_name)
from customers
where first_name in ('Fidel');
select * from accounts;
update accounts
set
	currency = 'USD',
    open_date = '2025-12-31'
where customer_id = 4;
select * from accounts;
insert into accounts (customer_id, account_type, balance, customer_name, currency, open_date)
select customer_id, 'business', 50000.00, CONCAT(first_name, ' ' , last_name), 'EUR', '2024-06-06'
from customers
where first_name = 'Khabib';
select * from accounts;
insert into accounts (customer_id, account_type, balance, customer_name, currency, open_date)
select customer_id, 'personal', 21000.00, CONCAT(first_name, ' ' , last_name), 'EUR', '2024-09-27'
from customers
where first_name = 'Khabib';
select * from accounts;
insert into accounts (customer_id, account_type, balance, customer_name, currency, open_date)
select customer_id, 'personal', 915000.00, CONCAT(first_name, ' ' , last_name), 'USD', '2026-01-17'
from customers
where first_name = 'Luiz Nazario';
select * from accounts;
select * from transactions;
describe transactions;
insert into transactions (account_id, amount, transaction_date, transaction_type, currency, country, customer_name)
values (
5,
46000.00,
'2026-01-14 13:29:20',
'IN',
'USD',
'CU',
'Fidel Castro'
);
select * from transactions;
select * from high_risk_countries;
insert into high_risk_countries (country_code, country_name)
values ('CU', 'Cuba');
select * from high_risk_countries;
select * from accounts;
insert into transactions (account_id, transaction_date, amount, currency, transaction_type, country, customer_name)
values (5, '2026-01-15 21:00:49', 45800.00, 'USD', 'OUT', 'HT', 'Fidel Castro');
select * from accounts;
INSERT INTO aml_alerts (customer_id, account_id, alert_type, alert_reason, transaction_ids, created_at)
SELECT 
    a.customer_id,
    t.account_id,
    'FLOW_THROUGH',
    CONCAT('Flow-through of funds detected on account ', t.account_id, ': incoming TRX followed by an immediate outgoing TRX'),
    JSON_ARRAYAGG(t.transaction_id),
    NOW()
FROM transactions t
JOIN accounts a ON t.account_id = a.account_id
WHERE 
    (t.transaction_type = 'IN' AND t.amount >= 10000.00)
    OR 
    (t.transaction_type = 'OUT' AND t.amount >= 10000.00)
GROUP BY t.account_id
HAVING COUNT(*) >= 2;
select * from aml_alerts;
INSERT INTO aml_alerts (customer_id, account_id, alert_type, alert_reason, transaction_ids, created_at)
SELECT 
    a.customer_id,
    t_in.account_id,
    'FLOW_THROUGH',
    CONCAT('Flow-through of funds detected on account ', t_in.account_id, ': incoming TRX followed by an outgoing TRX within 5 days'),
    JSON_ARRAYAGG(t_all.transaction_id),
    NOW()
FROM transactions t_in
JOIN transactions t_out 
    ON t_in.account_id = t_out.account_id
    AND t_in.transaction_type = 'IN'
    AND t_out.transaction_type = 'OUT'
    AND t_out.amount >= 10000
    AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
JOIN accounts a ON t_in.account_id = a.account_id
JOIN transactions t_all ON t_all.account_id = t_in.account_id
WHERE t_in.amount >= 10000
GROUP BY t_in.account_id
HAVING COUNT(*) >= 2;
select * from accounts;
insert into transactions (account_id, amount, transaction_type, country, transaction_date, customer_name)
values (6, 16280.00, 'OUT', 'AR', '2026-01-19 09:24:59', 'Luiz Nazario de Lima');
INSERT INTO aml_alerts (customer_id, account_id, alert_type, alert_reason, transaction_ids, created_at)
SELECT 
    a.customer_id,
    t_in.account_id,
    'FLOW_THROUGH',
    CONCAT('Flow-through of funds detected on account ', t_in.account_id, ': incoming TRX followed by an outgoing TRX within 5 days'),
    JSON_ARRAYAGG(t_all.transaction_id),
    NOW()
FROM transactions t_in
JOIN transactions t_out 
    ON t_in.account_id = t_out.account_id
    AND t_in.transaction_type = 'IN'
    AND t_out.transaction_type = 'OUT'
    AND t_out.amount >= 10000
    AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
JOIN accounts a ON t_in.account_id = a.account_id
JOIN transactions t_all ON t_all.account_id = t_in.account_id
WHERE t_in.amount >= 10000
GROUP BY t_in.account_id
HAVING COUNT(*) >= 2;
select * from aml_alerts;
SELECT account_id, alert_type, COUNT(*) AS cnt
FROM aml_alerts
GROUP BY account_id, alert_type
HAVING cnt > 1;
select * from aml_alerts;
delete from aml_alerts
where alert_id = 7;
set global event_scheduler = on;
show variables like 'event_scheduler';
CREATE EVENT IF NOT EXISTS flow_through_hourly
ON SCHEDULE EVERY 1 HOUR
STARTS CURRENT_DATE + INTERVAL HOUR(NOW())+1 HOUR
DO
BEGIN
    INSERT INTO aml_alerts (customer_id, account_id, alert_type, alert_reason, transaction_ids, created_at)
    SELECT 
        a.customer_id,
        t_in.account_id,
        'FLOW_THROUGH',
        CONCAT('Flow-through of funds detected on account ', t_in.account_id, ': incoming TRX followed by an outgoing TRX within 5 days'),
        JSON_ARRAYAGG(t_all.transaction_id),
        NOW()
    FROM transactions t_in
    JOIN transactions t_out 
        ON t_in.account_id = t_out.account_id
        AND t_in.transaction_type = 'IN'
        AND t_out.transaction_type = 'OUT'
        AND t_out.amount >= 10000
        AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
    JOIN accounts a ON t_in.account_id = a.account_id
    JOIN transactions t_all ON t_all.account_id = t_in.account_id
    WHERE t_in.amount >= 10000
      AND NOT EXISTS (
          SELECT 1
          FROM aml_alerts al
          WHERE JSON_CONTAINS(al.transaction_ids, CAST(t_in.transaction_id AS JSON)) 
            OR JSON_CONTAINS(al.transaction_ids, CAST(t_out.transaction_id AS JSON))
      )
    GROUP BY t_in.account_id
    HAVING COUNT(*) >= 2;
END;
select * from aml_alerts;
select * from transactions;

show variables like 'event_scheduler';
select * from aml_alerts;
SHOW EVENTS LIKE 'flow_through_hourly';
select * from aml_alerts;
select * from transactions;
select * from customers;
insert into customers (first_name, last_name, country, risk_rating)
values ('Luis', 'Figo', 'PT', 'LOW');
select * from accounts;
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values (7, 'personal', 8000.00, 'EUR', '2024-09-18', 'Luis Figo');
alter table customers
add column company_name varchar(255);
select * from customers;
update customers
set company_name = 'N/A'
where company_name is null;
alter table customers
modify company_name varchar(255) default 'N/A';
select * from customers;
update customers
set company_name = 'Reus Projektbau GmbH' 
where customer_id = 2;
select * from customers;
update customers
set company_name = 'Sambo Academy'
where customer_id = 5;
alter table customers
add column customer_type varchar(20);
update customers
set customer_type = case
	when customer_id in (2,5) then 'business'
    else 'personal'
end;
select * from aml_alerts;
SHOW EVENTS LIKE 'flow_through_hourly';
show events from aml_monitoring;
select * from transactions;
SELECT
    t_in.account_id,
    t_in.transaction_id AS in_trx,
    t_in.amount AS in_amount,
    SUM(t_out.amount) AS total_out_amount,
    COUNT(t_out.transaction_id) AS out_count,
    DATEDIFF(MAX(t_out.transaction_date), t_in.transaction_date) AS days_diff
FROM transactions t_in
JOIN transactions t_out
    ON t_in.account_id = t_out.account_id
WHERE t_in.transaction_type = 'IN'
  AND t_out.transaction_type = 'OUT'
  AND t_in.amount >= 10000
  AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
GROUP BY t_in.transaction_id
HAVING
    SUM(t_out.amount) >= t_in.amount * 0.8
    AND COUNT(t_out.transaction_id) >= 2;
DROP EVENT IF EXISTS flow_through_hourly;
select * from aml_alerts;
select * from transactions;
SHOW EVENTS from aml_monitoring;
select * from customers;
select * from accounts;
insert into customers (first_name, last_name, country, risk_rating, company_name, customer_type)
values ('David', 'Beckham', 'GB', 'LOW', 'Beckham Productions Studio', 'business');
insert into customers (first_name, last_name, country, risk_rating, company_name, customer_type)
values ('Marilyn', 'Monroe', 'US', 'MEDIUM', 'Brows and Lashes by Marilyn', 'business');
insert into customers (first_name, last_name, country, risk_rating, company_name, customer_type)
values ('Felix', 'Trinidad', 'PR', 'HIGH', 'Trinidad and Partners', 'business');
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values (8, 'saving', 173000.00, 'GBP', '2025-02-21', 'David Beckham');
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values (9, 'business', 11742.00, 'USD', '2024-11-30', 'Marilyn Monroe');
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values (10, 'saving', 94000.00, 'USD', '2023-12-02', 'Felix Trinidad');
select * from accounts;
update accounts
set customer_name = 'Reus Projektbau GmbH'
where customer_id = 2;
update accounts
set customer_name = 'Khabib Nurmagomedov'
where customer_id = 5 and account_type = 'personal';
update accounts
set customer_name = 'Beckham Productions Studio'
where customer_id = 8 and account_type = 'business';
update accounts
set customer_name = 'Trinidad and Partners'
where customer_id = 10 and account_type = 'business';
select * from customers;
select * from aml_alerts;
UPDATE aml_alerts
SET transaction_ids = JSON_ARRAY(transaction_id)
WHERE transaction_id IS NOT NULL;
ALTER TABLE aml_alerts
DROP COLUMN transaction_id;
select * from aml_alerts;
show events from aml_monitoring;
select * from transactions;
DROP EVENT IF EXISTS flow_through_hourly;
SELECT
    t_in.account_id,
    JSON_ARRAYAGG(trx.transaction_id) AS transaction_ids
FROM transactions t_in
JOIN transactions t_out
    ON t_in.account_id = t_out.account_id
    AND t_out.transaction_type = 'OUT'
    AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
JOIN (
    SELECT DISTINCT transaction_id, account_id
    FROM transactions
) trx
    ON trx.account_id = t_in.account_id
   AND (
        trx.transaction_id = t_in.transaction_id
        OR trx.transaction_id = t_out.transaction_id
   )
WHERE t_in.transaction_type = 'IN'
  AND t_in.amount >= 10000
GROUP BY t_in.account_id;
select * from aml_cases;
select * from aml_alerts;
SELECT case_id, alert_id, case_status
FROM aml_cases
WHERE alert_id = 13;
UPDATE aml_cases
SET case_status = 'FALSE_POSITIVE'
WHERE case_id = 13;
UPDATE aml_cases
SET
    case_status = 'FALSE_ALERT',
    decision = 'FALSE POSITIVE',
    decision_reason = 'Alert incorrectly generated – incoming transaction was not included in transaction_ids'
WHERE case_id = 13;
select * from aml_cases;
select * from case_transactions;
delete from case_transactions
where case_id = 8;
delete from aml_cases
where alert_id = 7;
select * from aml_alerts;
select * from transactions;
alter table transactions
add column payment_reference varchar(255);
alter table transactions
modify column payment_reference varchar(255) default 'blank';
update transactions
set payment_reference = 'blank'
where payment_reference is null;
update transactions
set payment_reference = 'partial payment for e-scooter 3/3'
where transaction_id = 6;
select * from aml_cases;
update aml_cases
set
	case_status = 'CLOSED',
    analyst_name = 'Jakub Kopiejka',
    decision = 'FALSE POSITIVE',
    decision_reason = 'According to the invoice received from the customer payment was made for an e-scooter',
    closed_at = current_timestamp
where case_id = 6;
select * from aml_cases;
select * from aml_alerts;
select * from transactions;
update aml_cases
set
	case_status = 'ESCALATED',
    analyst_name = 'Liam Brady',
    decision = 'TRUE POSITIVE',
    decision_reason = 'The purpose and the counterparty of the outgoing transaction remain unknown. The customer is a PEP (Minister of Foreign Affairs of Cuba).',
    closed_at = current_timestamp
where case_id = 7;
select * from transactions;
update transactions
set payment_reference = 'Public funds allocated to support socialist states'
where transaction_id = 12;
update transactions
set payment_reference = 'HT1P/00012345/4'
where transaction_id = 13;
alter table transactions
add column counterparty varchar(255);
select * from transactions;
update transactions
set counterparty = 'unknown'
where transaction_id = 13;
update transactions
set counterparty = 'Piaggio & C. S.p.A.'
where transaction_id in(4,5,6);
select * from transactions;
update transactions
set
	payment_reference = 'Financial aid for students',
    counterparty = 'Kosar High-School'
where transaction_id = 11;
select * from aml_cases;
update transactions
set
	payment_reference = 'Payment for construction materials according to the invoice 429/32',
    counterparty = 'Surgutneftegaz'
where transaction_id = 9;
select * from transactions;
update transactions
set
	counterparty = 'Alisar Ailabouni',
    payment_reference = 'xoxo my love'
where transaction_id = 10;
update transactions
set counterparty = case transaction_id
	when 1 then 'Lidl'
    when 2 then 'Vistula'
    when 3 then 'Rossmann'
end
where transaction_id in (1, 2, 3);
select * from aml_cases;
update aml_cases
set closed_at = '2026-01-19 16:58:30'
where case_id = 13;
update aml_cases
set analyst_name = 'Dmitri Pirog'
where case_id = 13;
select * from aml_alerts;
update aml_cases
set
	decision_reason = 'Customer activity consistent with profile. The customer is involved in humanitarian aid in Iran and other Middle-East countries'
where case_id = 2;
update aml_alerts
set
	alert_type = 'UNUSUAL_TRX_PATTERN'
where alert_id = 5;
select * from customers;
describe customers;
insert into customers (first_name, last_name, country, risk_rating, customer_type)
values
('Tupac Amaru', 'Shakur', 'US', 'MEDIUM', 'business'),
('Mila', 'Kunis', 'UA', 'LOW', 'personal'),
('Marion', 'Cotillard', 'FR', 'LOW', 'personal'),
('Florian', 'Homm', 'DE', 'HIGH', 'business'),
('Ana', 'de Armas', 'VE', 'MEDIUM', 'business'),
('Sydney', 'Sweeney', 'US', 'LOW', 'business'),
('Mateusz', 'Morawiecki', 'PL', 'HIGH', 'business'),
('Erislandy', 'Lara', 'CU', 'HIGH', 'personal'),
('Charlie', 'Hunnam', 'GB', 'LOW', 'business'),
('Arsene', 'Wenger', 'MC', 'MEDIUM', 'personal');
select * from customers;
update customers
set company_name = case customer_id
	when 11 then 'Tupac Entertainment Ltd'
    when 14 then 'Finanzberatung Homm GmbH'
    when 15 then 'Ceramica Carabobo'
    when 16 then 'Surgery Sydney'
    when 17 then 'Kancelaria Notarialna Mateusz Morawiecki'
    when 19 then 'Hools Apparel'
end
where customer_id in (11, 14, 15, 16, 17, 19);
select * from customers;
select * from accounts;
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values
(11, 'business', 270000.00, 'USD', '2024-07-15', 'Tupac Entertainment Ltd'),
(12, 'personal', 22385.00, 'UAH', '2025-04-29', 'Mila Kunis'),
(13, 'personal', 41491.00, 'EUR', '2023-11-07', 'Marion Cotillard'),
(14, 'business', 10000.00, 'EUR', '2026-01-20', 'Finanzberatung Homm GmbH'),
(13, 'saving', 83297.00, 'EUR', '2023-11-08', 'Marion Cotillard'),
(12, 'saving', 12530.00, 'UAH', '2025-05-01', 'Mila Kunis'),
(15, 'business', 3900000.00, 'USD', '2024-03-20', 'Ceramica Carabobo'),
(16, 'business', 200000.00, 'USD', '2024-06-06', 'Surgery Sydney'),
(16, 'personal', 39000.00, 'USD', '2024-07-04', 'Sydney Sweeney'),
(16, 'saving', 51250.00, 'USD', '2024-06-30', 'Sydney Sweeney'),
(17, 'business', 115279.00, 'PLN', '2025-05-17', 'Kancelaria Notarialna Mateusz Morawiecki'),
(17, 'personal', 266220.00, 'PLN', '2025-05-13', 'Mateusz Morawiecki'),
(18, 'personal', 13110.00, 'USD', '2024-08-12', 'Erislandy Lara'),
(19, 'business', 52428.00, 'GBP', '2025-09-16', 'Hools Apparel'),
(19, 'personal', 21228.00, 'GBP', '2025-08-29', 'Charlie Hunnam'),
(19, 'saving', 10500.00, 'GBP', '2025-08-30', 'Charlie Hunnam'),
(20, 'personal', 914000.00, 'EUR', '2025-12-12', 'Arsene Wenger');
select * from customers;
insert into customers (first_name, last_name, country, risk_rating, customer_type)
values
('Abou', 'Diaby', 'FR', 'MEDIUM', 'business'),
('Silvio', 'Berlusconi', 'IT', 'HIGH', 'business'),
('Morgan', 'Freeman', 'US', 'LOW', 'personal'),
('Tatiana', 'Novaeva', 'RU', 'MEDIUM', 'business'),
('Ricardo', 'Quaresma', 'PT', 'LOW', 'personal'),
('Mesut', 'Gundogan', 'TR', 'MEDIUM', 'business'),
('Jesse', 'James', 'GB', 'LOW', 'business'),
('Martina', 'Hernandez', 'ES', 'LOW', 'personal'),
('Santiago', 'Munez', 'ES', 'LOW', 'personal'),
('Konstantinos', 'Varoufakis', 'GR', 'MEDIUM', 'business');
select * from customers;
select * from accounts;
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values
(21, 'business', 34800.00, 'EUR', '2024-04-14', 'Diaby Healthcare Solutions'),
(21, 'personal', 21220.00, 'EUR', '2024-04-24', 'Abou Diaby'),
(22, 'business', 67900.00, 'EUR', '2024-06-15', 'Ristorante Bunga Bunga'),
(23, 'personal', 3860.00, 'USD', '2026-01-05', 'Morgan Freeman'),
(24, 'business', 12930.00, 'EUR', '2023-12-04', 'Siberian Massage and Spa'),
(24, 'personal', 5000.00, 'EUR', '2024-02-12', 'Tatiana Novaeva'),
(25, 'personal', 400.00, 'EUR', '2025-05-16', 'Ricardo Quaresma'),
(25, 'saving', 40400.00, 'EUR', '2025-05-18', 'Ricardo Quaresma'),
(26, 'business', 13200.00, 'EUR', '2025-09-13', 'Doner von Gundo'),
(26, 'business', 56500.00, 'TRY', '2025-10-09', 'Doner von Gundo'),
(27, 'business', 73720.00, 'GBP', '2024-09-10', 'Jesse Maintenance and Repair'),
(27, 'business', 21600.00, 'EUR', '2024-11-12', 'Jesse Maintenance and Repair'),
(28, 'personal', 5500.00, 'EUR', '2025-01-30', 'Martina Hernandez'),
(28, 'saving', 2370.00, 'EUR', '2025-03-14', 'Martina Hernandez'),
(29, 'personal', 19610.00, 'EUR', '2025-09-09', 'Santiago Munez'),
(29, 'personal', 4000.00, 'USD', '2025-09-19', 'Santiago Munez'),
(30, 'business', 54721.00, 'EUR', '2024-10-10', 'Mykonos Luxury Car Rentals');
insert into accounts (customer_id, account_type, balance, currency, open_date, customer_name)
values (30, 'personal', 13700.00, 'EUR', '2025-02-24', 'Konstantinos Varoufakis');
select * from customers;
select * from accounts;
update customers
set company_name = case customer_id
	when 21 then 'Diaby Healthcare Solutions'
    when 22 then 'Ristorante Bunga Bunga'
    when 24 then 'Siberian Massage and Spa'
    when 26 then 'Doner von Gundo'
    when 27 then 'Jesse Maintenance and Repair'
    when 30 then 'Mykonos Luxury Car Rentals'
end
where customer_id in (21, 22, 24, 26, 27, 30);
select * from customers;
select * from accounts;
select * from customers;
alter table customers
add column customer_name varchar(255);
update customers
set customer_name = case
	when customer_type = 'business' then company_name
    else CONCAT (first_name, ' ' , last_name)
end;
select
	a.customer_id
from accounts a
group by a.customer_id
having count(distinct a.account_type) > 1;
insert into customers (customer_name, customer_type)
select
	customer_name,
    'business'
from customers
where customer_id = 5;
select * from customers;
select * from accounts;
update accounts
set customer_id = 31
where customer_id = 5
	and account_type = 'business';
SELECT
    a.customer_id
FROM accounts a
GROUP BY a.customer_id
HAVING COUNT(DISTINCT a.account_type) > 1;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 8;
update accounts
set customer_id = 32
where customer_id = 8
	and account_type = 'business';
SELECT
    a.customer_id
FROM accounts a
GROUP BY a.customer_id
HAVING COUNT(DISTINCT a.account_type) > 1;
select * from accounts;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 10;
UPDATE accounts
SET customer_id = 33
WHERE customer_id = 10
  AND account_type = 'business';
  select * from accounts;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 16;
UPDATE accounts
SET customer_id = 34
WHERE customer_id = 16
  AND account_type = 'business';
select * from accounts;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 17;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 17;
select * from accounts;
delete from customers
where customer_id in (36, 37);
UPDATE accounts
SET customer_id = 35
WHERE customer_id = 17
  AND account_type = 'business';
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 19;
select * from customers;
UPDATE accounts
SET customer_id = 38
WHERE customer_id = 19
  AND account_type = 'business';
select * from accounts;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 21;
select * from customers;
UPDATE accounts
SET customer_id = 39
WHERE customer_id = 21
  AND account_type = 'business';
select * from accounts;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 24;
UPDATE accounts
SET customer_id = 40
WHERE customer_id = 24
  AND account_type = 'business';
select * from accounts;
INSERT INTO customers (customer_name, customer_type)
SELECT
    customer_name,
    'business'
FROM customers
WHERE customer_id = 30;
UPDATE accounts
SET customer_id = 41
WHERE customer_id = 30
  AND account_type = 'business';
select * from customers;
ALTER TABLE customers
DROP COLUMN first_name,
DROP COLUMN last_name,
DROP COLUMN company_name;
select * from customers;
update customers
set country = case customer_id
	when 4 then 'CU'
    when 5 then 'RU'
    when 6 then 'BR'
end
where customer_id in (4,5,6);
select * from customers;
select * from accounts;
update customers
set
	customer_name = 'Konstantinos Varoufakis',
    customer_type = 'personal'
where customer_id = 30;
select * from accounts;
CREATE TABLE beneficial_owners (
    bo_id INT AUTO_INCREMENT PRIMARY KEY,

    customer_id INT NOT NULL,
    
    bo_name VARCHAR(255) NOT NULL,
    ownership_percent DECIMAL(5,2) CHECK (ownership_percent > 0 AND ownership_percent <= 100),

    country CHAR(2),
    is_pep BOOLEAN DEFAULT FALSE,

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_bo_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON DELETE CASCADE
);
select * from beneficial_owners;
select * from customers;
INSERT INTO beneficial_owners (
    customer_id,
    bo_name,
    ownership_percent,
    country,
    is_pep
)
VALUES
	(2, 'Marco Reus', 100.00, 'DE', FALSE),
    (9, 'Marilyn Monroe', 100.00, 'US', FALSE),
    (11, 'Tupac Amaru Shakur', 75.00, 'US', FALSE),
    (11, 'Biggie Smalls', 25.00, 'US', FALSE),
    (14, 'Florian Homm', 100.00, 'DE', TRUE),
    (15, 'Ana de Armas', 30.00, 'CU', FALSE),
    (15, 'Jennifer Lopez', 30.00, 'US', FALSE),
    (15, 'Shakira Pique', 40.00, 'CO', FALSE),
    (22, 'Silvio Berlusconi', 100.00, 'IT', TRUE),
    (26, 'Mesut Gundogan', 100.00, 'TR', FALSE),
    (27, 'Jesse James', 70.00, 'GB', FALSE),
    (27, 'Wayne Rooney', 30.00, 'GB', FALSE),
    (31, 'Khabib Nurmagomedov', 75.00, 'RU', FALSE),
    (31, 'Islam Machaczew', 25.00, 'RU', FALSE),
    (32, 'David Beckham', 50.00, 'GB', FALSE),
    (32, 'Victoria Beckham', 50.00, 'GB', FALSE),
    (33, 'Felix Trinidad', 100.00, 'PR', FALSE),
    (34, 'Sydney Sweeney', 100.00, 'US', FALSE),
    (35, 'Mateusz Morawiecki', 100.00, 'PL', TRUE),
    (38, 'Charlie Hunnam', 60.00, 'GB', FALSE),
    (38, 'Brad Pitt', 40.00, 'US', FALSE),
    (39, 'Abou Diaby', 75.00, 'FR', FALSE),
    (39, 'Hatem Ben Arfa', 25.00, 'FR', FALSE),
    (40, 'Tatiana Novaeva', 75.00, 'RU', FALSE),
    (40, 'Dmitri Miedwiediew', 25.00, 'RU', TRUE),
    (41, 'Konstantions Varoufakis', 100.00, 'GR', FALSE);
    select * from beneficial_owners;
    alter table customers
    modify column UBO varchar (1000);
    UPDATE customers c
LEFT JOIN (
    SELECT customer_id, GROUP_CONCAT(bo_name SEPARATOR ', ') AS bo_list
    FROM beneficial_owners
    GROUP BY customer_id
) bo
ON c.customer_id = bo.customer_id
SET c.UBO = CASE 
                WHEN c.customer_type = 'business' THEN bo.bo_list
                ELSE 'N/A'
            END;
SELECT customer_id, customer_name, customer_type, UBO
FROM customers;
select * from beneficial_owners;
select * from transactions;
select * from aml_alerts;
select * from aml_cases;
show events from aml_monitoring;
SELECT 
    t_in.account_id,
    t_in.transaction_id AS incoming_trx,
    t_out.transaction_id AS outgoing_trx,
    t_in.amount AS incoming_amount,
    t_out.amount AS outgoing_amount
FROM transactions t_in
JOIN transactions t_out 
    ON t_in.account_id = t_out.account_id
    AND t_in.transaction_type = 'IN'
    AND t_out.transaction_type = 'OUT'
    AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
WHERE t_in.amount >= 10000;
select * from aml_alerts;
select * from transactions;
update transactions
set 
	counterparty = 'Pablo Nuno de Lima'
where transaction_id = 16;
show tables from aml_monitoring;
use aml_monitoring;
select count(*) as number_of_tables
from information_schema.tables
where table_schema = DATABASE();
select * from aml_alerts;
show variables like 'event_scheduler';
show events like 'event_structuring_hourly';
SELECT
    t.account_id,
    COUNT(*) AS trx_count,
    SUM(t.amount) AS total_amount
FROM transactions t
WHERE t.transaction_date >= NOW() - INTERVAL 10 DAY
  AND t.amount < 10000
GROUP BY t.account_id
HAVING COUNT(*) >= 3
   AND SUM(t.amount) > 10000;
select * from transactions;
alter table transactions
rename column country to counterparty_country;
select * from transactions;
select * from high_risk_countries;
insert into high_risk_countries (country_code, country_name)
values ('VE', 'Venezuela');
insert into high_risk_countries (country_code, country_name)
values ('MM', 'Myanmar');
show events like 'event_high_risk_incoming_hourly';
select * from transactions;
select * from accounts;
update transactions
set account_id = 8
where transaction_id in (14, 15, 16);
update transactions
set customer_name = 'Reus Projektbau GmbH'
where account_id = 2;
insert into transactions (account_id, transaction_date, amount, currency, transaction_type, counterparty_country, customer_name, payment_reference, counterparty)
values
(9, '2026-01-22 15:21:56', 5000.00, 'EUR', 'IN', 'MM', 'Luis Figo', 'Real Estate 281/56 Grand Falls', 'Min Aung Hlaing'),
(10, '2025-07-18 12:07:46', 9000.00, 'GBP', 'IN', 'US', 'Beckham Productions Studio', 'Part Payment', 'Romeo Novels'),
(10, '2025-07-20 07:25:45', 8700.00, 'GBP', 'IN', 'US', 'Beckham Productions Studio', 'Part Payment 2/3', 'Romeo Novels'),
(10, '2025-07-23 09:21:24', 8800.00, 'GBP', 'IN', 'US', 'Beckham Productions Studio', 'Final Payment', 'Romeo Novels'),
(11, '2025-09-13 11:56:20', 12500.00, 'GBP', 'OUT', 'ES', 'David Beckham', 'for my Lovebird', 'Victoria Beckham'),
(12, '2025-08-15 09:17:16', 20000.00, 'GBP', 'IN', 'GB', 'David Beckham', 'own transfer', 'Beckham Productions Studio'),
(13, '2024-12-03 12:05:08', 2100.00, 'USD', 'IN', 'US', 'Brows and Lashes by Marilyn', 'invoice 12/03', 'Marriet Hammington'),
(13, '2024-12-12 09:59:40', 15000.00, 'USD', 'OUT', 'US', 'Brows and Lashes by Marilyn', 'Work Supplies', 'Beauty Accessoires Inc.'),
(14, '2025-12-12 12:56:01', 52300.00, 'USD', 'IN', 'HT', 'Trinidad and Partners', 'attorney fees / divorce case', 'Luisa Montegri'),
(16, '2025-12-17 09:16:18', 124700.00, 'USD', 'OUT', 'US', 'Tupac Entertainment Ltd', 'Donation', 'Afeni Shakur Foundation'),
(17, '2026-01-25 17:00:00', 7000.00, 'UAH', 'OUT', 'RU', 'Mila Kunis', 'blank', 'Rosnieft'),
(17, '2026-01-26 17:00:00', 7500.00, 'UAH', 'OUT', 'RU', 'Mila Kunis', 'blank', 'Roman Abramovich'),
(17, '2026-01-27 17:00:00', 8100.00, 'UAH', 'OUT', 'RU', 'Mila Kunis', 'blank', 'Alisher Usmanov'),
(18, '2026-01-15 11:33:00', 230.00, 'EUR', 'OUT', 'FR', 'Marion Cotillard', 'FEE', 'Louvre Museum'),
(19, '2026-01-29 10:12:11', 19000.00, 'EUR', 'IN', 'VE', 'Finanzberatung Homm GmbH', 'Financial Services from 18th of November', 'Joga Bonito SRL'),
(20, '2024-02-16 13:41:29', 9900.00, 'EUR', 'IN', 'FR', 'Marion Cotillard', 'Cash deposit', 'Marion Cotillard'),
(20, '2024-02-19 09:31:00', 9800.00, 'EUR', 'IN', 'FR', 'Marion Cotillard', 'Cash deposit', 'Marion Cotillard'),
(20, '2024-02-21 16:15:30', 9550.00, 'EUR', 'IN', 'FR', 'Marion Cotillard', 'Cash deposit', 'Marion Cotillard'),
(22, '2024-09-19 20:19:04', 1100000.00, 'USD', 'IN', 'US', 'Ceramica Carabobo', 'blank', 'Donald Trump'),
(22, '2024-09-20 21:10:07', 1050000.00, 'USD', 'OUT', 'CO', 'Ceramica Carabobo', 'Real Estate Investment', 'Gutierrez Apartments Ltd');
insert into transactions (account_id, transaction_date, amount, currency, transaction_type, counterparty_country, customer_name, payment_reference, counterparty)
values
(23, '2024-08-14 10:09:30', 10000.00, 'USD', 'OUT', 'AU', 'Surgery Sydney', 'invoice 194/24', 'Aussie Medical Devices'),
(23, '2024-08-14 13:12:39', 4860.00, 'USD', 'OUT', 'AU', 'Surgery Sydney', 'freight services S.Sydney', 'Paco Logistics Ltd'),
(24, '2025-12-31 18:11:24', 180.00, 'USD', 'OUT', 'US', 'Sydney Sweeney', 'invoice 296834/152', 'Atlanta Beverages'),
(24, '2025-06-30 12:00:05', 520.00, 'USD', 'IN', 'US', 'Sydney Sweeney', 'Reimbursement', 'Collin Farrell'),
(26, '2026-01-19 12:43:41', 28000.00, 'PLN', 'IN', 'PL', 'Kancelaria Notarialna Mateusz Morawiecki', 'Taksa Notarialna - Wesola 43', 'Sebastian Fabijanski'),
(26, '2026-01-19 13:00:00', 28000.00, 'PLN', 'OUT', 'PL', 'Kancelaria Notarialna Mateusz Morawiecki', 'blank', 'Iwona Morawiecka'),
(27, '2025-06-11 12:48:12', 6000.00, 'PLN', 'IN', 'PL', 'Mateusz Morawiecki', 'Cash deposit', 'Mateusz Morawiecki'),
(27, '2025-06-11 13:48:12', 6000.00, 'PLN', 'IN', 'PL', 'Mateusz Morawiecki', 'Cash deposit', 'Mateusz Morawiecki'),
(27, '2025-06-11 14:48:12', 6000.00, 'PLN', 'IN', 'PL', 'Mateusz Morawiecki', 'Cash deposit', 'Mateusz Morawiecki'),
(27, '2025-06-11 15:48:12', 6000.00, 'PLN', 'IN', 'PL', 'Mateusz Morawiecki', 'Cash deposit', 'Mateusz Morawiecki'),
(28, '2026-01-04 14:27:00', 12150.00, 'USD', 'OUT', 'CU', 'Erislandy Lara', 'Family support', 'Ana Lara'),
(29, '2025-10-24 10:12:34', 600.00, 'GBP', 'IN', 'GB', 'Hools Apparel', 'Hoodie XXL Beige', 'Scott Palmer'),
(29, '2025-11-01 12:09:03', 525.00, 'GBP', 'IN', 'GB', 'Hools Apparel', 'Underpants Black', 'Ian Wright'), 
(29, '2025-10-28 14:00:05', 480.00, 'GBP', 'IN', 'GB', 'Hools Apparel', 'Shirt Size L Blue', 'Shaun Mendes'),
(30, '2025-09-10 10:12:59', 20000.00, 'GBP', 'IN', 'GB', 'Charlie Hunnam', 'blank', 'Jessica Mercedes'),
(30, '2025-09-11 16:18:10', 19500.00, 'GBP', 'OUT', 'US', 'Charlie Hunnam', 'Ford GT', 'Maxi Cars');
select * from accounts;
INSERT INTO transactions (
    account_id, transaction_date, amount, currency, transaction_type,
    counterparty_country, customer_name, payment_reference, counterparty
)
VALUES
(32, '2026-01-14 12:00:00', 32800.00, 'EUR', 'IN', 'FR', 'Arsene Wenger', 'FT001', 'DAZN'),
(32, '2026-01-15 12:00:00', 15190.00, 'EUR', 'OUT', 'FR', 'Arsene Wenger', 'FT002', 'Real Madrid'),
(32, '2026-01-16 12:00:00', 16280.00, 'EUR', 'OUT', 'FR', 'Arsene Wenger', 'FT003', 'Real Madrid'),
(32, '2026-01-17 12:00:00', 5000.00, 'EUR', 'IN', 'DE', 'Arsene Wenger', 'TR001', 'European Football Federation'),
(33, '2026-01-18 12:00:00', 4000.00, 'USD', 'IN', 'PL', 'Diaby Healthcare Solutions', 'ST001', 'Maciej Rybus'),
(33, '2026-01-19 12:00:00', 3500.00, 'USD', 'IN', 'PL', 'Diaby Healthcare Solutions', 'ST002', 'Piotr Zielinski'),
(33, '2026-01-20 12:00:00', 3000.00, 'USD', 'IN', 'PL', 'Diaby Healthcare Solutions', 'ST003', 'Kamil Grosicki'),
(33, '2026-01-21 12:00:00', 2000.00, 'USD', 'OUT', 'PL', 'Diaby Healthcare Solutions', 'ST004', 'Pharma Supply'),
(34, '2026-01-22 12:00:00', 12000.00, 'EUR', 'IN', 'RU', 'Abou Diaby', 'HR001', 'Russian Export LLC'),
(34, '2026-01-23 12:00:00', 5000.00, 'EUR', 'OUT', 'DE', 'Abou Diaby', 'TR005', 'Berliner Ltd'),
(35, '2026-01-20 12:00:00', 7000.00, 'EUR', 'IN', 'IT', 'Ristorante Bunga Bunga', 'Catering', 'Joao Pedro'),
(35, '2026-01-21 12:00:00', 3000.00, 'EUR', 'OUT', 'IT', 'Ristorante Bunga Bunga', 'Supplies', 'Italian Kitchen Supplies SRL'),
(36, '2026-01-18 12:00:00', 3000.00, 'USD', 'IN', 'US', 'Morgan Freeman', 'ST005', 'Beneditto Perloni'),
(36, '2026-01-19 12:00:00', 4000.00, 'USD', 'IN', 'US', 'Morgan Freeman', 'ST006', 'Dwight Yorke'),
(36, '2026-01-20 12:00:00', 3500.00, 'USD', 'IN', 'US', 'Morgan Freeman', 'ST007', 'Marshall Mathers'),
(37, '2026-01-19 12:00:00', 15000.00, 'USD', 'IN', 'IR', 'Siberian Massage and Spa', 'HR002', 'Iran Trade Co'),
(37, '2026-01-20', 5000.00, 'USD', 'OUT', 'RU', 'Siberian Massage and Spa', 'TR008', 'Murat Gassiev'),
(38, '2026-01-15 12:00:00', 14000.00, 'EUR', 'IN', 'RU', 'Tatiana Novaeva', 'FT004', 'Gazprombank'),
(38, '2026-01-16 12:00:00', 13800.00, 'EUR', 'OUT', 'RU', 'Tatiana Novaeva', 'FT005', 'Sberbank'),
(39, '2026-01-20 12:00:00', 5000.00, 'EUR', 'IN', 'PT', 'Ricardo Quaresma', 'TR009', 'Marita Quaresma'),
(39, '2026-01-21 12:00:00', 4000.00, 'EUR', 'OUT', 'PT', 'Ricardo Quaresma', 'TR010', 'Joao Quaresma'),
(41, '2026-01-18 12:00:00', 3000.00, 'EUR', 'IN', 'DE', 'Doner von Gundo', 'ST008', 'Helga Rosenberg'),
(41, '2026-01-19 12:00:00', 3500.00, 'EUR', 'IN', 'DE', 'Doner von Gundo', 'ST009', 'Helmut Schmidt'),
(42, '2026-01-20 12:00:00', 4000.00, 'EUR', 'IN', 'DE', 'Doner von Gundo', 'ST010', 'Mufasa al Gambani'),
(43, '2026-01-21 12:00:00', 20000.00, 'USD', 'IN', 'KP', 'Jesse Maintenance and Repair', 'HR003', 'North Korea Corp'),
(44, '2026-01-22 12:00:00', 18000.00, 'USD', 'IN', 'SY', 'Jesse Maintenance and Repair', 'HR004', 'Syria Business'),
(45, '2026-01-20 12:00:00', 7000.00, 'EUR', 'IN', 'ES', 'Martina Hernandez', 'TR011', 'Pablo Escobar'),
(47, '2026-01-15 12:00:00', 16000.00, 'EUR', 'IN', 'BR', 'Santiago Munez', 'FT006', 'Terrabanco'),
(47, '2026-01-16 12:00:00', 15500.00, 'EUR', 'OUT', 'BR', 'Santiago Munez', 'blank', 'Ricardo Kaka'),
(48, '2026-01-17 12:00:00', 5000.00, 'EUR', 'IN', 'BR', 'Santiago Munez', 'TR012', 'Banco Primeira'),
(49, '2026-01-23 12:00:00', 12000.00, 'EUR', 'IN', 'RU', 'Mykonos Luxury Car Rentals', 'HR005', 'Russian Export LLC'),
(50, '2026-01-20 12:00:00', 9000.00, 'EUR', 'IN', 'GR', 'Konstantinos Varoufakis', 'TR013', 'Mavros Karagounis');
select * from aml_alerts;
select * from aml_cases;
select * from transactions;
describe transactions;
alter table transactions
modify counterparty_country char(2)
after counterparty;
SHOW CREATE TABLE transactions;
select * from customers;
select * from accounts;
select * from transactions;
update transactions
set currency = 'USD'
where account_id = 8;
select * from transactions;
select * from aml_alerts;
select * from aml_cases;
update aml_cases
set
	case_status = 'CLOSED',
    analyst_name = 'Gennady Golovkin',
    decision = 'FALSE_POSITIVE',
    decision_reason = 'The case has already been solved (see case_id 6)',
    closed_at = current_timestamp
where case_id = 14;
select * from aml_alerts;
select * from transactions;
select * from aml_cases;
update aml_cases
set
	case_status = 'ESCALATED',
    analyst_name = 'Jakub Kopiejka',
    decision_reason = 'Rapid movement of funds between high-risk countries. Almost the entire amount was immediately transfered away.',
    closed_at = current_timestamp
where case_id = 16;
alter table aml_cases
drop column decision;
alter table aml_cases
rename column case_status to decision;
select * from aml_cases;
describe aml_cases;
alter table aml_cases
modify decision varchar(20)
after analyst_name;
select * from aml_cases;
select * from aml_alerts;
select * from transactions;
update aml_cases
set
	closed_at = current_timestamp
where case_id = 17;
update aml_cases
set
	analyst_name = 'Dmitri Pirog',
    decision = 'CLOSED', 
    decision_reason = 'The incoming transfer is consistent with the customer profile. In addition the power of attorney was provided upon request.',
    closed_at = current_timestamp
where case_id = 18;
update aml_cases
set
	analyst_name = 'Gennady Golovkin',
    decision = 'CLOSED', 
    decision_reason = 'The transaction is consistent with the customers background',
    closed_at = current_timestamp
where case_id = 19;
select * from aml_alerts;
select * from transactions;
select * from aml_cases;
update aml_cases
set
	analyst_name = 'Jakub Kopiejka',
    decision = 'ESCALATED',
    decision_reason = 'Sanctioned counterparties. Unclear purpose of the transactions',
    closed_at = current_timestamp
where case_id = 20;
select * from aml_cases;
select * from aml_alerts;
select * from transactions;
update aml_cases
set
	analyst_name = 'Liam Brady',
    decision = 'ESCALATED',
    decision_reason = 'Unknown source of funds and purpose of the transaction as the counterparty does not match the customers background',
    closed_at = current_timestamp
where case_id = 24;
update aml_cases
set
	analyst_name = 'Dmitri Pirog',
    decision = 'CLOSED',
    decision_reason = 'Customer acitivity consistent with profile and nature of business',
    closed_at = current_timestamp
where case_id = 25;
update aml_cases
set
    decision_reason = 'Flow-through of funds detected.The customer is expected to provide relevant documentation regarding the purpose of the transactions'
where case_id = 26;
select * from aml_cases;
select * from aml_alerts;
select * from transactions;
update aml_cases
set
	decision = 'IN_PROCESS'
where case_id = 26;
select * from transactions;
select * from customers;
select * from aml_alerts;
show triggers;
show create trigger trg_alert_to_case;
drop trigger if exists trg_alert_to_case;
INSERT INTO aml_alerts (
    customer_id,
    account_id,
    alert_type,
    alert_reason,
    transaction_ids,
    created_at
)
VALUES (
    11,
    16,
    'SUSP_REM_INFO',
    'Suspicious Remittance Info',
    JSON_ARRAY(26),
    NOW()
);
select * from aml_cases;
select * from transactions;
select * from aml_alerts;
select * from customers;
INSERT INTO aml_alerts (
    customer_id,
    account_id,
    alert_type,
    alert_reason,
    transaction_ids,
    created_at
)
VALUES (
    17,
    27,
    'STRUCTURING',
    'Structuring detected on account 27: 4 cash deposits under the reporting threshold',
    JSON_ARRAY(43,44,45,46),
    NOW()
);


    
    


    

    


	
    
    



    
    























    

    








	






















