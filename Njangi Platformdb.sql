-- =========================================
-- Create Database
-- =========================================
CREATE DATABASE IF NOT EXISTS njangi_system;
USE njangi_system;

-- =========================================
-- 1. USER TABLE
-- =========================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'member') NOT NULL DEFAULT 'member',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================
-- 2. WALLET TABLE
-- =========================================
CREATE TABLE wallets (
    wallet_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    balance DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_wallet_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- =========================================
-- 3. NJANGI GROUP TABLE
-- =========================================
CREATE TABLE njangi_groups (
    group_id INT AUTO_INCREMENT PRIMARY KEY,
    group_name VARCHAR(100) NOT NULL,
    contribution_amount DECIMAL(10,2) NOT NULL,
    cycle_duration INT NOT NULL,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_group_creator
        FOREIGN KEY (created_by) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- =========================================
-- 4. GROUP MEMBER TABLE (Junction Table)
-- =========================================
CREATE TABLE group_members (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NOT NULL,
    join_date DATE NOT NULL,
    CONSTRAINT fk_member_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_member_group
        FOREIGN KEY (group_id) REFERENCES njangi_groups(group_id)
        ON DELETE CASCADE
);

-- =========================================
-- 5. MOBILE MONEY ACCOUNT TABLE
-- =========================================
CREATE TABLE mobile_money_accounts (
    mma_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    provider ENUM('MTN', 'Orange') NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    verified_status BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_mma_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);

-- =========================================
-- 6. TRANSACTION TABLE
-- =========================================
CREATE TABLE transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_id INT NULL,
    mma_id INT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_type ENUM('deposit', 'withdrawal', 'njangi_contribution') NOT NULL,
    payment_method ENUM('wallet', 'mobile_money') NOT NULL,
    transaction_status ENUM('pending', 'successful', 'failed') NOT NULL,
    external_reference VARCHAR(100) NULL,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_transaction_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_transaction_group
        FOREIGN KEY (group_id) REFERENCES njangi_groups(group_id)
        ON DELETE SET NULL,

    CONSTRAINT fk_transaction_mma
        FOREIGN KEY (mma_id) REFERENCES mobile_money_accounts(mma_id)
        ON DELETE SET NULL
);

-- =========================================
-- 7. OPTIONAL: PAYMENT REQUEST TABLE
-- =========================================
CREATE TABLE payment_requests (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    provider ENUM('MTN', 'Orange') NOT NULL,
    status ENUM('pending', 'completed', 'failed') NOT NULL,
    request_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    response_time TIMESTAMP NULL,
    CONSTRAINT fk_payment_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE
);