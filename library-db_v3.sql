/*
SQLyog Ultimate v9.62 
MySQL - 5.7.44-48 : Database - bisublar_lss
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`bisublar_lss` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;

USE `bisublar_lss`;

/*Table structure for table `books` */

DROP TABLE IF EXISTS `books`;

CREATE TABLE `books` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `author` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `co_author` varchar(300) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'Book',
  `publisher` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `place` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `date_published` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `volume` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `series` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `category` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `format` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `editor` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `illustrator` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `pages` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `isbn` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `physical_desc` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `accession_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `call_no` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `barcode` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `circulation_type` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'Loanable',
  `price` decimal(10,2) DEFAULT '0.00',
  `value` decimal(10,2) DEFAULT '0.00',
  `purchased_date` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `evaluated_date` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `acquisition_date` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `copies_available` int(11) DEFAULT '1',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_books_barcode` (`barcode`),
  KEY `idx_books_title` (`title`(100)),
  KEY `idx_books_isbn` (`isbn`),
  KEY `idx_books_category` (`category`)
) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `books` */

insert  into `books`(`id`,`title`,`author`,`co_author`,`type`,`publisher`,`place`,`date_published`,`volume`,`series`,`category`,`format`,`editor`,`illustrator`,`pages`,`isbn`,`physical_desc`,`accession_no`,`call_no`,`barcode`,`location`,`circulation_type`,`price`,`value`,`purchased_date`,`evaluated_date`,`acquisition_date`,`copies_available`,`created_at`,`updated_at`) values (1,'Introduction to Information Technology','Efraim Turban','Linda Volonino','Book','McGraw-Hill Education','New York','2021','','','Information Technology','','','','612','978-0-07-352285-2','','ACC-001','QA76.T87 2021','BK-000001','Main Shelf A1','Loanable','1850.00','0.00','','','',3,'2026-03-11 21:51:53','2026-03-11 21:51:53'),(2,'Fundamentals of Programming: C and C++','Richard L. Halterman',NULL,'Book','Southern Adventist University Press','Tennessee','2019','','','Programming','','','','428','978-1-4920-7339-0','','ACC-002','QA76.73.C H35 2019','BK-000002','Main Shelf A1','Loanable','1200.00','0.00','','','',2,'2026-03-11 21:51:53','2026-03-16 02:07:21'),(3,'Calculus: Early Transcendentals','James Stewart','Daniel Clegg','Book','Cengage Learning','Boston','2020','','','Mathematics','','','','1156','978-1-337-61392-7','','ACC-003','QA303.2.S74 2020','BK-000003','Main Shelf B2','Loanable','2400.00','0.00','','','',2,'2026-03-11 21:51:54','2026-03-24 20:06:47'),(4,'Philippine History: A Comprehensive Study','Milagros Guerrero','Emmanuel Encarnacion','Book','Rex Book Store','Manila','2018','','','Philippine History','','','','380','978-971-23-8765-4','','ACC-004','DS661.G84 2018','BK-000004','Main Shelf C3','Loanable','950.00','0.00','','','',5,'2026-03-11 21:51:54','2026-03-11 21:51:54'),(5,'Biology: The Science of Life','Robert A. Wallace','Gerald P. Sanders','Book','HarperCollins','New York','2020','','','Biology','','','','870','978-0-06-046182-1','','ACC-005','QH307.2.W35 2020','BK-000005','Main Shelf B3','Loanable','5750.67','0.00','','','',7,'2026-03-11 21:51:55','2026-08-04 09:38:53'),(6,'Principles of Economics','N. Gregory Mankiw',NULL,'Book','Cengage Learning','Mason, Ohio','2021','','','Economics','','','','888','978-0-357-03831-4','','ACC-006','HB171.5.M36 2021','BK-000006','Main Shelf D1','Loanable','2200.00','0.00','','','',2,'2026-03-11 21:51:55','2026-03-11 21:51:55'),(7,'Noli Me Tangere','Jose Rizal',NULL,'Book','Bookmark Inc.','Makati','2017','','','Filipino Literature','','','','396','978-971-569-600-3','','ACC-007','PQ8897.R59 N6 2017','BK-000007','Filipino Works Shelf','Loanable','450.00','0.00','','','',7,'2026-03-11 21:51:55','2026-03-24 20:14:30'),(8,'El Filibusterismo','Jose Rizal',NULL,'Book','Bookmark Inc.','Makati','2017','','','Filipino Literature','','','','348','978-971-569-601-0','','ACC-008','PQ8897.R59 E4 2017','BK-000008','Filipino Works Shelf','Loanable','450.00','0.00','','','',7,'2026-03-11 21:51:56','2026-03-12 01:31:56'),(9,'General Chemistry','Darrell D. Ebbing','Steven D. Gammon','Book','Cengage Learning','Boston','2022','','','Chemistry','','','','1120','978-0-357-36624-1','','ACC-009','QD33.2.E22 2022','BK-000009','Main Shelf B1','Loanable','2600.00','0.00','','','',3,'2026-03-11 21:51:56','2026-03-11 21:51:56'),(10,'Introduction to Psychology','James W. Kalat',NULL,'Book','Cengage Learning','Belmont, CA','2019','','','Psychology','','','','628','978-1-337-56528-9','','ACC-010','BF121.K35 2019','BK-000010','Main Shelf D2','Loanable','1900.00','0.00','','','',2,'2026-03-11 21:51:57','2026-03-11 21:51:57'),(11,'Database Management Systems','Ramez Elmasri','Sham Navathe','Book','Pearson Education','Hoboken, NJ','2020','','','Information Technology','','','','1034','978-0-13-468859-5','','ACC-011','QA76.9.D3 E45 2020','BK-000011','Main Shelf A2','Loanable','2800.00','0.00','','','',1,'2026-03-11 21:51:57','2026-03-23 03:20:54'),(12,'Principles of Marketing','Philip Kotler','Gary Armstrong','Book','Pearson Education','Hoboken, NJ','2021','','','Business & Management','','','','752','978-0-13-671232-1','','ACC-012','HF5415.K636 2021','BK-000012','Main Shelf D1','Loanable','2100.00','0.00','','','',3,'2026-03-11 21:51:57','2026-03-11 21:51:57'),(13,'Fundamentals of Nursing: Concepts and Application','Barbara Kozier','Glenora Erb','Book','Pearson Education','Upper Saddle River, NJ','2021','','','Nursing','','','','1840','978-0-13-558016-5','','ACC-013','RT41.K69 2021','BK-000013','Health Sciences Shelf','Loanable','3200.00','0.00','','','',1,'2026-03-11 21:51:58','2026-03-23 11:23:30'),(14,'Environmental Science: Toward a Sustainable Future','Richard T. Wright','Dorothy F. Boorse','Book','Pearson Education','Boston','2020','','','Environmental Science','','','','704','978-0-13-449637-0','','ACC-014','GE105.W75 2020','BK-000014','Main Shelf B4','Loanable','1850.00','0.00','','','',3,'2026-03-11 21:51:58','2026-03-16 01:37:16'),(15,'The Art of Teaching','Gilbert Highet',NULL,'Book','Vintage Books','New York','2018','','','Education','','','','291','978-0-394-70121-5','','ACC-015','LB1025.H5 2018','BK-000015','Education Shelf','Loanable','780.00','0.00','','','',4,'2026-03-11 21:51:59','2026-03-11 21:51:59'),(16,'Bohol: A Cultural Heritage Guide','Carlos V. Celdran',NULL,'Book','Anvil Publishing','Mandaluyong','2019','','','Local Studies','','','','215','978-971-27-3356-7','','ACC-016','DS688.B65 C45 2019','BK-000016','Filipiniana Shelf','Reference','620.00','0.00','','','',2,'2026-03-11 21:51:59','2026-04-13 03:13:10'),(17,'Technical Communication: Principles and Practice','Meenakshi Raman','Sangeeta Sharma','Book','Oxford University Press','New Delhi','2021','','','Communication','','','','415','978-0-19-947490-3','','ACC-017','T10.5.R36 2021','BK-000017','Main Shelf C1','Loanable','1100.00','0.00','','','',5,'2026-03-11 21:51:59','2026-03-11 21:51:59'),(18,'Agricultural Science: Foundations and Applications','Ray V. Herren',NULL,'Book','Delmar Cengage Learning','Clifton Park, NY','2020','','','Agriculture','','','','592','978-1-4354-8815-5','','ACC-018','S521.H47 2020','BK-000018','Agriculture Shelf','Loanable','1650.00','0.00','','','',58,'2026-03-11 21:52:00','2026-08-16 02:16:41'),(19,'Web Development and Design Foundations with HTML5','Terry Felke-Morris',NULL,'Book','Pearson Education','Hoboken, NJ','2022','','','Information Technology','','','','590','978-0-13-758994-3','','ACC-019','TK5105.888.F45 2022','BK-000019','Main Shelf A3','Loanable','2050.00','0.00','','','',2,'2026-03-11 21:52:00','2026-03-24 20:02:37'),(20,'Rizal Without the Overcoat','Ambeth R. Ocampo',NULL,'Book','Anvil Publishing','Mandaluyong','2020','','','Filipino Literature','','','','224','978-971-27-2980-5','','ACC-020','CT1930.R59 O23 2020','BK-000020','Filipiniana Shelf','Loanable','420.00','0.00','','','',6,'2026-03-11 21:52:01','2026-03-11 21:52:01'),(32,'Hambog ng Sagropo','Allen Kalbo','','Book','Kalbo Company','','','','','','','','','','','','88744','099980988','777777','Ibabaw sa lamesa','Loanable','112.12','80.00','','','',4,'2026-03-24 20:10:32','2026-04-13 02:34:45'),(33,'Game','authority','authorirty','Thesis','wala','','','','','yes','no','','','','90909009','','67865695','243284',NULL,'rack 4','Loanable','120.00','66.00','','','',40,'2026-08-03 13:33:40','2026-08-03 13:33:40');

