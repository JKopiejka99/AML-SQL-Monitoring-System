# SQL-Based AML Monitoring System

## Overview
This project simulates an Anti-Money Laundering (AML) transaction monitoring system built in MySQL.

It includes automated detection mechanisms for:

- Structuring (3+ transactions below 10k totaling above 10k within 10 days)
- Flow Through of Funds
- High-Risk Country Exposure

## Architecture

Transactions → Event Scheduler → AML Alerts → Trigger → AML Cases

## Technologies Used

- MySQL 8
- SQL Triggers
- Event Scheduler
- JSON Aggregation
- Relational Database Design

## Author

Jakub Kopiejka
