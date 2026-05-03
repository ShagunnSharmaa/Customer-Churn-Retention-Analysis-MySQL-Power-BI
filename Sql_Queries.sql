USE churn_db;

CREATE TABLE customers (
    customerID        VARCHAR(20)    PRIMARY KEY,
    gender            VARCHAR(10),
    SeniorCitizen     TINYINT,
    Partner           VARCHAR(5),
    Dependents        VARCHAR(5),
    tenure            INT,
    PhoneService      VARCHAR(5),
    MultipleLines     VARCHAR(30),
    InternetService   VARCHAR(20),
    OnlineSecurity    VARCHAR(20),
    OnlineBackup      VARCHAR(20),
    DeviceProtection  VARCHAR(20),
    TechSupport       VARCHAR(20),
    StreamingTV       VARCHAR(20),
    StreamingMovies   VARCHAR(20),
    Contract          VARCHAR(20),
    PaperlessBilling  VARCHAR(5),
    PaymentMethod     VARCHAR(35),
    MonthlyCharges    DECIMAL(8,2),
    TotalCharges      DECIMAL(10,2),
    Churn             VARCHAR(5)
);

SELECT COUNT(*) FROM customers;

-- Query 1 — Overall Churn Rate
SELECT
    COUNT(*) AS total_customers,
    SUM(Churn = 'Yes') AS churned,
    SUM(Churn = 'No') AS retained,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers;

-- Query 2 — Churn by Contract Type
SELECT
    Contract,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;

-- Query 3 — Churn by Internet Service
SELECT
    InternetService,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;

-- Query 4 — Churn by Payment Method
SELECT
    PaymentMethod,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;

-- Query 5 — Churn by Senior Citizen
SELECT
    CASE SeniorCitizen WHEN 1 THEN 'Senior' ELSE 'Non-Senior' END AS segment,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY SeniorCitizen;

-- Query 6 — Churn by Gender
SELECT
    gender,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY gender;

-- Query 7 — Avg Charges: Churned vs Retained
SELECT
    Churn,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2) AS avg_total_charges,
    ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM customers
GROUP BY Churn;

-- Query 8 — Tenure Buckets
SELECT
    CASE
        WHEN tenure BETWEEN 0  AND 12 THEN '0-12 months (New)'
        WHEN tenure BETWEEN 13 AND 24 THEN '13-24 months'
        WHEN tenure BETWEEN 25 AND 48 THEN '25-48 months'
        ELSE '49+ months (Loyal)'
    END AS tenure_bucket,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY tenure_bucket
ORDER BY MIN(tenure);

-- Query 9 — RFM Segments + Churn Rate
SELECT
    CASE
        WHEN tenure >= 48 AND MonthlyCharges >= 70 THEN 'Champions'
        WHEN tenure >= 24 AND MonthlyCharges >= 50 THEN 'Loyal Customers'
        WHEN tenure < 12  AND MonthlyCharges >= 70 THEN 'High-Value New'
        WHEN tenure < 12  AND MonthlyCharges < 40  THEN 'Low-Value New'
        ELSE 'Mid-Tier'
    END AS rfm_segment,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS churn_rate_pct
FROM customers
GROUP BY rfm_segment
ORDER BY churn_rate_pct DESC;

-- Query 10 — Churn Risk Score Summary
SELECT
    CASE
        WHEN (
            IF(Contract = 'Month-to-month', 3, 0) +
            IF(tenure < 12, 2, 0) +
            IF(PaymentMethod = 'Electronic check', 2, 0) +
            IF(SeniorCitizen = 1, 1, 0) +
            IF(InternetService = 'Fiber optic', 1, 0) +
            IF(OnlineSecurity = 'No', 1, 0) +
            IF(TechSupport = 'No', 1, 0)
        ) >= 7 THEN 'HIGH RISK'
        WHEN (
            IF(Contract = 'Month-to-month', 3, 0) +
            IF(tenure < 12, 2, 0) +
            IF(PaymentMethod = 'Electronic check', 2, 0) +
            IF(SeniorCitizen = 1, 1, 0) +
            IF(InternetService = 'Fiber optic', 1, 0) +
            IF(OnlineSecurity = 'No', 1, 0) +
            IF(TechSupport = 'No', 1, 0)
        ) >= 4 THEN 'MEDIUM RISK'
        ELSE 'LOW RISK'
    END AS risk_label,
    COUNT(*) AS total,
    SUM(Churn = 'Yes') AS actually_churned,
    ROUND(100 * SUM(Churn = 'Yes') / COUNT(*), 2) AS actual_churn_pct
FROM customers
GROUP BY risk_label
ORDER BY FIELD(risk_label, 'HIGH RISK', 'MEDIUM RISK', 'LOW RISK');
-- Query 11 — Revenue at Risk
SELECT
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END), 2) AS monthly_revenue_lost,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN TotalCharges ELSE 0 END), 2) AS total_revenue_lost,
    ROUND(SUM(CASE WHEN Churn = 'No' THEN MonthlyCharges ELSE 0 END), 2) AS monthly_revenue_retained
FROM customers;

-- Query 12 — Top 50 High Risk Active Customers
SELECT
    customerID, tenure, Contract, MonthlyCharges, InternetService, PaymentMethod,
    (
        IF(Contract = 'Month-to-month', 3, 0) +
        IF(tenure < 12, 2, 0) +
        IF(PaymentMethod = 'Electronic check', 2, 0) +
        IF(SeniorCitizen = 1, 1, 0) +
        IF(InternetService = 'Fiber optic', 1, 0) +
        IF(OnlineSecurity = 'No', 1, 0) +
        IF(TechSupport = 'No', 1, 0)
    ) AS risk_score
FROM customers
ORDER BY risk_score DESC, MonthlyCharges DESC;