/*Table structure for table `borrowers` */

DROP TABLE IF EXISTS `borrowers`;

CREATE TABLE `borrowers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `id_no` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `firstname` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lastname` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mobile_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `address` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `date_registered` date DEFAULT NULL,
  `type` enum('Student','Faculty','Others') COLLATE utf8mb4_unicode_ci DEFAULT 'Student',
  `status` enum('Active','Inactive') COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_borrowers_id_no` (`id_no`)
) ENGINE=InnoDB AUTO_INCREMENT=23 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `borrowers` */

insert  into `borrowers`(`id`,`id_no`,`firstname`,`lastname`,`mobile_phone`,`phone`,`email`,`address`,`notes`,`date_registered`,`type`,`status`,`created_at`,`updated_at`) values (4,'513113','jho','nel','09475816664','','jho66@gmail.com','dimakita st.','tetris','2026-03-11','Student','Active','2026-03-11 23:25:22','2026-03-11 23:25:22'),(6,'443322','gg','ff','06548752','','zak44@gmail.com','vaseee','','2026-03-12','Student','Active','2026-03-12 01:30:56','2026-03-12 02:19:24'),(7,'123456','zach','lumantas','555645','','email@gmail.com','secret','Pending admin approval','2026-08-04','Student','Active','2026-03-13 21:51:57','2026-08-16 02:24:58'),(8,'ADMIN','Administrator','-','','','','','Auto-created borrower profile','2026-03-16','Student','Active','2026-03-16 02:53:37','2026-03-16 02:53:37'),(9,'12345678','staff','-','','','','','Auto-created borrower profile','2026-03-23','Student','Active','2026-03-23 09:30:56','2026-03-23 09:30:56'),(10,'443311','zach','lumantas','','','','','','2026-03-23','Student','Active','2026-03-23 10:55:33','2026-03-23 10:55:33'),(11,'787890','edward','vinuya','09865544322','','','','Department: College of Technology','2026-03-23','Student','Active','2026-03-23 11:11:45','2026-03-23 11:11:45'),(12,'1234567','circulation','-','','','','','Auto-created borrower profile','2026-03-23','Student','Active','2026-03-23 11:15:33','2026-03-23 11:15:33'),(13,'946569','Mark','Manla','09705672618','','','','Department: CTECH','2026-03-24','Student','Active','2026-03-24 20:00:48','2026-03-24 20:00:48'),(14,'878787','ᜆᜅᜂᜁᜀᜈ','ᜆᜅᜂᜁᜀᜈ','09886998777','','','','Department: ᜆᜅᜂᜁ','2026-04-13','Student','Active','2026-04-13 02:33:53','2026-04-13 02:33:53'),(15,'223778','kevin','esto','09654434567','','','','Department: CTECH','2026-04-13','Student','Active','2026-04-13 02:37:31','2026-04-13 02:37:31'),(16,'4564564','sd','g','09877665455','','','','Department: ctech','2026-04-22','Student','Active','2026-04-22 23:25:18','2026-04-22 23:25:18'),(17,'248823','Mark Allene','CAyda','09942607330','','','','Department: Ctech','2026-04-23','Student','Active','2026-04-23 00:33:36','2026-04-23 00:33:36'),(18,'123457','xak','lee','09480532777','','','','Department: college of technology','2026-08-03','Student','Active','2026-08-03 13:21:30','2026-08-03 13:21:30'),(19,'443326','librarian','-','','','','','Auto-created borrower profile','2026-08-03','Student','Active','2026-08-03 13:44:15','2026-08-03 13:44:15'),(20,'443325','ZACH','ANDREW','09480532777','','zak@gmail.com','address','Pending admin approval','2026-08-04','Student','Inactive','2026-08-03 21:15:25','2026-08-04 09:00:51'),(21,'LIBADMIN','Library','Administrator','','','','','Auto-created borrower profile','2026-08-04','Student','Active','2026-08-04 09:08:00','2026-08-04 09:08:00'),(22,'STAFF01','Library','Staff','','','','','Auto-created borrower profile','2026-08-04','Student','Active','2026-08-04 09:36:31','2026-08-04 09:36:31');

/*Table structure for table `reservations` */

DROP TABLE IF EXISTS `reservations`;

CREATE TABLE `reservations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `book_id` int(11) NOT NULL,
  `borrower_id` int(11) NOT NULL,
  `reserved_on` date DEFAULT NULL,
  `reserved_for_days` int(11) DEFAULT '5',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `status` enum('Active','Fulfilled','Cancelled','Expired') COLLATE utf8mb4_unicode_ci DEFAULT 'Active',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reservations_status` (`status`),
  KEY `idx_reservations_borrower` (`borrower_id`),
  KEY `idx_reservations_book` (`book_id`),
  CONSTRAINT `fk_reservations_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_reservations_borrower` FOREIGN KEY (`borrower_id`) REFERENCES `borrowers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `reservations` */

