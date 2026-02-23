-- Trigger: trg_alert_to_case
DROP TRIGGER IF EXISTS `trg_alert_to_case`;
DELIMITER $$
CREATE TRIGGER `trg_alert_to_case`
AFTER INSERT ON `aml_alerts`
FOR EACH ROW
BEGIN
    INSERT INTO aml_cases (
        alert_id,
        decision,
        created_at
    )
    VALUES (
        NEW.alert_id,
        'NOT_IN_PROCESS',
        NOW()
    );
END$$
DELIMITER ;
