CREATE DATABASE IF NOT EXISTS labapp CHARACTER SET utf8mb4;
CREATE TABLE IF NOT EXISTS labapp.visitors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    note VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO labapp.visitors (name, note) VALUES
    ('Fishir', 'entri awal mini project'),
    ('Kelompok 2', 'web server konek ke DB remote');
-- user yang hanya boleh konek dari web server 10.20.2.10
CREATE USER IF NOT EXISTS 'webapp'@'10.20.2.10' IDENTIFIED BY 'WebApp#1206';
GRANT SELECT, INSERT, UPDATE, DELETE ON labapp.* TO 'webapp'@'10.20.2.10';
FLUSH PRIVILEGES;
