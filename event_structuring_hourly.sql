-- Event: event_structuring_hourly
DROP EVENT IF EXISTS `event_structuring_hourly`;
DELIMITER $$
CREATE EVENT `event_structuring_hourly`
ON SCHEDULE EVERY 1 HOUR STARTS '2026-01-29 11:49:24' ON COMPLETION NOT PRESERVE ENABLE
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
        t.account_id,
        'STRUCTURING',
        CONCAT(
            'Structuring detected on account ',
            t.account_id,
            ': 3+ transactions below 10k totaling above 10k within 10 days'
        ),
        JSON_ARRAYAGG(t.transaction_id),
        NOW()

    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id

    WHERE t.transaction_date >= NOW() - INTERVAL 10 DAY
      AND t.amount < 10000

    GROUP BY t.account_id

    HAVING COUNT(*) >= 3
       AND SUM(t.amount) > 10000

       AND NOT EXISTS (
            SELECT 1
            FROM aml_alerts al
            WHERE al.alert_type = 'STRUCTURING'
              AND al.account_id = t.account_id
              AND al.created_at >= NOW() - INTERVAL 10 DAY
       );

END$$
DELIMITER ;
