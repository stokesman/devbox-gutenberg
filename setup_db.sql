-- Development instance
CREATE DATABASE IF NOT EXISTS devbox_gutenberg_wp;

USE devbox_gutenberg_wp;

CREATE USER IF NOT EXISTS 'devbox_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON devbox_gutenberg_wp.* TO 'devbox_user'@'localhost';


-- Testing instance
CREATE DATABASE IF NOT EXISTS devbox_gutenberg_wp_test;

USE devbox_gutenberg_wp_test;

CREATE USER IF NOT EXISTS 'devbox_user'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON devbox_gutenberg_wp_test.* TO 'devbox_user'@'localhost';

-- Connect in WordPress using: 
-- Database: devbox_gutenberg_(wp|test)
-- User: devbox_user
-- Password: password
-- Host: 127.0.0.1
-- Port: 3306