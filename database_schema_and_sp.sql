-- ============================================================================
-- BISU-BILAR LIBRARY MANAGEMENT SYSTEM
-- MySQL Database Schema & Stored Procedures
-- Database: bisublar_cis
-- ============================================================================

CREATE DATABASE IF NOT EXISTS `bisublar_cis`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `bisublar_cis`;

-- ============================================================================
-- TABLE DEFINITIONS
-- ============================================================================

-- ------------------------------------
-- 1. System Users (Admin / Staff)
-- ------------------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id`           INT            NOT NULL AUTO_INCREMENT,
  `user_id`      VARCHAR(50)    NOT NULL,
  `username`     VARCHAR(100)   NOT NULL,
  `password`     VARCHAR(255)   NOT NULL,
  `designation`  VARCHAR(100)   DEFAULT '',
  `access_right` VARCHAR(50)    DEFAULT 'USER',
  `is_admin`     TINYINT(1)     DEFAULT 0,
  `created_at`   DATETIME       DEFAULT CURRENT_TIMESTAMP,
  `updated_at`   DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------
-- 2. Borrowers / Patrons
-- ------------------------------------
DROP TABLE IF EXISTS `borrowers`;
CREATE TABLE `borrowers` (
  `id`              INT            NOT NULL AUTO_INCREMENT,
  `id_no`           VARCHAR(50)    NOT NULL,
  `firstname`       VARCHAR(100)   NOT NULL,
  `lastname`        VARCHAR(100)   NOT NULL,
  `mobile_phone`    VARCHAR(30)    DEFAULT '',
  `phone`           VARCHAR(30)    DEFAULT '',
  `email`           VARCHAR(150)   DEFAULT '',
  `address`         VARCHAR(500)   DEFAULT '',
  `notes`           TEXT           DEFAULT NULL,
  `date_registered` DATE           DEFAULT NULL,
  `type`            ENUM('Student','Faculty','Others') DEFAULT 'Student',
  `status`          ENUM('Active','Inactive')          DEFAULT 'Active',
  `created_at`      DATETIME       DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_borrowers_id_no` (`id_no`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------
-- 3. Suppliers
-- ------------------------------------
DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE `suppliers` (
  `id`              INT            NOT NULL AUTO_INCREMENT,
  `sup_code`        VARCHAR(50)    NOT NULL,
  `company_name`    VARCHAR(200)   NOT NULL,
  `address`         VARCHAR(500)   DEFAULT '',
  `phone`           VARCHAR(30)    DEFAULT '',
  `fax_no`          VARCHAR(30)    DEFAULT '',
  `mobile_phone`    VARCHAR(30)    DEFAULT '',
  `email`           VARCHAR(150)   DEFAULT '',
  `web_site`        VARCHAR(255)   DEFAULT '',
  `contact_person`  VARCHAR(150)   DEFAULT '',
  `position`        VARCHAR(100)   DEFAULT '',
  `gender`          ENUM('Male','Female','Other') DEFAULT 'Male',
  `created_at`      DATETIME       DEFAULT CURRENT_TIMESTAMP,
  `updated_at`      DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_suppliers_sup_code` (`sup_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------
-- 4. Books / Library Items
-- ------------------------------------
DROP TABLE IF EXISTS `books`;
CREATE TABLE `books` (
  `id`               INT            NOT NULL AUTO_INCREMENT,
  `title`            VARCHAR(500)   NOT NULL,
  `author`           VARCHAR(300)   DEFAULT '',
  `co_author`        VARCHAR(300)   DEFAULT '',
  `type`             VARCHAR(50)    DEFAULT 'Book',
  `publisher`        VARCHAR(200)   DEFAULT '',
  `place`            VARCHAR(200)   DEFAULT '',
  `date_published`   VARCHAR(50)    DEFAULT '',
  `volume`           VARCHAR(50)    DEFAULT '',
  `series`           VARCHAR(100)   DEFAULT '',
  `category`         VARCHAR(100)   DEFAULT '',
  `format`           VARCHAR(50)    DEFAULT '',
  `editor`           VARCHAR(200)   DEFAULT '',
  `illustrator`      VARCHAR(200)   DEFAULT '',
  `pages`            VARCHAR(20)    DEFAULT '',
  `isbn`             VARCHAR(30)    DEFAULT '',
  `physical_desc`    VARCHAR(500)   DEFAULT '',
  `accession_no`     VARCHAR(50)    DEFAULT '',
  `call_no`          VARCHAR(50)    DEFAULT '',
  `barcode`          VARCHAR(50)    DEFAULT NULL,
  `location`         VARCHAR(200)   DEFAULT '',
  `circulation_type` VARCHAR(50)    DEFAULT 'Loanable',
  `price`            DECIMAL(10,2)  DEFAULT 0.00,
  `value`            DECIMAL(10,2)  DEFAULT 0.00,
  `purchased_date`   VARCHAR(50)    DEFAULT '',
  `evaluated_date`   VARCHAR(50)    DEFAULT '',
  `acquisition_date` VARCHAR(50)    DEFAULT '',
  `copies_available` INT            DEFAULT 1,
  `created_at`       DATETIME       DEFAULT CURRENT_TIMESTAMP,
  `updated_at`       DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_books_barcode` (`barcode`),
  INDEX `idx_books_title` (`title`(100)),
  INDEX `idx_books_isbn` (`isbn`),
  INDEX `idx_books_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------
-- 5. Transactions (Checkout / Checkin)
-- ------------------------------------
DROP TABLE IF EXISTS `transactions`;
CREATE TABLE `transactions` (
  `id`             INT            NOT NULL AUTO_INCREMENT,
  `book_id`        INT            NOT NULL,
  `borrower_id`    INT            NOT NULL,
  `loan_date`      DATE           DEFAULT NULL,
  `due_date`       DATE           NOT NULL,
  `return_date`    DATE           DEFAULT NULL,
  `fine_amount`    DECIMAL(10,2)  DEFAULT 0.00,
  `past_due_fines` DECIMAL(10,2)  DEFAULT 0.00,
  `total_fine`     DECIMAL(10,2)  DEFAULT 0.00,
  `notes`          TEXT           DEFAULT NULL,
  `status`         ENUM('Loaned','Returned','Overdue') DEFAULT 'Loaned',
  `created_at`     DATETIME       DEFAULT CURRENT_TIMESTAMP,
  `updated_at`     DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_transactions_status` (`status`),
  INDEX `idx_transactions_borrower` (`borrower_id`),
  INDEX `idx_transactions_book` (`book_id`),
  CONSTRAINT `fk_transactions_book`     FOREIGN KEY (`book_id`)     REFERENCES `books`(`id`)     ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_transactions_borrower` FOREIGN KEY (`borrower_id`) REFERENCES `borrowers`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------
-- 6. Reservations
-- ------------------------------------
DROP TABLE IF EXISTS `reservations`;
CREATE TABLE `reservations` (
  `id`                INT            NOT NULL AUTO_INCREMENT,
  `book_id`           INT            NOT NULL,
  `borrower_id`       INT            NOT NULL,
  `reserved_on`       DATE           DEFAULT NULL,
  `reserved_for_days` INT            DEFAULT 5,
  `notes`             TEXT           DEFAULT NULL,
  `status`            ENUM('Active','Fulfilled','Cancelled','Expired') DEFAULT 'Active',
  `created_at`        DATETIME       DEFAULT CURRENT_TIMESTAMP,
  `updated_at`        DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_reservations_status` (`status`),
  INDEX `idx_reservations_borrower` (`borrower_id`),
  INDEX `idx_reservations_book` (`book_id`),
  CONSTRAINT `fk_reservations_book`     FOREIGN KEY (`book_id`)     REFERENCES `books`(`id`)     ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT `fk_reservations_borrower` FOREIGN KEY (`borrower_id`) REFERENCES `borrowers`(`id`) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Default admin user (password: admin123 — hash with bcrypt at app level)
INSERT INTO `users` (`user_id`, `username`, `password`, `designation`, `access_right`, `is_admin`)
VALUES ('ADMIN', 'ADMIN USER', '$2a$10$placeholder_hash_replace_at_app_level', 'Librarian', 'ADMINISTRATOR', 1)
ON DUPLICATE KEY UPDATE `id` = `id`;


-- ============================================================================
-- STORED PROCEDURES
-- ============================================================================

-- ============================================================================
-- AUTH MODULE
-- ============================================================================

-- ------------------------------------
-- sp_user_login
-- Retrieves user record by user_id for login validation.
-- Password comparison (bcrypt) is handled at the application layer.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_user_login`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_user_login`(
    IN p_user_id VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        `id`,
        `user_id`,
        `username`,
        `password`,
        `designation`,
        `access_right`,
        `is_admin`
    FROM `users`
    WHERE `user_id` = p_user_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_current_user
-- Retrieves user profile by internal id (excludes password).
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_current_user`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_current_user`(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        `id`,
        `user_id`,
        `username`,
        `designation`,
        `access_right`,
        `is_admin`
    FROM `users`
    WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- USERS MODULE
-- ============================================================================

-- ------------------------------------
-- sp_get_all_users
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_all_users`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_all_users`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        `id`,
        `user_id`,
        `username`,
        `designation`,
        `access_right`,
        `is_admin`,
        `created_at`
    FROM `users`
    ORDER BY `user_id`;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_create_user
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_create_user`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_create_user`(
    IN p_user_id      VARCHAR(50),
    IN p_username     VARCHAR(100),
    IN p_password     VARCHAR(255),
    IN p_designation  VARCHAR(100),
    IN p_access_right VARCHAR(50),
    IN p_is_admin     TINYINT(1)
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    INSERT INTO `users` (`user_id`, `username`, `password`, `designation`, `access_right`, `is_admin`)
    VALUES (p_user_id, p_username, p_password, IFNULL(p_designation, ''), IFNULL(p_access_right, 'USER'), IFNULL(p_is_admin, 0));

    SET v_new_id = LAST_INSERT_ID();

    SELECT
        `id`,
        `user_id`,
        `username`,
        `designation`,
        `access_right`,
        `is_admin`
    FROM `users`
    WHERE `id` = v_new_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_update_user
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_update_user`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_update_user`(
    IN p_id           INT,
    IN p_username     VARCHAR(100),
    IN p_password     VARCHAR(255),
    IN p_designation  VARCHAR(100),
    IN p_access_right VARCHAR(50),
    IN p_is_admin     TINYINT(1)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    UPDATE `users`
    SET
        `username`     = IFNULL(p_username, `username`),
        `password`     = IFNULL(p_password, `password`),
        `designation`  = IFNULL(p_designation, `designation`),
        `access_right` = IFNULL(p_access_right, `access_right`),
        `is_admin`     = IFNULL(p_is_admin, `is_admin`),
        `updated_at`   = NOW()
    WHERE `id` = p_id;

    SELECT
        `id`,
        `user_id`,
        `username`,
        `designation`,
        `access_right`,
        `is_admin`
    FROM `users`
    WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_delete_user
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_delete_user`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_delete_user`(
    IN p_id INT
)
BEGIN
    DECLARE v_user_id VARCHAR(50);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT `user_id` INTO v_user_id FROM `users` WHERE `id` = p_id;

    IF v_user_id = 'ADMIN' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cannot delete the default admin account';
    END IF;

    DELETE FROM `users` WHERE `id` = p_id;

    SELECT ROW_COUNT() AS affected_rows;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- BOOKS MODULE
-- ============================================================================

-- ------------------------------------
-- sp_get_all_books
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_all_books`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_all_books`(
    IN p_search          VARCHAR(255),
    IN p_type            VARCHAR(50),
    IN p_circulation_type VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT *
    FROM `books`
    WHERE
        (p_search IS NULL OR p_search = '' OR
            `title`   LIKE CONCAT('%', p_search, '%') OR
            `author`  LIKE CONCAT('%', p_search, '%') OR
            `barcode` LIKE CONCAT('%', p_search, '%') OR
            `isbn`    LIKE CONCAT('%', p_search, '%') OR
            `call_no` LIKE CONCAT('%', p_search, '%'))
        AND (p_type IS NULL OR p_type = '' OR `type` = p_type)
        AND (p_circulation_type IS NULL OR p_circulation_type = '' OR `circulation_type` = p_circulation_type)
    ORDER BY `title` ASC;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_book_by_id
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_book_by_id`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_book_by_id`(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT * FROM `books` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_book_by_barcode
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_book_by_barcode`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_book_by_barcode`(
    IN p_barcode VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT * FROM `books` WHERE `barcode` = p_barcode;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_create_book
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_create_book`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_create_book`(
    IN p_title            VARCHAR(500),
    IN p_author           VARCHAR(300),
    IN p_co_author        VARCHAR(300),
    IN p_type             VARCHAR(50),
    IN p_publisher        VARCHAR(200),
    IN p_place            VARCHAR(200),
    IN p_date_published   VARCHAR(50),
    IN p_volume           VARCHAR(50),
    IN p_series           VARCHAR(100),
    IN p_category         VARCHAR(100),
    IN p_format           VARCHAR(50),
    IN p_editor           VARCHAR(200),
    IN p_illustrator      VARCHAR(200),
    IN p_pages            VARCHAR(20),
    IN p_isbn             VARCHAR(30),
    IN p_physical_desc    VARCHAR(500),
    IN p_accession_no     VARCHAR(50),
    IN p_call_no          VARCHAR(50),
    IN p_barcode          VARCHAR(50),
    IN p_location         VARCHAR(200),
    IN p_circulation_type VARCHAR(50),
    IN p_price            DECIMAL(10,2),
    IN p_value            DECIMAL(10,2),
    IN p_purchased_date   VARCHAR(50),
    IN p_evaluated_date   VARCHAR(50),
    IN p_acquisition_date VARCHAR(50),
    IN p_copies_available INT
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    INSERT INTO `books` (
        `title`, `author`, `co_author`, `type`, `publisher`, `place`, `date_published`,
        `volume`, `series`, `category`, `format`, `editor`, `illustrator`, `pages`, `isbn`,
        `physical_desc`, `accession_no`, `call_no`, `barcode`, `location`,
        `circulation_type`, `price`, `value`, `purchased_date`, `evaluated_date`,
        `acquisition_date`, `copies_available`
    ) VALUES (
        p_title,
        IFNULL(p_author, ''),
        IFNULL(p_co_author, ''),
        IFNULL(p_type, 'Book'),
        IFNULL(p_publisher, ''),
        IFNULL(p_place, ''),
        IFNULL(p_date_published, ''),
        IFNULL(p_volume, ''),
        IFNULL(p_series, ''),
        IFNULL(p_category, ''),
        IFNULL(p_format, ''),
        IFNULL(p_editor, ''),
        IFNULL(p_illustrator, ''),
        IFNULL(p_pages, ''),
        IFNULL(p_isbn, ''),
        IFNULL(p_physical_desc, ''),
        IFNULL(p_accession_no, ''),
        IFNULL(p_call_no, ''),
        p_barcode,
        IFNULL(p_location, ''),
        IFNULL(p_circulation_type, 'Loanable'),
        IFNULL(p_price, 0.00),
        IFNULL(p_value, 0.00),
        IFNULL(p_purchased_date, ''),
        IFNULL(p_evaluated_date, ''),
        IFNULL(p_acquisition_date, ''),
        IFNULL(p_copies_available, 1)
    );

    SET v_new_id = LAST_INSERT_ID();

    SELECT * FROM `books` WHERE `id` = v_new_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_update_book
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_update_book`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_update_book`(
    IN p_id               INT,
    IN p_title            VARCHAR(500),
    IN p_author           VARCHAR(300),
    IN p_co_author        VARCHAR(300),
    IN p_type             VARCHAR(50),
    IN p_publisher        VARCHAR(200),
    IN p_place            VARCHAR(200),
    IN p_date_published   VARCHAR(50),
    IN p_volume           VARCHAR(50),
    IN p_series           VARCHAR(100),
    IN p_category         VARCHAR(100),
    IN p_format           VARCHAR(50),
    IN p_editor           VARCHAR(200),
    IN p_illustrator      VARCHAR(200),
    IN p_pages            VARCHAR(20),
    IN p_isbn             VARCHAR(30),
    IN p_physical_desc    VARCHAR(500),
    IN p_accession_no     VARCHAR(50),
    IN p_call_no          VARCHAR(50),
    IN p_barcode          VARCHAR(50),
    IN p_location         VARCHAR(200),
    IN p_circulation_type VARCHAR(50),
    IN p_price            DECIMAL(10,2),
    IN p_value            DECIMAL(10,2),
    IN p_purchased_date   VARCHAR(50),
    IN p_evaluated_date   VARCHAR(50),
    IN p_acquisition_date VARCHAR(50),
    IN p_copies_available INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    UPDATE `books`
    SET
        `title`            = IFNULL(p_title, `title`),
        `author`           = IFNULL(p_author, `author`),
        `co_author`        = IFNULL(p_co_author, `co_author`),
        `type`             = IFNULL(p_type, `type`),
        `publisher`        = IFNULL(p_publisher, `publisher`),
        `place`            = IFNULL(p_place, `place`),
        `date_published`   = IFNULL(p_date_published, `date_published`),
        `volume`           = IFNULL(p_volume, `volume`),
        `series`           = IFNULL(p_series, `series`),
        `category`         = IFNULL(p_category, `category`),
        `format`           = IFNULL(p_format, `format`),
        `editor`           = IFNULL(p_editor, `editor`),
        `illustrator`      = IFNULL(p_illustrator, `illustrator`),
        `pages`            = IFNULL(p_pages, `pages`),
        `isbn`             = IFNULL(p_isbn, `isbn`),
        `physical_desc`    = IFNULL(p_physical_desc, `physical_desc`),
        `accession_no`     = IFNULL(p_accession_no, `accession_no`),
        `call_no`          = IFNULL(p_call_no, `call_no`),
        `barcode`          = IFNULL(p_barcode, `barcode`),
        `location`         = IFNULL(p_location, `location`),
        `circulation_type` = IFNULL(p_circulation_type, `circulation_type`),
        `price`            = IFNULL(p_price, `price`),
        `value`            = IFNULL(p_value, `value`),
        `purchased_date`   = IFNULL(p_purchased_date, `purchased_date`),
        `evaluated_date`   = IFNULL(p_evaluated_date, `evaluated_date`),
        `acquisition_date` = IFNULL(p_acquisition_date, `acquisition_date`),
        `copies_available` = IFNULL(p_copies_available, `copies_available`),
        `updated_at`       = NOW()
    WHERE `id` = p_id;

    SELECT * FROM `books` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_delete_book
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_delete_book`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_delete_book`(
    IN p_id INT
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT COUNT(*) INTO v_exists FROM `books` WHERE `id` = p_id;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not found';
    END IF;

    DELETE FROM `books` WHERE `id` = p_id;

    SELECT ROW_COUNT() AS affected_rows;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- BORROWERS MODULE
-- ============================================================================

-- ------------------------------------
-- sp_get_all_borrowers
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_all_borrowers`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_all_borrowers`(
    IN p_search VARCHAR(255),
    IN p_type   VARCHAR(20),
    IN p_status VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT *
    FROM `borrowers`
    WHERE
        (p_search IS NULL OR p_search = '' OR
            `firstname` LIKE CONCAT('%', p_search, '%') OR
            `lastname`  LIKE CONCAT('%', p_search, '%') OR
            `id_no`     LIKE CONCAT('%', p_search, '%') OR
            `email`     LIKE CONCAT('%', p_search, '%'))
        AND (p_type   IS NULL OR p_type   = '' OR `type`   = p_type)
        AND (p_status IS NULL OR p_status = '' OR `status` = p_status)
    ORDER BY `lastname` ASC, `firstname` ASC;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_borrower_by_id
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_borrower_by_id`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_borrower_by_id`(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT * FROM `borrowers` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_borrower_by_idno
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_borrower_by_idno`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_borrower_by_idno`(
    IN p_id_no VARCHAR(50)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT * FROM `borrowers` WHERE `id_no` = p_id_no;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_create_borrower
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_create_borrower`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_create_borrower`(
    IN p_id_no        VARCHAR(50),
    IN p_firstname    VARCHAR(100),
    IN p_lastname     VARCHAR(100),
    IN p_mobile_phone VARCHAR(30),
    IN p_phone        VARCHAR(30),
    IN p_email        VARCHAR(150),
    IN p_address      VARCHAR(500),
    IN p_notes        TEXT,
    IN p_type         VARCHAR(20),
    IN p_status       VARCHAR(20)
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    INSERT INTO `borrowers` (`id_no`, `firstname`, `lastname`, `mobile_phone`, `phone`, `email`, `address`, `notes`, `date_registered`, `type`, `status`)
    VALUES (
        p_id_no,
        p_firstname,
        p_lastname,
        IFNULL(p_mobile_phone, ''),
        IFNULL(p_phone, ''),
        IFNULL(p_email, ''),
        IFNULL(p_address, ''),
        IFNULL(p_notes, ''),
        CURDATE(),
        IFNULL(p_type, 'Student'),
        IFNULL(p_status, 'Active')
    );

    SET v_new_id = LAST_INSERT_ID();

    SELECT * FROM `borrowers` WHERE `id` = v_new_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_update_borrower
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_update_borrower`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_update_borrower`(
    IN p_id           INT,
    IN p_id_no        VARCHAR(50),
    IN p_firstname    VARCHAR(100),
    IN p_lastname     VARCHAR(100),
    IN p_mobile_phone VARCHAR(30),
    IN p_phone        VARCHAR(30),
    IN p_email        VARCHAR(150),
    IN p_address      VARCHAR(500),
    IN p_notes        TEXT,
    IN p_type         VARCHAR(20),
    IN p_status       VARCHAR(20)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    UPDATE `borrowers`
    SET
        `id_no`        = IFNULL(p_id_no, `id_no`),
        `firstname`    = IFNULL(p_firstname, `firstname`),
        `lastname`     = IFNULL(p_lastname, `lastname`),
        `mobile_phone` = IFNULL(p_mobile_phone, `mobile_phone`),
        `phone`        = IFNULL(p_phone, `phone`),
        `email`        = IFNULL(p_email, `email`),
        `address`      = IFNULL(p_address, `address`),
        `notes`        = IFNULL(p_notes, `notes`),
        `type`         = IFNULL(p_type, `type`),
        `status`       = IFNULL(p_status, `status`),
        `updated_at`   = NOW()
    WHERE `id` = p_id;

    SELECT * FROM `borrowers` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_delete_borrower
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_delete_borrower`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_delete_borrower`(
    IN p_id INT
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT COUNT(*) INTO v_exists FROM `borrowers` WHERE `id` = p_id;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Borrower not found';
    END IF;

    DELETE FROM `borrowers` WHERE `id` = p_id;

    SELECT ROW_COUNT() AS affected_rows;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- SUPPLIERS MODULE
-- ============================================================================

-- ------------------------------------
-- sp_get_all_suppliers
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_all_suppliers`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_all_suppliers`(
    IN p_search VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT *
    FROM `suppliers`
    WHERE
        (p_search IS NULL OR p_search = '' OR
            `company_name`   LIKE CONCAT('%', p_search, '%') OR
            `sup_code`       LIKE CONCAT('%', p_search, '%') OR
            `contact_person` LIKE CONCAT('%', p_search, '%'))
    ORDER BY `company_name` ASC;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_supplier_by_id
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_supplier_by_id`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_supplier_by_id`(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT * FROM `suppliers` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_create_supplier
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_create_supplier`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_create_supplier`(
    IN p_sup_code       VARCHAR(50),
    IN p_company_name   VARCHAR(200),
    IN p_address        VARCHAR(500),
    IN p_phone          VARCHAR(30),
    IN p_fax_no         VARCHAR(30),
    IN p_mobile_phone   VARCHAR(30),
    IN p_email          VARCHAR(150),
    IN p_web_site       VARCHAR(255),
    IN p_contact_person VARCHAR(150),
    IN p_position       VARCHAR(100),
    IN p_gender         VARCHAR(10)
)
BEGIN
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    INSERT INTO `suppliers` (
        `sup_code`, `company_name`, `address`, `phone`, `fax_no`, `mobile_phone`,
        `email`, `web_site`, `contact_person`, `position`, `gender`
    ) VALUES (
        p_sup_code,
        p_company_name,
        IFNULL(p_address, ''),
        IFNULL(p_phone, ''),
        IFNULL(p_fax_no, ''),
        IFNULL(p_mobile_phone, ''),
        IFNULL(p_email, ''),
        IFNULL(p_web_site, ''),
        IFNULL(p_contact_person, ''),
        IFNULL(p_position, ''),
        IFNULL(p_gender, 'Male')
    );

    SET v_new_id = LAST_INSERT_ID();

    SELECT * FROM `suppliers` WHERE `id` = v_new_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_update_supplier
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_update_supplier`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_update_supplier`(
    IN p_id             INT,
    IN p_sup_code       VARCHAR(50),
    IN p_company_name   VARCHAR(200),
    IN p_address        VARCHAR(500),
    IN p_phone          VARCHAR(30),
    IN p_fax_no         VARCHAR(30),
    IN p_mobile_phone   VARCHAR(30),
    IN p_email          VARCHAR(150),
    IN p_web_site       VARCHAR(255),
    IN p_contact_person VARCHAR(150),
    IN p_position       VARCHAR(100),
    IN p_gender         VARCHAR(10)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    UPDATE `suppliers`
    SET
        `sup_code`       = IFNULL(p_sup_code, `sup_code`),
        `company_name`   = IFNULL(p_company_name, `company_name`),
        `address`        = IFNULL(p_address, `address`),
        `phone`          = IFNULL(p_phone, `phone`),
        `fax_no`         = IFNULL(p_fax_no, `fax_no`),
        `mobile_phone`   = IFNULL(p_mobile_phone, `mobile_phone`),
        `email`          = IFNULL(p_email, `email`),
        `web_site`       = IFNULL(p_web_site, `web_site`),
        `contact_person` = IFNULL(p_contact_person, `contact_person`),
        `position`       = IFNULL(p_position, `position`),
        `gender`         = IFNULL(p_gender, `gender`),
        `updated_at`     = NOW()
    WHERE `id` = p_id;

    SELECT * FROM `suppliers` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_delete_supplier
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_delete_supplier`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_delete_supplier`(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    DELETE FROM `suppliers` WHERE `id` = p_id;

    SELECT ROW_COUNT() AS affected_rows;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- TRANSACTIONS MODULE (CHECKOUT / CHECKIN)
-- ============================================================================

-- ------------------------------------
-- sp_get_all_transactions
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_all_transactions`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_all_transactions`(
    IN p_status      VARCHAR(20),
    IN p_borrower_id INT,
    IN p_search      VARCHAR(255)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        t.*,
        b.`title`    AS book_title,
        b.`barcode`  AS book_barcode,
        b.`author`   AS book_author,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name,
        br.`id_no`   AS borrower_id_no
    FROM `transactions` t
    INNER JOIN `books` b      ON t.`book_id`     = b.`id`
    INNER JOIN `borrowers` br ON t.`borrower_id` = br.`id`
    WHERE
        (p_status IS NULL OR p_status = '' OR t.`status` = p_status)
        AND (p_borrower_id IS NULL OR p_borrower_id = 0 OR t.`borrower_id` = p_borrower_id)
        AND (p_search IS NULL OR p_search = '' OR
            b.`title`     LIKE CONCAT('%', p_search, '%') OR
            b.`barcode`   LIKE CONCAT('%', p_search, '%') OR
            br.`firstname` LIKE CONCAT('%', p_search, '%') OR
            br.`lastname`  LIKE CONCAT('%', p_search, '%'))
    ORDER BY t.`created_at` DESC;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_borrower_loans
-- Active/Overdue loans for a specific borrower.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_borrower_loans`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_borrower_loans`(
    IN p_borrower_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        t.*,
        b.`title`   AS book_title,
        b.`barcode` AS book_barcode
    FROM `transactions` t
    INNER JOIN `books` b ON t.`book_id` = b.`id`
    WHERE t.`borrower_id` = p_borrower_id
      AND t.`status` IN ('Loaned', 'Overdue')
    ORDER BY t.`due_date` ASC;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_checkout_book
-- Creates a loan transaction and decrements copies_available.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_checkout_book`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_checkout_book`(
    IN p_book_id     INT,
    IN p_borrower_id INT,
    IN p_loan_date   DATE,
    IN p_due_date    DATE,
    IN p_notes       TEXT
)
BEGIN
    DECLARE v_copies INT DEFAULT 0;
    DECLARE v_book_exists INT DEFAULT 0;
    DECLARE v_borrower_exists INT DEFAULT 0;
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    -- Validate book exists and has copies
    SELECT COUNT(*), IFNULL(MAX(`copies_available`), 0)
      INTO v_book_exists, v_copies
      FROM `books`
      WHERE `id` = p_book_id;

    IF v_book_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not found';
    END IF;

    IF v_copies <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No copies available';
    END IF;

    -- Validate borrower exists
    SELECT COUNT(*) INTO v_borrower_exists FROM `borrowers` WHERE `id` = p_borrower_id;
    IF v_borrower_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Borrower not found';
    END IF;

    -- Create the transaction
    INSERT INTO `transactions` (`book_id`, `borrower_id`, `loan_date`, `due_date`, `notes`, `status`)
    VALUES (
        p_book_id,
        p_borrower_id,
        IFNULL(p_loan_date, CURDATE()),
        p_due_date,
        IFNULL(p_notes, ''),
        'Loaned'
    );

    SET v_new_id = LAST_INSERT_ID();

    -- Decrement available copies
    UPDATE `books`
    SET `copies_available` = `copies_available` - 1
    WHERE `id` = p_book_id;

    -- Return the created transaction with joined data
    SELECT
        t.*,
        b.`title`   AS book_title,
        b.`barcode` AS book_barcode,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name
    FROM `transactions` t
    INNER JOIN `books` b      ON t.`book_id`     = b.`id`
    INNER JOIN `borrowers` br ON t.`borrower_id` = br.`id`
    WHERE t.`id` = v_new_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_checkin_book
-- Processes a book return, calculates fines, increments copies_available.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_checkin_book`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_checkin_book`(
    IN p_transaction_id INT,
    IN p_return_date    DATE,
    IN p_fine_amount    DECIMAL(10,2),
    IN p_past_due_fines DECIMAL(10,2),
    IN p_notes          TEXT
)
BEGIN
    DECLARE v_status VARCHAR(20);
    DECLARE v_book_id INT;
    DECLARE v_total_fine DECIMAL(10,2);
    DECLARE v_return DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    -- Fetch existing transaction
    SELECT `status`, `book_id`
      INTO v_status, v_book_id
      FROM `transactions`
      WHERE `id` = p_transaction_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    IF v_status = 'Returned' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book already returned';
    END IF;

    SET v_return     = IFNULL(p_return_date, CURDATE());
    SET v_total_fine = IFNULL(p_fine_amount, 0) + IFNULL(p_past_due_fines, 0);

    -- Update transaction
    UPDATE `transactions`
    SET
        `return_date`    = v_return,
        `fine_amount`    = IFNULL(p_fine_amount, 0),
        `past_due_fines` = IFNULL(p_past_due_fines, 0),
        `total_fine`     = v_total_fine,
        `status`         = 'Returned',
        `notes`          = COALESCE(p_notes, `notes`),
        `updated_at`     = NOW()
    WHERE `id` = p_transaction_id;

    -- Increment available copies
    UPDATE `books`
    SET `copies_available` = `copies_available` + 1
    WHERE `id` = v_book_id;

    -- Return updated transaction
    SELECT
        t.*,
        b.`title`   AS book_title,
        b.`barcode` AS book_barcode,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name
    FROM `transactions` t
    INNER JOIN `books` b      ON t.`book_id`     = b.`id`
    INNER JOIN `borrowers` br ON t.`borrower_id` = br.`id`
    WHERE t.`id` = p_transaction_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_renew_loan
-- Extends the due date of an active loan.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_renew_loan`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_renew_loan`(
    IN p_transaction_id INT,
    IN p_new_due_date   DATE
)
BEGIN
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT `status` INTO v_status FROM `transactions` WHERE `id` = p_transaction_id;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;

    IF v_status = 'Returned' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book already returned';
    END IF;

    UPDATE `transactions`
    SET
        `due_date`   = p_new_due_date,
        `updated_at` = NOW()
    WHERE `id` = p_transaction_id;

    SELECT * FROM `transactions` WHERE `id` = p_transaction_id;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- RESERVATIONS MODULE
-- ============================================================================

-- ------------------------------------
-- sp_get_all_reservations
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_all_reservations`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_all_reservations`(
    IN p_status      VARCHAR(20),
    IN p_borrower_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        r.*,
        b.`title`            AS book_title,
        b.`barcode`          AS book_barcode,
        b.`copies_available` AS copies_available,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name,
        br.`id_no`           AS borrower_id_no
    FROM `reservations` r
    INNER JOIN `books` b      ON r.`book_id`     = b.`id`
    INNER JOIN `borrowers` br ON r.`borrower_id` = br.`id`
    WHERE
        (p_status IS NULL OR p_status = '' OR r.`status` = p_status)
        AND (p_borrower_id IS NULL OR p_borrower_id = 0 OR r.`borrower_id` = p_borrower_id)
    ORDER BY r.`reserved_on` DESC;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_create_reservation
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_create_reservation`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_create_reservation`(
    IN p_book_id          INT,
    IN p_borrower_id      INT,
    IN p_reserved_for_days INT,
    IN p_notes            TEXT
)
BEGIN
    DECLARE v_book_exists INT DEFAULT 0;
    DECLARE v_borrower_exists INT DEFAULT 0;
    DECLARE v_active_exists INT DEFAULT 0;
    DECLARE v_new_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    -- Validate book
    SELECT COUNT(*) INTO v_book_exists FROM `books` WHERE `id` = p_book_id;
    IF v_book_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Book not found';
    END IF;

    -- Validate borrower
    SELECT COUNT(*) INTO v_borrower_exists FROM `borrowers` WHERE `id` = p_borrower_id;
    IF v_borrower_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Borrower not found';
    END IF;

    -- Check for existing active reservation
    SELECT COUNT(*) INTO v_active_exists
    FROM `reservations`
    WHERE `book_id` = p_book_id AND `borrower_id` = p_borrower_id AND `status` = 'Active';

    IF v_active_exists > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Borrower already has an active reservation for this book';
    END IF;

    INSERT INTO `reservations` (`book_id`, `borrower_id`, `reserved_on`, `reserved_for_days`, `notes`)
    VALUES (p_book_id, p_borrower_id, CURDATE(), IFNULL(p_reserved_for_days, 5), IFNULL(p_notes, ''));

    SET v_new_id = LAST_INSERT_ID();

    SELECT
        r.*,
        b.`title`   AS book_title,
        b.`barcode` AS book_barcode,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name
    FROM `reservations` r
    INNER JOIN `books` b      ON r.`book_id`     = b.`id`
    INNER JOIN `borrowers` br ON r.`borrower_id` = br.`id`
    WHERE r.`id` = v_new_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_update_reservation
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_update_reservation`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_update_reservation`(
    IN p_id     INT,
    IN p_status VARCHAR(20),
    IN p_notes  TEXT
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT COUNT(*) INTO v_exists FROM `reservations` WHERE `id` = p_id;
    IF v_exists = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reservation not found';
    END IF;

    UPDATE `reservations`
    SET
        `status`     = IFNULL(p_status, `status`),
        `notes`      = IFNULL(p_notes, `notes`),
        `updated_at` = NOW()
    WHERE `id` = p_id;

    SELECT * FROM `reservations` WHERE `id` = p_id;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_cancel_reservation
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_cancel_reservation`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_cancel_reservation`(
    IN p_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    UPDATE `reservations`
    SET
        `status`     = 'Cancelled',
        `updated_at` = NOW()
    WHERE `id` = p_id;

    SELECT ROW_COUNT() AS affected_rows;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_book_reservation_count
-- Active reservation count for a specific book.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_book_reservation_count`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_book_reservation_count`(
    IN p_book_id INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT COUNT(*) AS `count`
    FROM `reservations`
    WHERE `book_id` = p_book_id AND `status` = 'Active';

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- DASHBOARD MODULE
-- ============================================================================

-- ------------------------------------
-- sp_get_dashboard_stats
-- Single call that returns all dashboard counters.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_dashboard_stats`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_dashboard_stats`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        (SELECT COUNT(*)   FROM `books`)                                                        AS totalBooks,
        (SELECT COUNT(*)   FROM `borrowers`)                                                    AS totalBorrowers,
        (SELECT COUNT(*)   FROM `borrowers`    WHERE `status` = 'Active')                       AS activeBorrowers,
        (SELECT COUNT(*)   FROM `transactions` WHERE `status` = 'Loaned')                       AS activeLoans,
        (SELECT COUNT(*)   FROM `transactions` WHERE `status` = 'Loaned' AND `due_date` < CURDATE()) AS overdueLoans,
        (SELECT COUNT(*)   FROM `reservations` WHERE `status` = 'Active')                       AS activeReservations,
        (SELECT COUNT(*)   FROM `suppliers`)                                                    AS totalSuppliers,
        (SELECT COUNT(*)   FROM `transactions` WHERE `status` = 'Returned')                     AS totalReturned,
        (SELECT COALESCE(SUM(`total_fine`), 0) FROM `transactions`)                             AS totalFines;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_recent_loans
-- Last 10 transactions for dashboard.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_recent_loans`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_recent_loans`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT
        t.*,
        b.`title` AS book_title,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name
    FROM `transactions` t
    INNER JOIN `books` b      ON t.`book_id`     = b.`id`
    INNER JOIN `borrowers` br ON t.`borrower_id` = br.`id`
    ORDER BY t.`created_at` DESC
    LIMIT 10;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_books_by_type
-- Book count grouped by type for dashboard chart.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_books_by_type`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_books_by_type`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT `type`, COUNT(*) AS `count`
    FROM `books`
    GROUP BY `type`;

    COMMIT;
END$$

DELIMITER ;


-- ------------------------------------
-- sp_get_borrowers_by_type
-- Borrower count grouped by type for dashboard chart.
-- ------------------------------------
DELIMITER $$

USE `bisublar_cis`$$

DROP PROCEDURE IF EXISTS `sp_get_borrowers_by_type`$$

CREATE DEFINER=`bisublar_cis`@`%` PROCEDURE `sp_get_borrowers_by_type`()
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;

    SELECT `type`, COUNT(*) AS `count`
    FROM `borrowers`
    GROUP BY `type`;

    COMMIT;
END$$

DELIMITER ;


-- ============================================================================
-- END OF SCRIPT
-- ============================================================================
