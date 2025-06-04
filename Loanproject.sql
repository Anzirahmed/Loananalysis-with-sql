CREATE DATABASE loan_data_db;
USE loan_data_db;
describe loan_bangladesh;
select * from loan_bangladesh;
SELECT COUNT(*) AS total_records FROM loan_bangladesh;
SHOW COLUMNS FROM loan_bangladesh;

SELECT 
    MIN(original_principal_amount) AS min_principal,
    MAX(original_principal_amount) AS max_principal,
    AVG(original_principal_amount) AS avg_principal,
    sum(original_principal_amount) AS total_principal
FROM loan_bangladesh;


SELECT 
    SUM(disbursed_amount) AS total_disbursed,
    SUM(undisbursed_amount) AS total_undisbursed
FROM loan_bangladesh;


SELECT 
    SUM(repaid_to_ibrd) AS total_repaid,
    SUM(borrowers_obligation) AS total_obligation
FROM loan_bangladesh;


1.//Retrieves the top 5 loans with the highest original principal amount
SELECT 
    loan_number,
    project_name,
    original_principal_amount,
    board_approval_date
FROM loan_bangladesh
ORDER BY original_principal_amount DESC
LIMIT 5;


2.//Shows total disbursed amount by approval year
SELECT 
    YEAR(STR_TO_DATE(board_approval_date, '%m/%d/%Y')) AS approval_year,
    SUM(disbursed_amount) AS total_disbursed
FROM loan_bangladesh
GROUP BY approval_year
ORDER BY approval_year;


3.//Lists total principal amount allocated per sector
SELECT 
   project_name,
    COUNT(*) AS num_projects,
    SUM(original_principal_amount) AS total_funding
FROM loan_bangladesh
GROUP BY project_name
ORDER BY total_funding DESC;


4.//Loans where repayment is still due or recent closing date is NULL
SELECT 
    loan_number,
    project_name,
    due_to_ibrd,
    borrowers_obligation,
    closed_date_most_recent
FROM loan_bangladesh
WHERE due_to_ibrd > 0
   OR closed_date_most_recent IS NULL;


5.//Projects that lost value due to exchange rate changes
SELECT 
    loan_number,
    project_name,
    exchange_adjustment
FROM loan_bangladesh
WHERE exchange_adjustment < 0
ORDER BY exchange_adjustment ASC;


6.//Compares average time (in days) between first and last repayment by loan type
SELECT 
    loan_type,
    AVG(DATEDIFF(
        STR_TO_DATE(last_repayment_date, '%m/%d/%Y'),
        STR_TO_DATE(first_repayment_date, '%m/%d/%Y')
    )) AS avg_repayment_duration_days
FROM loan_bangladesh
WHERE first_repayment_date IS NOT NULL AND last_repayment_date IS NOT NULL
GROUP BY loan_type;


7.//Projects where a significant portion was cancelled
SELECT 
    loan_number,
    project_name,
    original_principal_amount,
    cancelled_amount,
    ROUND((cancelled_amount / original_principal_amount) * 100, 2) AS cancelled_percentage
FROM loan_bangladesh
WHERE cancelled_amount > 0
ORDER BY cancelled_percentage DESC;


8.// Define delay between approval and disbursement
WITH disbursement_delay AS (
    SELECT 
        loan_number,
        project_name,
        STR_TO_DATE(board_approval_date, '%m/%d/%Y') AS approval_date,
        STR_TO_DATE(last_disbursement_date, '%m/%d/%Y') AS disbursement_date,
        DATEDIFF(
            STR_TO_DATE(last_disbursement_date, '%m/%d/%Y'),
            STR_TO_DATE(board_approval_date, '%m/%d/%Y')
        ) AS days_to_disburse
    FROM loan_bangladesh
    WHERE board_approval_date IS NOT NULL AND last_disbursement_date IS NOT NULL
)
-- Select projects with disbursement delay > 2 years
SELECT *
FROM disbursement_delay
WHERE days_to_disburse > 730
ORDER BY days_to_disburse DESC;


9.//Shows what % of obligations have been repaid
SELECT 
    SUM(repaid_to_ibrd) AS total_repaid,
    SUM(borrowers_obligation) AS total_obligation,
    ROUND(SUM(repaid_to_ibrd) / SUM(borrowers_obligation) * 100, 2) AS repayment_percentage
FROM loan_bangladesh
WHERE borrowers_obligation > 0;


10. //Combine loan type and loan status to create a matrix
SELECT 
    loan_type,
    loan_status,
    COUNT(*) AS count_loans,
    SUM(original_principal_amount) AS total_amount
FROM loan_bangladesh
GROUP BY loan_type, loan_status
ORDER BY total_amount DESC;


11.//Use CASE to categorize projects by size
SELECT 
    loan_number,
    project_name,
    original_principal_amount,
    CASE 
        WHEN original_principal_amount >= 500000000 THEN 'Very Large'
        WHEN original_principal_amount >= 100000000 THEN 'Large'
        WHEN original_principal_amount >= 10000000 THEN 'Medium'
        ELSE 'Small'
    END AS loan_size_category
FROM loan_bangladesh
ORDER BY original_principal_amount DESC;
