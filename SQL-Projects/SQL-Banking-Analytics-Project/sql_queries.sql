-- =============================================
-- SQL Banking Analytics Project
-- Author: Harsh Nuwal
-- Database: MySQL
-- Description: Customer and transaction analysis
-- =============================================

-- =====================
-- TABLE: customers
-- =====================
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    city VARCHAR(50),
    account_type VARCHAR(20),
    join_date DATE
);

-- =====================
-- TABLE: accounts
-- =====================
CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    balance DECIMAL(12,2),
    credit_score INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- =====================
-- TABLE: transactions
-- =====================
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_date DATE,
    transaction_type VARCHAR(10),
    amount DECIMAL(12,2),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id)
);




-- =============================================
-- BASIC ANALYSIS
-- =============================================

-- Total number of customers
SELECT COUNT(*) AS total_customers
FROM customers;

-- Average account balance by account type
SELECT 
    c.account_type,
    AVG(a.balance) AS avg_balance
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
GROUP BY c.account_type;




-- =============================================
-- INTERMEDIATE ANALYSIS
-- =============================================

-- City-wise total transaction amount
SELECT 
    c.city,
    SUM(t.amount) AS total_transaction_amount
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.city
ORDER BY total_transaction_amount DESC;

-- Debit vs Credit transaction comparison
SELECT 
    transaction_type,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount
FROM transactions
GROUP BY transaction_type;

-- Top 10 customers by total transaction amount
SELECT 
    c.customer_id,
    c.customer_name,
    SUM(t.amount) AS total_transaction_amount
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
JOIN transactions t ON a.account_id = t.account_id
GROUP BY c.customer_id, c.customer_name
ORDER BY total_transaction_amount DESC
LIMIT 10;




-- =============================================
-- ADVANCED ANALYSIS
-- =============================================

-- Customer segmentation based on account balance
SELECT 
    c.customer_id,
    c.customer_name,
    a.balance,
    CASE
        WHEN a.balance >= 500000 THEN 'High Value'
        WHEN a.balance BETWEEN 100000 AND 499999 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id;

-- Identify potential high-risk customers
-- (Low balance and low credit score)
SELECT 
    c.customer_id,
    c.customer_name,
    a.balance,
    a.credit_score
FROM customers c
JOIN accounts a ON c.customer_id = a.customer_id
WHERE a.balance < 50000
  AND a.credit_score < 600;




-- =============================================
-- WINDOW FUNCTION ANALYSIS
-- =============================================

-- Monthly transaction trend with cumulative amount
SELECT
    DATE_FORMAT(t.transaction_date, '%Y-%m') AS transaction_month,
    SUM(t.amount) AS monthly_transaction_amount,
    SUM(SUM(t.amount)) OVER (
        ORDER BY DATE_FORMAT(t.transaction_date, '%Y-%m')
    ) AS cumulative_transaction_amount
FROM transactions t
GROUP BY transaction_month
ORDER BY transaction_month;
