-- Week 6 — Event-Driven Auditing
USE arravo_retail;

CREATE TABLE IF NOT EXISTS audit_log (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(64) NOT NULL,
  action VARCHAR(20) NOT NULL,
  record_id INT NOT NULL,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS salary_history (
  history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  employee_id INT NOT NULL,
  old_salary INT,
  new_salary INT,
  changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

CREATE TABLE IF NOT EXISTS deleted_records_log (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  table_name VARCHAR(64) NOT NULL,
  record_id INT NOT NULL,
  row_snapshot JSON NOT NULL,
  deleted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS stock_alerts (
  alert_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  old_stock_qty INT,
  new_stock_qty INT,
  alert_message VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE IF NOT EXISTS daily_sales_summary (
  summary_date DATE PRIMARY KEY,
  transactions INT NOT NULL,
  units_sold INT NOT NULL,
  revenue DECIMAL(18,2) NOT NULL,
  refreshed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                 ON UPDATE CURRENT_TIMESTAMP
);

DROP TRIGGER IF EXISTS trg_sales_after_insert;
DROP TRIGGER IF EXISTS trg_employees_salary_after_update;
DROP TRIGGER IF EXISTS trg_customers_before_delete;
DROP TRIGGER IF EXISTS trg_products_stock_after_update;

DELIMITER $$

CREATE TRIGGER trg_sales_after_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
  INSERT INTO audit_log(table_name,action,record_id)
  VALUES('sales','INSERT',NEW.sale_id);
END$$

CREATE TRIGGER trg_employees_salary_after_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
  IF NOT (OLD.monthly_salary <=> NEW.monthly_salary) THEN
    INSERT INTO salary_history(employee_id,old_salary,new_salary)
    VALUES(NEW.employee_id,OLD.monthly_salary,NEW.monthly_salary);

    INSERT INTO audit_log(table_name,action,record_id)
    VALUES('employees','SALARY UPDATE',NEW.employee_id);
  END IF;
END$$

CREATE TRIGGER trg_customers_before_delete
BEFORE DELETE ON customers
FOR EACH ROW
BEGIN
  INSERT INTO deleted_records_log(table_name,record_id,row_snapshot)
  VALUES(
    'customers',
    OLD.customer_id,
    JSON_OBJECT(
      'customer_id',OLD.customer_id,
      'customer_name',OLD.customer_name,
      'gender',OLD.gender,
      'email',OLD.email,
      'phone',OLD.phone,
      'city',OLD.city,
      'signup_date',OLD.signup_date,
      'customer_segment',OLD.customer_segment
    )
  );
END$$

CREATE TRIGGER trg_products_stock_after_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
  IF NEW.stock_qty < 5 AND OLD.stock_qty >= 5 THEN
    INSERT INTO stock_alerts(product_id,old_stock_qty,new_stock_qty,alert_message)
    VALUES(
      NEW.product_id,OLD.stock_qty,NEW.stock_qty,
      CONCAT('Low stock: ',NEW.product_name,' dropped below 5 units')
    );
  END IF;
END$$

DELIMITER ;

-- Safe trigger tests inside a transaction
START TRANSACTION;

UPDATE employees
SET monthly_salary=monthly_salary+1000
WHERE employee_id=1;

UPDATE products
SET stock_qty=4
WHERE product_id=1;

SELECT * FROM salary_history ORDER BY changed_at DESC LIMIT 5;
SELECT * FROM stock_alerts ORDER BY created_at DESC LIMIT 5;

ROLLBACK;

-- Event scheduler
SET GLOBAL event_scheduler=ON;
SHOW VARIABLES LIKE 'event_scheduler';

DROP EVENT IF EXISTS ev_daily_sales_summary;

DELIMITER $$

CREATE EVENT ev_daily_sales_summary
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE,'23:55:00')
DO
BEGIN
  INSERT INTO daily_sales_summary(summary_date,transactions,units_sold,revenue)
  SELECT CURRENT_DATE-INTERVAL 1 DAY,
         COUNT(*),
         COALESCE(SUM(quantity),0),
         COALESCE(SUM(total_amount),0)
  FROM sales
  WHERE sale_date=CURRENT_DATE-INTERVAL 1 DAY
  ON DUPLICATE KEY UPDATE
    transactions=VALUES(transactions),
    units_sold=VALUES(units_sold),
    revenue=VALUES(revenue),
    refreshed_at=CURRENT_TIMESTAMP;
END$$

DELIMITER ;

-- Manual simulation for the latest sale date in the training dataset
INSERT INTO daily_sales_summary(summary_date,transactions,units_sold,revenue)
SELECT MAX(sale_date),COUNT(*),SUM(quantity),SUM(total_amount)
FROM sales
WHERE sale_date=(SELECT MAX(sale_date) FROM sales)
GROUP BY sale_date
ON DUPLICATE KEY UPDATE
  transactions=VALUES(transactions),
  units_sold=VALUES(units_sold),
  revenue=VALUES(revenue),
  refreshed_at=CURRENT_TIMESTAMP;

SELECT * FROM daily_sales_summary ORDER BY summary_date DESC;
SHOW EVENTS FROM arravo_retail;
