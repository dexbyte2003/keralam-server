CREATE TABLE IF NOT EXISTS `g4-garage_list` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    `label` VARCHAR(100) NOT NULL,
    `type` VARCHAR(20) NOT NULL DEFAULT 'citizen', -- citizen, job, gang
    `coords` TEXT NOT NULL, -- JSON containing action, spawn, and delete markers
    `job_gang_name` VARCHAR(50) DEFAULT NULL,
    `min_grade` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `g4-garage_shares` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `plate` VARCHAR(12) NOT NULL,
    `citizenid` VARCHAR(50) NOT NULL,
    `shared_with` VARCHAR(50) NOT NULL,
    UNIQUE KEY `unique_share` (`plate`, `citizenid`, `shared_with`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `g4-garage_community_vehicles` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `garage_name` VARCHAR(50) NOT NULL,
    `model` VARCHAR(50) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `min_grade` INT DEFAULT 0,
    `mods` LONGTEXT DEFAULT NULL,
    `plate_type` VARCHAR(20) NOT NULL DEFAULT 'static', -- static or random
    `custom_plate` VARCHAR(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
