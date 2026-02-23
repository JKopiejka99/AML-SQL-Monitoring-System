AML Monitoring System


AML Monitoring System — Project summary

What this project demonstrates
This repository is a compact demonstration of how an AML (Anti-Money Laundering) monitoring
system can be organised around transactional data. It shows a clean data model, simple
automated detectors that flag suspicious behaviour, and the minimal workflows needed to
turn an automated alert into an investigation case.

Segments and why they matter for AML

- Schema (`sql/00_schema.sql`)
	- What it contains: tables and relationships for customers, accounts, transactions, alerts,
		cases and beneficial owners.
	- Role in AML: a clear schema ensures every transaction can be linked back to an account and
		ultimately to a customer. That linkage is critical when investigators need to trace flows of
		funds, identify ownership, or connect multiple accounts to the same person or organisation.

- Seed data (`sql/01_seed.sql`)
	- What it contains: a small, realistic dataset and reference lists (e.g., high-risk countries).
	- Role in AML: sample data lets you run the detectors and see example alerts without using
		sensitive real-world data. The seed includes crafted cases that illustrate common AML
		patterns like large incoming transfers, rapid outflows, and structuring.

- Detectors / Events (`sql/events/`)
	- What they do: scheduled SQL tasks that scan recent transactions and insert alerts when
		specific rules are satisfied.
	- Role in AML: detectors automate early screening so suspicious activity surfaces quickly.
		Examples included: incoming transactions from high-risk countries, structuring (many small
		deposits below threshold), and flow-through (large inbound followed by rapid outbound).

- Triggers (`sql/triggers/`)
	- What they do: small automated actions tied to data changes (e.g., create a case when an
		alert is inserted, update a customer's UBO list when a beneficial owner is added).
	- Role in AML: triggers keep the dataset operational and consistent, reducing manual work
		for analysts and ensuring alerts enter the investigation workflow immediately.

- Examples and scripts (`sql/02_queries.sql`, `scripts/`)
	- What they contain: analyst-friendly queries for exploring alerts and simple deploy scripts
		to stand up the demo locally.
	- Role in AML: these are the investigative tools analysts use to validate alerts and gather
		context needed for decision-making.

Security, privacy and notes
- No real customer data is included. This is a demo dataset intended for learning and portfolio
	display.



