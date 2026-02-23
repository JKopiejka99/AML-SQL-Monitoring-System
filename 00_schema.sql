-- 00_schema.sql
-- DDL: create database and schema objects

CREATE DATABASE IF NOT EXISTS aml_monitoring;
USE aml_monitoring;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(255),
    country VARCHAR(50),
    risk_rating VARCHAR(10),
    customer_type VARCHAR(20),
    UBO VARCHAR(1000),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(20),
    balance DECIMAL(12,2),
    currency CHAR(3),
    open_date DATE,
    customer_name VARCHAR(255),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT,
    transaction_date DATETIME,
    amount DECIMAL(12,2),
    currency CHAR(3),
    transaction_type VARCHAR(10),
    counterparty VARCHAR(255),
    counterparty_country CHAR(2),
    payment_reference VARCHAR(255) DEFAULT 'blank',
    customer_name VARCHAR(255),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);

CREATE TABLE IF NOT EXISTS high_risk_countries (
    country_code CHAR(2) PRIMARY KEY,
    country_name VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS aml_alerts (
    alert_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    account_id INT,
    transaction_ids JSON,
    alert_type VARCHAR(50),
    alert_reason VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS alert_transactions (
    alert_id INT NOT NULL,
    transaction_id INT NOT NULL,
    PRIMARY KEY (alert_id, transaction_id),
    FOREIGN KEY (alert_id) REFERENCES aml_alerts(alert_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

CREATE TABLE IF NOT EXISTS aml_cases (
    case_id INT AUTO_INCREMENT PRIMARY KEY,
    alert_id INT,
    analyst_name VARCHAR(100),
    decision VARCHAR(50),
    decision_reason VARCHAR(255),
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    closed_at DATETIME
);

CREATE TABLE IF NOT EXISTS case_transactions (
    case_id INT NOT NULL,
    transaction_id INT NOT NULL,
    PRIMARY KEY (case_id, transaction_id),
    FOREIGN KEY (case_id) REFERENCES aml_cases(case_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id)
);

CREATE TABLE IF NOT EXISTS beneficial_owners (
    bo_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    bo_name VARCHAR(255) NOT NULL,
    ownership_percent DECIMAL(5,2) CHECK (ownership_percent > 0 AND ownership_percent <= 100),
    country CHAR(2),
    is_pep BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_bo_customer FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

-- Notes: Triggers and Events are stored in sql/triggers/ and sql/events/ and should be applied after schema and seed.
