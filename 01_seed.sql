-- 01_seed.sql
-- Sample/reference data for demos

USE aml_monitoring;

-- Customers (representative sample)
INSERT INTO customers (customer_id, customer_name, country, risk_rating, customer_type)
VALUES
(1, 'Jan Kowalski', 'PL', 'LOW', 'personal'),
(2, 'Marco Reus', 'DE', 'LOW', 'personal'),
(3, 'Damiano David', 'IT', 'MEDIUM', 'personal'),
(4, 'Fidel Castro', 'CU', 'HIGH', 'personal'),
(5, 'Khabib Nurmagomedov', 'RU', 'HIGH', 'personal');

-- Accounts
INSERT INTO accounts (account_id, customer_id, account_type, balance, currency, open_date, customer_name)
VALUES
(1, 1, 'personal', 100000.00, 'EUR', '2026-03-27', 'Jan Kowalski'),
(2, 2, 'business', 50000.00, 'EUR', '2024-06-06', 'Reus Projektbau GmbH'),
(3, 3, 'personal', 915000.00, 'USD', '2026-01-17', 'Damiano David'),
(5, 4, 'personal', 1000000.00, 'USD', '2025-12-31', 'Fidel Castro');

-- High risk countries
INSERT INTO high_risk_countries (country_code, country_name) VALUES
('IR','Iran'),('KP','North Korea'),('SY','Syria'),('RU','Russia'),('HT','Haiti'),('CU','Cuba');

-- Beneficial owners (small sample)
INSERT INTO beneficial_owners (customer_id, bo_name, ownership_percent, country, is_pep)
VALUES
(2, 'Marco Reus', 100.00, 'DE', FALSE),
(14, 'Florian Homm', 100.00, 'DE', TRUE),
(31, 'Khabib Nurmagomedov', 75.00, 'RU', FALSE);

-- Transactions (examples that will trigger alerts)
INSERT INTO transactions (account_id, transaction_date, amount, currency, transaction_type, counterparty_country, customer_name, payment_reference, counterparty)
VALUES
(1, '2026-01-02 10:15:43', 400.00, 'PLN', 'OUT', 'PL', 'Jan Kowalski', 'purchase', 'Lidl'),
(1, '2026-01-05 16:45:21', 1100.00, 'PLN', 'OUT', 'PL', 'Jan Kowalski', 'purchase', 'Vistula'),
(1, '2026-01-06 12:01:33', 70.00, 'PLN', 'IN', 'PL', 'Jan Kowalski', 'refund', 'Rossmann'),
(5, '2026-01-14 13:29:20', 46000.00, 'USD', 'IN', 'CU', 'Fidel Castro', 'FT001', 'DAZN'),
(5, '2026-01-15 21:00:49', 45800.00, 'USD', 'OUT', 'HT', 'Fidel Castro', 'FT002', 'Luisa Montegri'),
(3, '2026-04-04 14:44:44', 9800.00, 'EUR', 'OUT', 'IT', 'Damiano David', 'TRX', 'Piaggio & C. S.p.A.');

-- Small example alerts to show relationships
INSERT INTO aml_alerts (customer_id, account_id, transaction_ids, alert_type, alert_reason)
VALUES
(5, 5, JSON_ARRAY(4,5), 'FLOW_THROUGH', 'Example flow-through'),
(3, 3, JSON_ARRAY(6), 'STRUCTURING', 'Example structuring');

-- Extended seed (additional demo data extracted from original project)
-- Insert extended customers with explicit IDs to keep seed deterministic
INSERT INTO customers (customer_id, customer_name, country, risk_rating, customer_type)
VALUES
(6, 'Luis Figo', 'PT', 'LOW', 'personal'),
(7, 'David Beckham', 'GB', 'LOW', 'business'),
(8, 'Marilyn Monroe', 'US', 'MEDIUM', 'business'),
(9, 'Felix Trinidad', 'PR', 'HIGH', 'business');

-- Create accounts with explicit account_id values for the demo customers
INSERT INTO accounts (account_id, customer_id, account_type, balance, currency, open_date, customer_name)
VALUES
(6, 6, 'personal', 8000.00, 'EUR', '2024-09-18', 'Luis Figo'),
(7, 7, 'business', 173000.00, 'GBP', '2025-02-21', 'David Beckham');

-- Add transactions referencing the explicit account IDs above
INSERT INTO transactions (account_id, transaction_date, amount, currency, transaction_type, counterparty_country, customer_name, payment_reference, counterparty)
VALUES
(6, '2026-01-22 15:21:56', 5000.00, 'EUR', 'IN', 'MM', 'Luis Figo', 'Real Estate 281/56 Grand Falls', 'Min Aung Hlaing'),
(7, '2025-07-18 12:07:46', 9000.00, 'GBP', 'IN', 'US', 'Beckham Productions Studio', 'Part Payment', 'Romeo Novels');
