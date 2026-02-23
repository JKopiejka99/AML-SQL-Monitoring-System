-- Trigger: trg_update_ubo_after_insert
DROP TRIGGER IF EXISTS `trg_update_ubo_after_insert`;
DELIMITER $$
CREATE TRIGGER `trg_update_ubo_after_insert`
AFTER INSERT ON `beneficial_owners`
FOR EACH ROW
BEGIN
    UPDATE customers c
    LEFT JOIN (
        SELECT customer_id, GROUP_CONCAT(bo_name SEPARATOR ', ') AS bo_list
        FROM beneficial_owners
        WHERE customer_id = NEW.customer_id
        GROUP BY customer_id
    ) bo
    ON c.customer_id = bo.customer_id
    SET c.UBO = bo.bo_list
    WHERE c.customer_id = NEW.customer_id
      AND c.customer_type = 'business';
END$$
DELIMITER ;
