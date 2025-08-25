# 📊 IDX Financial Workflow

This repository contains **Data Analyst (DA)** and **Data Engineering (DE)** workflows based on the [Financial Statement Data IDX 2020–2023](https://www.kaggle.com/datasets/kalkulasi/financial-statement-data-idx-2020-2023/data) dataset from Kaggle.  
The dataset includes annual financial statements of **604 public companies** listed on the Indonesia Stock Exchange (IDX).

---

## 🔹 Analyzing Requirements

### 📂 Data Source
- Dataset from Kaggle: *Financial Statement Data IDX 2020–2023*.  
- Covers annual reports of 604 public companies listed on IDX.  
- Primary source: official financial reports published via IDX.  

### 📊 Data Quality
- **Completeness**: Not all companies are included; some did not publish or have irrelevant reports.  
- **Consistency**: Standardized account names (Balance Sheet, Income Statement, Cash Flow), but unit validation (million/billion Rupiah) is required.  
- **Missing Values**: Some variables or periods are empty, requiring imputation/cleaning.  
- **Accuracy**: Dataset follows official reports, but verification is recommended for financial decisions.  

### 🔗 Integration
- IDX stock price data → link financial performance with market movement.  
- Industry sector data → comparison across industries.  
- External macroeconomic data (inflation, interest rate, exchange rate) → assess impact of economy.  
- CSV format → compatible with Python, R, SQL, BI tools (Tableau, Power BI).  

### 🗂️ Scope
- **Period**: 2020–2023.  
- **Coverage**: 604 public companies.  
- **Statements**:  
  - Balance Sheet (BS): assets, liabilities, equity.  
  - Income Statement (IS): revenue, expenses, profit/loss.  
  - Cash Flow (CF): operating, investing, financing cash flow.  
- **Possible Analysis**:  
  - Growth trends.  
  - Financial ratios (ROA, ROE, DER, EBITDA margin, etc.).  
  - Benchmarking across companies/sectors.  
  - Classification & clustering of companies based on performance.  

### 📖 Documentation
- Dataset includes descriptions of accounts (BS, IS, CF) in English & Bahasa Indonesia.  
- Appendix table explains each account → easier mapping & analysis.  
- Additional docs:  
  - Data dictionary (column definitions & units).  
  - Data cleaning & transformation guide.  
  - Limitations (missing companies, inconsistencies across years).  

---

## ⚙️ Project Workflow

### 🛠 Data Engineering (DE)
- Data extraction from Kaggle.  
- Cleaning & transformation (handling missing values, unit standardization).  
- Building pipelines for integration with external datasets.  
- Preparing structured data for analytics/BI tools.  

### 📈 Data Analysis (DA)
- Exploratory Data Analysis (EDA).  
- Trend & ratio analysis.  
- Benchmarking between sectors.  
- Visualizations & dashboards.  
- Generating insights for business/finance decision-making.  

---

## 🚀 Tech Stack
- **Database**: SQL Server  
- **Languages**: SQL (T-SQL)
- **Tools**: Tableau
- **Version Control**: Git & GitHub  
