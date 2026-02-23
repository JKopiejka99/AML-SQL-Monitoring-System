-- Event: flow_through_hourly
DROP EVENT IF EXISTS `flow_through_hourly`;
DELIMITER $$
CREATE EVENT `flow_through_hourly`
ON SCHEDULE EVERY 1 HOUR STARTS '2026-01-20 13:51:17' ON COMPLETION NOT PRESERVE ENABLE
DO
BEGIN
    INSERT INTO aml_alerts (
        customer_id,
        account_id,
        alert_type,
        alert_reason,
        transaction_ids,
        created_at
    )
    SELECT
        a.customer_id,
        t_in.account_id,
        'FLOW_THROUGH',
        CONCAT(
            'Flow-through of funds detected on account ',
            t_in.account_id,
            ': large incoming transaction followed by quick outgoing transactions'
        ),
        JSON_ARRAYAGG(trx.transaction_id),
        NOW()
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
    JOIN accounts a
        ON a.account_id = t_in.account_id
    WHERE t_in.transaction_type = 'IN'
      AND t_in.amount >= 10000
      AND NOT EXISTS (
          SELECT 1
          FROM aml_alerts al
          WHERE al.alert_type = 'FLOW_THROUGH'
            AND al.account_id = t_in.account_id
      )
    GROUP BY
        t_in.transaction_id,
        t_in.account_id,
        t_in.amount
    HAVING
        SUM(t_out.amount) >= t_in.amount * 0.8
        AND COUNT(t_out.transaction_id) >= 2;
END$$
DELIMITER ;
