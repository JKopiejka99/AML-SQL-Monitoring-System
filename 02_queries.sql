-- 02_queries.sql
-- Useful queries / examples / analytics for the project

USE aml_monitoring;

-- Recent alerts
SELECT * FROM aml_alerts ORDER BY created_at DESC LIMIT 50;

-- High-value incoming followed by quick outflows (sample analytic)
SELECT
    t_in.account_id,
    t_in.transaction_id AS incoming_trx,
    SUM(t_out.amount) AS total_out,
    COUNT(t_out.transaction_id) AS out_count
FROM transactions t_in
JOIN transactions t_out ON t_in.account_id = t_out.account_id
    AND t_out.transaction_type = 'OUT'
    AND DATEDIFF(t_out.transaction_date, t_in.transaction_date) BETWEEN 0 AND 5
WHERE t_in.transaction_type = 'IN' AND t_in.amount >= 10000
GROUP BY t_in.transaction_id
HAVING SUM(t_out.amount) >= t_in.amount * 0.8 AND COUNT(t_out.transaction_id) >= 2;

-- Structuring candidates (3+ small deposits within 10 days)
SELECT
    t.account_id,
    COUNT(*) AS trx_count,
    SUM(t.amount) AS total_amount
FROM transactions t
WHERE t.transaction_date >= NOW() - INTERVAL 10 DAY
  AND t.amount < 10000
GROUP BY t.account_id
HAVING COUNT(*) >= 3 AND SUM(t.amount) > 10000;

-- Alerts join to transactions (expand JSON transaction_ids)
SELECT a.alert_id, a.alert_type, t.transaction_id, t.amount
FROM aml_alerts a
JOIN JSON_TABLE(a.transaction_ids, '$[*]' COLUMNS(tx_id INT PATH '$')) jt ON 1
JOIN transactions t ON t.transaction_id = jt.tx_id
WHERE a.alert_id IS NOT NULL;

-- Example: manually create an alert for a high-risk incoming
INSERT INTO aml_alerts (customer_id, account_id, alert_type, alert_reason, transaction_ids, created_at)
SELECT a.customer_id, t.account_id, 'HIGH_RISK_COUNTRY',
       CONCAT('Transaction to high-risk country: ', h.country_name),
       JSON_ARRAYAGG(t.transaction_id), NOW()
FROM transactions t
JOIN accounts a ON a.account_id = t.account_id
JOIN high_risk_countries h ON t.counterparty_country = h.country_code
WHERE t.transaction_type = 'IN'
GROUP BY t.account_id, h.country_code;

-- Development / ad-hoc queries extracted from project history

-- Show scheduled events
SHOW EVENTS FROM aml_monitoring;
SHOW EVENTS LIKE 'event_structuring_hourly';

-- Show triggers
SHOW TRIGGERS;

-- Example: update aggregated UBO field after loading beneficial_owners
UPDATE customers c
LEFT JOIN (
    SELECT customer_id, GROUP_CONCAT(bo_name SEPARATOR ', ') AS bo_list
    FROM beneficial_owners
    GROUP BY customer_id
) bo ON c.customer_id = bo.customer_id
SET c.UBO = CASE WHEN c.customer_type = 'business' THEN bo.bo_list ELSE 'N/A' END;

-- Example housekeeping: enable event scheduler (requires SUPER privileges)
-- SET GLOBAL event_scheduler = ON;

