-- ============================================================================
-- Daily Progress & Stories Micro-Blogging System - Database Schema
-- ============================================================================
-- This schema creates a secure database structure for the portfolio's
-- daily updates system. Only authenticated admins can add stories,
-- but all visitors can read the public feed.
-- ============================================================================

-- Create the main database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS `portfolio_stories` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `portfolio_stories`;

-- ============================================================================
-- Stories Table: Stores all daily progress updates with images
-- ============================================================================
CREATE TABLE IF NOT EXISTS `stories` (
  -- Primary identifier for each story
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  
  -- File system path to the uploaded image (relative to uploads folder)
  -- Format: uploads/YYYY/MM/unique_id_filename.extension
  `image_path` VARCHAR(500) NOT NULL,
  
  -- The text content of the daily progress/story
  -- Using MEDIUMTEXT to support lengthy updates (up to 16MB)
  `story_text` MEDIUMTEXT NOT NULL,
  
  -- Auto-generated timestamp when the story is created (UTC)
  -- This is automatically set to the current timestamp on insert
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Automatic update timestamp (useful for future editing features)
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  -- Soft delete flag (for future archive functionality)
  -- 0 = published, 1 = archived
  `is_archived` TINYINT(1) DEFAULT 0,
  
  -- Indexing for optimal query performance
  -- Index on created_at to quickly fetch latest stories
  KEY `idx_created_at` (`created_at` DESC),
  
  -- Index on archived status to filter out archived stories
  KEY `idx_is_archived` (`is_archived`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Admin Credentials Table: Stores admin authentication data
-- ============================================================================
CREATE TABLE IF NOT EXISTS `admin_users` (
  -- Primary identifier
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  
  -- Admin username
  `username` VARCHAR(255) UNIQUE NOT NULL,
  
  -- Hashed password using PHP's password_hash() function (bcrypt)
  -- Length must be at least 60 characters
  `password_hash` VARCHAR(255) NOT NULL,
  
  -- Last login timestamp for security auditing
  `last_login` TIMESTAMP NULL DEFAULT NULL,
  
  -- Account creation timestamp
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Index on username for faster lookups during login
  KEY `idx_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================================
-- Insert default admin user (password: change_me_immediately)
-- To generate a new hash, use: php -r "echo password_hash('your_password', PASSWORD_BCRYPT);"
-- ============================================================================
INSERT INTO `admin_users` (`username`, `password_hash`) 
VALUES ('admin', '$2y$10$t6aJ8p2K1vNq3xL9mQ0d.uEz5kL2pQ9sM8wX4yZ6vB3cN1aO5fR2i')
ON DUPLICATE KEY UPDATE `username` = `username`;

-- ============================================================================
-- Query Examples for Reference:
-- ============================================================================
-- Fetch all published stories (newest first):
-- SELECT id, image_path, story_text, created_at FROM stories 
-- WHERE is_archived = 0 
-- ORDER BY created_at DESC;
--
-- Insert a new story:
-- INSERT INTO stories (image_path, story_text) VALUES (?, ?);
--
-- Archive a story:
-- UPDATE stories SET is_archived = 1 WHERE id = ?;
-- ============================================================================
