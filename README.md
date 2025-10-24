# 🏙️ Housing Affordability SQL Project

## 📘 Project Overview
This project explores **housing affordability and rent burden** using structured SQL analysis.  
I designed and populated a small SQLite database to study how monthly rent compares to household income across multiple cities and neighborhoods in the United States.

The project demonstrates beginner-level SQL skills, data modeling, and real-world data interpretation — all created in **SQLite** and managed through **VS Code**.

---

## 🎯 Objectives
- Understand how rent and income vary by city and neighborhood  
- Calculate **rent burden ratios** (rent as a percentage of income)  
- Identify areas considered **“cost-burdened”** (spending ≥ 30 % of income on rent)  
- Practice beginner-friendly SQL concepts such as:
  - `CREATE TABLE`, `INSERT`, `JOIN`
  - Aggregations (`GROUP BY`, `AVG`, `ROUND`)
  - Conditional logic (`CASE WHEN`)
  - Basic window functions (`ROW_NUMBER`, comparisons across months)

---

## 🗂️ Database Schema

**Tables:**
1. **cities**
   - `city_id` INTEGER PRIMARY KEY  
   - `city_name` TEXT  
   - `state` TEXT  
   - `region` TEXT  

2. **neighborhoods**
   - `nbh_id` INTEGER PRIMARY KEY  
   - `city_id` INTEGER (links to `cities.city_id`)  
   - `nbh_name` TEXT  

3. **rent_stats**
   - `stat_id` INTEGER PRIMARY KEY  
   - `nbh_id` INTEGER (links to `neighborhoods.nbh_id`)  
   - `year_month` TEXT ('YYYY-MM')  
   - `median_rent` REAL  
   - `median_income` REAL  

---

## 💾 Sample Data
Each city contains several neighborhoods, and each neighborhood has rent and income data for two months (June 2025 & July 2025).  
Example rows:

| City | Neighborhood | Year-Month | Rent ($) | Income ($) |
|------|---------------|------------|-----------|------------|
| Norfolk | Ghent | 2025-06 | 1450 | 52000 |
| Boston | Dorchester | 2025-07 | 2325 | 78000 |

---

## 🔍 Example Analyses

### 1️⃣ Rent Burden by Neighborhood
```sql
SELECT
  c.city_name,
  n.nbh_name,
  r.year_month,
  r.median_rent,
  r.median_income,
  ROUND(r.median_rent / (r.median_income/12.0), 3) AS rent_burden_ratio
FROM rent_stats r
JOIN neighborhoods n ON r.nbh_id = n.nbh_id
JOIN cities c ON n.city_id = c.city_id
ORDER BY rent_burden_ratio DESC;

#2️⃣ Flag Cost-Burdened Neighborhoods 
SELECT
  c.city_name,
  n.nbh_name,
  r.year_month,
  ROUND(r.median_rent / (r.median_income/12.0), 3) AS rent_burden_ratio,
  CASE WHEN r.median_rent >= (r.median_income/12.0)*0.30
       THEN 'Cost-Burdened' ELSE 'OK' END AS status
FROM rent_stats r
JOIN neighborhoods n ON r.nbh_id = n.nbh_id
JOIN cities c ON n.city_id = c.city_id
ORDER BY status DESC;

###3️⃣ Average Rent Burden by City
SELECT
  c.city_name,
  ROUND(AVG(r.median_rent / (r.median_income/12.0)), 3) AS avg_rent_burden
FROM rent_stats r
JOIN neighborhoods n ON r.nbh_id = n.nbh_id
JOIN cities c ON n.city_id = c.city_id
GROUP BY c.city_name
ORDER BY avg_rent_burden DESC;


##4️⃣ Month-to-Month Rent Change
WITH ranked AS (
  SELECT
    r.*,
    ROW_NUMBER() OVER (PARTITION BY nbh_id ORDER BY year_month) AS rn
  FROM rent_stats r
)
SELECT
  c.city_name,
  n.nbh_name,
  cur.year_month,
  cur.median_rent AS rent_now,
  prev.median_rent AS rent_prev,
  ROUND((cur.median_rent - prev.median_rent), 2) AS change
FROM ranked cur
JOIN ranked prev ON cur.nbh_id = prev.nbh_id AND cur.rn = prev.rn + 1
JOIN neighborhoods n ON cur.nbh_id = n.nbh_id
JOIN cities c ON n.city_id = c.city_id
ORDER BY change DESC;