/*Table structure for table `suppliers` */

DROP TABLE IF EXISTS `suppliers`;

CREATE TABLE `suppliers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sup_code` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `company_name` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `address` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `fax_no` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `mobile_phone` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `email` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `web_site` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `contact_person` varchar(150) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `position` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `gender` enum('Male','Female','Other') COLLATE utf8mb4_unicode_ci DEFAULT 'Male',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_suppliers_sup_code` (`sup_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `suppliers` */

/*Table structure for table `transactions` */

DROP TABLE IF EXISTS `transactions`;

CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `book_id` int(11) NOT NULL,
  `borrower_id` int(11) NOT NULL,
  `loan_date` date DEFAULT NULL,
  `due_date` date NOT NULL,
  `return_date` date DEFAULT NULL,
  `fine_amount` decimal(10,2) DEFAULT '0.00',
  `past_due_fines` decimal(10,2) DEFAULT '0.00',
  `total_fine` decimal(10,2) DEFAULT '0.00',
  `notes` text COLLATE utf8mb4_unicode_ci,
  `status` enum('Loaned','Returned','Overdue') COLLATE utf8mb4_unicode_ci DEFAULT 'Loaned',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transactions_status` (`status`),
  KEY `idx_transactions_borrower` (`borrower_id`),
  KEY `idx_transactions_book` (`book_id`),
  CONSTRAINT `fk_transactions_book` FOREIGN KEY (`book_id`) REFERENCES `books` (`id`) ON UPDATE CASCADE,
  CONSTRAINT `fk_transactions_borrower` FOREIGN KEY (`borrower_id`) REFERENCES `borrowers` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `transactions` */

insert  into `transactions`(`id`,`book_id`,`borrower_id`,`loan_date`,`due_date`,`return_date`,`fine_amount`,`past_due_fines`,`total_fine`,`notes`,`status`,`created_at`,`updated_at`) values (1,5,17,'2026-08-04','2026-08-07','2026-08-04','0.00','0.00','0.00','','Returned','2026-08-04 09:38:17','2026-08-04 09:38:53'),(2,18,7,'2026-08-04','2026-08-07','2026-08-16','45.00','0.00','45.00','','Returned','2026-08-04 10:31:20','2026-08-16 02:15:16'),(3,18,7,'2026-08-16','2026-08-16',NULL,'0.00','0.00','0.00','','Loaned','2026-08-16 02:16:41','2026-08-16 02:16:41');

/*Table structure for table `users` */

DROP TABLE IF EXISTS `users`;

CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `designation` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT '',
  `access_right` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT 'USER',
  `is_admin` tinyint(1) DEFAULT '0',
  `status` enum('APPROVED','PENDING','DENIED') COLLATE utf8mb4_unicode_ci DEFAULT 'APPROVED',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/*Data for the table `users` */

insert  into `users`(`id`,`user_id`,`username`,`password`,`designation`,`access_right`,`is_admin`,`status`,`created_at`,`updated_at`) values (1,'ADMIN','ADMIN USER','ADMIN','Librarian','ADMINISTRATOR',1,'APPROVED','2026-08-04 08:52:59','2026-08-04 08:59:19'),(2,'443325','ZACH ANDREW','$2b$10$dIhfVdLhDwycu0BfwDxsoO1nr93bjztprqqzR4RCykGx60JtiMpFK','Borrower','BORROWER',0,'APPROVED','2026-08-04 09:00:50','2026-08-04 09:05:19'),(3,'LIBADMIN','Library Administrator','$2b$10$p.egf4eNZoum.7E16mPe3u1FLuZRya4uFs456DlpahsJrqY75.A2O','Librarian','ADMINISTRATOR',1,'APPROVED','2026-08-04 09:06:59','2026-08-04 09:06:59'),(4,'CIRCSTAFF','Circulation In Charge','$2b$10$B6PGeB6CsY32tJCw3i9JvOLUhcToOZw6Hg8UF02x4JNh1qvzgyD3y','Circulation In Charge','CIRCULATION_IN_CHARGE',0,'APPROVED','2026-08-04 09:10:54','2026-08-16 02:22:15'),(5,'STAFF01','Library Staff','$2b$10$WApKnwpbKEnCqv33u/DgSeIs8UPD.NttoMy6v3ZcgxPJs0WMshto2','Library Staff','STAFF',0,'APPROVED','2026-08-04 09:15:54','2026-08-04 09:36:08'),(6,'123456','zach lumantas','$2b$10$caqv.jZeWb3cKTZjZuyAROYpNyARQqOznta7TdWS2aoGviDvlDfJm','Borrower','BORROWER',0,'APPROVED','2026-08-04 10:29:31','2026-08-16 02:24:58');

/* Procedure structure for procedure `sp_cancel_reservation` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_cancel_reservation` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_cancel_reservation`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_checkin_book` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_checkin_book` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_checkin_book`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_checkout_book` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_checkout_book` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_checkout_book`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_book` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_book` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_create_book`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_borrower` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_borrower` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_create_borrower`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_reservation` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_reservation` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_create_reservation`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_supplier` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_supplier` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_create_supplier`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_create_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_create_user` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_create_user`(
    IN p_user_id      VARCHAR(50),
    IN p_username     VARCHAR(100),
    IN p_password     VARCHAR(255),
    IN p_designation  VARCHAR(100),
    IN p_access_right VARCHAR(50),
    IN p_is_admin     TINYINT(1),
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
    INSERT INTO `users` (`user_id`, `username`, `password`, `designation`, `access_right`, `is_admin`, `status`)
    VALUES (p_user_id, p_username, p_password, IFNULL(p_designation, ''), IFNULL(p_access_right, 'USER'), IFNULL(p_is_admin, 0), IFNULL(p_status, 'APPROVED'));
    SET v_new_id = LAST_INSERT_ID();
    SELECT
        `id`,
        `user_id`,
        `username`,
        `designation`,
        `access_right`,
        `is_admin`,
        `status`
    FROM `users`
    WHERE `id` = v_new_id;
    COMMIT;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_delete_book` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_delete_book` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_delete_book`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_delete_borrower` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_delete_borrower` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_delete_borrower`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_delete_supplier` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_delete_supplier` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_delete_supplier`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_delete_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_delete_user` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_delete_user`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_books` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_books` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_all_books`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_borrowers` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_borrowers` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_all_borrowers`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_reservations` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_reservations` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_all_reservations`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_suppliers` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_suppliers` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_all_suppliers`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_transactions` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_transactions` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_all_transactions`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_all_users` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_all_users` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_all_users`()
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
        `status`,
        `created_at`
    FROM `users`
    ORDER BY `user_id`;
    COMMIT;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_books_by_type` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_books_by_type` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_books_by_type`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_book_by_barcode` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_book_by_barcode` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_book_by_barcode`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_book_by_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_book_by_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_book_by_id`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_book_reservation_count` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_book_reservation_count` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_book_reservation_count`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_borrowers_by_type` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_borrowers_by_type` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_borrowers_by_type`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_borrower_by_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_borrower_by_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_borrower_by_id`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_borrower_by_idno` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_borrower_by_idno` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_borrower_by_idno`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_borrower_loans` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_borrower_loans` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_borrower_loans`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_current_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_current_user` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_current_user`(
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
        `is_admin`,
        `status`
    FROM `users`
    WHERE `id` = p_id;
    COMMIT;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_dashboard_stats` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_dashboard_stats` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_dashboard_stats`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_recent_loans` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_recent_loans` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_recent_loans`()
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_get_supplier_by_id` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_get_supplier_by_id` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_get_supplier_by_id`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_renew_loan` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_renew_loan` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_renew_loan`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_book` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_book` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_update_book`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_borrower` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_borrower` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_update_borrower`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_reservation` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_reservation` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_update_reservation`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_supplier` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_supplier` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_update_supplier`(
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
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_update_user` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_update_user` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_update_user`(
    IN p_id           INT,
    IN p_username     VARCHAR(100),
    IN p_password     VARCHAR(255),
    IN p_designation  VARCHAR(100),
    IN p_access_right VARCHAR(50),
    IN p_is_admin     TINYINT(1),
    IN p_status       VARCHAR(20)
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
        `status`       = IFNULL(p_status, `status`),
        `updated_at`   = NOW()
    WHERE `id` = p_id;
    SELECT
        `id`,
        `user_id`,
        `username`,
        `designation`,
        `access_right`,
        `is_admin`,
        `status`
    FROM `users`
    WHERE `id` = p_id;
    COMMIT;
END */$$
DELIMITER ;

/* Procedure structure for procedure `sp_user_login` */

/*!50003 DROP PROCEDURE IF EXISTS  `sp_user_login` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_user_login`(
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
        `is_admin`,
        `status`
    FROM `users`
    WHERE `user_id` = p_user_id;
    COMMIT;
END */$$
DELIMITER ;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

/* ═══════════════════════════════════════════════════════════════════════════
   CASHIER / FINE PAYMENT MODULE  (added 2026-08-16)
   ═══════════════════════════════════════════════════════════════════════════ */

/* Add fine_paid flag to transactions (safe ALTER - skipped if column exists) */

ALTER TABLE `transactions`
  ADD COLUMN IF NOT EXISTS `fine_paid` TINYINT(1) NOT NULL DEFAULT 0 AFTER `total_fine`;

/*Table structure for table `fine_payments` */

DROP TABLE IF EXISTS `fine_payments`;

CREATE TABLE `fine_payments` (
  `id`                  int(11)           NOT NULL AUTO_INCREMENT,
  `transaction_id`      int(11)           NOT NULL,
  `fine_amount`         decimal(10,2)     NOT NULL DEFAULT '0.00',
  `amount_paid`         decimal(10,2)     NOT NULL DEFAULT '0.00',
  `change_given`        decimal(10,2)     NOT NULL DEFAULT '0.00',
  `payment_type`        enum('Cash')      NOT NULL DEFAULT 'Cash',
  `payment_status`      enum('Paid','Void') NOT NULL DEFAULT 'Paid',
  `received_by_user_id` varchar(50)  COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `receipt_no`          varchar(30)  COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `notes`               text         COLLATE utf8mb4_unicode_ci,
  `paid_at`             datetime          DEFAULT CURRENT_TIMESTAMP,
  `created_at`          datetime          DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_fine_payments_receipt` (`receipt_no`),
  KEY `idx_fine_payments_transaction` (`transaction_id`),
  KEY `idx_fine_payments_status` (`payment_status`),
  CONSTRAINT `fk_fine_payments_transaction`
    FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

/* Procedure structure for procedure `sp_process_fine_payment` */

/*!50003 DROP PROCEDURE IF EXISTS `sp_process_fine_payment` */;

DELIMITER $$

/*!50003 CREATE DEFINER=`bisublar_lss`@`%` PROCEDURE `sp_process_fine_payment`(
    IN p_transaction_id      INT,
    IN p_amount_paid         DECIMAL(10,2),
    IN p_payment_type        VARCHAR(10),
    IN p_received_by_user_id VARCHAR(50),
    IN p_notes               TEXT
)
BEGIN
    DECLARE v_fine_amount   DECIMAL(10,2);
    DECLARE v_fine_paid     TINYINT(1);
    DECLARE v_tx_status     VARCHAR(20);
    DECLARE v_new_id        INT;
    DECLARE v_change_given  DECIMAL(10,2);
    DECLARE v_receipt_no    VARCHAR(30);
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    -- Validate transaction
    SELECT `total_fine`, `fine_paid`, `status`
      INTO v_fine_amount, v_fine_paid, v_tx_status
      FROM `transactions`
      WHERE `id` = p_transaction_id;
    IF v_fine_amount IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction not found';
    END IF;
    IF v_fine_paid = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Fine has already been paid for this transaction';
    END IF;
    IF v_fine_amount = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This transaction has no outstanding fine';
    END IF;
    IF p_amount_paid < v_fine_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Amount paid is less than the fine amount';
    END IF;
    SET v_change_given = p_amount_paid - v_fine_amount;
    -- Insert payment record (receipt_no updated after INSERT to use LAST_INSERT_ID)
    INSERT INTO `fine_payments`
        (`transaction_id`, `fine_amount`, `amount_paid`, `change_given`,
         `payment_type`, `payment_status`, `received_by_user_id`, `receipt_no`, `notes`, `paid_at`)
    VALUES
        (p_transaction_id, v_fine_amount, p_amount_paid, v_change_given,
         IFNULL(p_payment_type, 'Cash'), 'Paid', p_received_by_user_id, '', IFNULL(p_notes, ''), NOW());
    SET v_new_id = LAST_INSERT_ID();
    -- Generate receipt number: RCPT-YYYYMMDD-NNNN
    SET v_receipt_no = CONCAT('RCPT-', DATE_FORMAT(NOW(), '%Y%m%d'), '-', LPAD(v_new_id, 4, '0'));
    UPDATE `fine_payments` SET `receipt_no` = v_receipt_no WHERE `id` = v_new_id;
    -- Mark fine as paid on transaction
    UPDATE `transactions` SET `fine_paid` = 1 WHERE `id` = p_transaction_id;
    -- Return payment record with borrower and book info
    SELECT
        fp.*,
        t.`loan_date`, t.`due_date`, t.`return_date`,
        b.`title`  AS book_title,
        b.`barcode` AS book_barcode,
        CONCAT(br.`firstname`, ' ', br.`lastname`) AS borrower_name,
        br.`id_no` AS borrower_id_no
    FROM `fine_payments` fp
    INNER JOIN `transactions` t  ON fp.`transaction_id` = t.`id`
    INNER JOIN `books`        b  ON t.`book_id`         = b.`id`
    INNER JOIN `borrowers`    br ON t.`borrower_id`     = br.`id`
    WHERE fp.`id` = v_new_id;
    COMMIT;
END */$$
DELIMITER ;

