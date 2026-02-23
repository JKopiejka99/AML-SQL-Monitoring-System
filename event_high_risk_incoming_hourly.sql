-- Event: event_high_risk_incoming_hourly
DROP EVENT IF EXISTS `event_high_risk_incoming_hourly`;
DELIMITER $$
CREATE EVENT `event_high_risk_incoming_hourly`
ON SCHEDULE EVERY 1 HOUR
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
        'HIGH_RISK_COUNTRY',
        CONCAT(
            'High-risk incoming transaction detected on account ',
            t.account_id,
            ': funds received from ',
            hrc.country_name,
            ' (',
            hrc.country_code,
            ')'
        ),
        JSON_ARRAYAGG(t.transaction_id),
        NOW()

    FROM transactions t
    JOIN accounts a
        ON t.account_id = a.account_id

    JOIN high_risk_countries hrc
        ON t.counterparty_country = hrc.country_code

    WHERE t.transaction_type = 'IN'
      AND NOT EXISTS (
          SELECT 1
          FROM aml_alerts al
          WHERE al.alert_type = 'HIGH_RISK_COUNTRY'
            AND JSON_CONTAINS(
                al.transaction_ids,
                CAST(t.transaction_id AS JSON)
            )
      )

    GROUP BY t.account_id, hrc.country_code, hrc.country_name;

END$$
DELIMITER ;
