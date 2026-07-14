# Customer Churn & Retention Analysis

## Business Problem
Telecom companies lose significant recurring revenue to customer churn. This 
project identifies who is churning, why, and how much revenue is at risk — 
then segments customers by risk level to enable targeted retention action.

## Dataset
10,000+ telecom customer records including tenure, contract type, billing, 
service subscriptions, and churn status.

## What I Did
- Modeled and queried the dataset in MySQL (12 queries)
- Calculated overall and segmented churn rates by Contract, Internet Service, 
  Payment Method, Senior Citizen status, and Gender
- Built RFM-style customer segments (Champions, Loyal, High-Value New, 
  Low-Value New, Mid-Tier) and measured churn rate per segment
- Designed a 7-factor weighted risk scoring model (contract type, tenure, 
  payment method, senior status, internet type, security/support add-ons) 
  to classify customers into High/Medium/Low risk
- Quantified monthly and total revenue at risk from churned customers
- Built a 3-page Power BI dashboard: Overview & KPIs, Customer Segments, 
  and Risk & Revenue Analysis

## Key Insights
- Overall churn rate is 26.8% (268 of 1,000 customers), representing ~₹19.60K 
  in lost monthly recurring revenue
- Month-to-month contracts show a 44% churn rate — 4x higher than annual 
  contracts (11%) and 22x higher than two-year contracts (2%), making 
  contract type the single strongest churn predictor
- High-Value New customers churn at 73%, the highest of any RFM segment — 
  higher even than Low-Value New customers, suggesting an onboarding or 
  early-tenure retention gap rather than a pricing problem
- Electronic check payment users and Fiber optic subscribers show the 
  highest churn rates within their respective categories (44% and 41%)
- The 7-factor risk scoring model successfully separates risk tiers: High 
  Risk customers (30.5% of the base) show a markedly higher churn rate than 
  Medium or Low Risk segments, validating the model's predictive value

## Dashboard
<img width="595" height="335" alt="image" src="https://github.com/user-attachments/assets/a228a0e7-3f70-4836-b816-b868eb1e8814" />
<img width="595" height="335" alt="image" src="https://github.com/user-attachments/assets/fbd16215-fe38-423a-8b67-58bffbfe8a45" />
<img width="594" height="335" alt="image" src="https://github.com/user-attachments/assets/69bf032c-59fb-4890-9b13-9f95de589486" />

## Tools
MySQL · Power BI (DAX measures, RFM segmentation, risk scoring)

## Files
- `Sql_Queries.sql` — table schema + all 12 analysis queries
- `Customer_Churn_project_dashboard.pbix` — full 3-page dashboard
