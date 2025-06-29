# Worldwide Travel Cities

This project aims to identify and recommend top travel destinations around the world based on various experiential, climatic, and affordability factors using data analytics and SQL.

---

## Objective

To analyse global travel destinations and recommend top countries for **nature**, **cultural**, and **leisure** experiences. The recommendation is based on:
- Ratings across 9 travel categories
- Temperature variation
- Affordability
- Descriptive and geographic data

The analysis provides insights using SQL transformations and supports decision-making through visual presentations in Power BI.

---

## Dataset Overview

**Source**: [Kaggle – Holiday Destinations Dataset](https://www.kaggle.com/)  
The dataset contains structured information about global holiday destinations enriched with:
- **Geographic Info**: Country, City, Latitude, Longitude  
- **Climate Data**: Avg, Min, and Max temperatures for each month  
- **Experiential Ratings** *(0–5 scale)*:
  - Wellness, Nature, Adventure
  - Culture, Cuisine
  - Urban, Nightlife
  - Beaches, Seclusion
-  **Affordability Ratings**:
  - Budget (most affordable)
  - Mid-range (moderate)
  - Luxury (most expensive)
-  **Free-text Descriptions** summarising key features of each location

---

##  SQL Analysis Summary

### Data Preparation
- Parsed monthly temperature JSON into a normalised table (`temperature_info`)
- Calculated average, min, and max monthly temperatures per destination

###  Data Integration
- Joined the temperature data with the main destination dataset to create a `detailed_view` table

### Categorisation Logic
Added classification flags using SQL logic:
- **Nature Destination**: Yes if `Wellness`, `Nature`, and `Adventure` > 3
- **Cultural Destination**: Yes if `Culture` and `Cuisine` > 3
- **Leisure Destination**: Yes if `Urban` and `Nightlife` > 3

### Ranking and Aggregation
- Created top 10 country lists for each category (`top_nature_country`, `top_cultural_country`, `top_leisure_country`)
- Calculated average category scores per country and assigned ranks

###  Climate Stability Analysis
- Appended monthly temperature data to each top-country table
- Calculated **standard deviation** of temperatures per country to assess climate consistency

###  Affordability Insights
- For each top destination, identified the most frequent affordability tier (Budget, Mid-range, Luxury)

###  Highlight Queries
- Total travel experience score per city
- City-level breakdowns for selected countries (India, Italy, Hong Kong, etc.)
- Comparison of average climate variation among top-ranked countries

---

##  Visual Analysis

Power BI dashboards include:
- Average experience ratings per category
- Top-ranked countries for each destination type
- Climate consistency and variation
- Affordability breakdowns
- Strategic destination recommendations

>  Final presentation includes PowerPoint screenshots and summarised visuals.

---

##  Repository Structure

Images/ # Visual snapshots used in presentation
BI_report.pbix # Power BI desktop file
PowerPoint screenshot.pptx # Slides for final recommendation
SQL_scripts.sql # Complete SQL transformations and queries
README.md # Project documentation

yaml
Copy
Edit

---

##  Key Takeaways

- **Botswana**, **India**, and **Italy** emerged as strong nature destinations.
- **Hong Kong** ranked top 3 for both culture and leisure, but is a luxury destination.
- Climate variation was measured using standard deviation — lower SD means more consistent weather.
- Affordability plays a critical role in final recommendations for each traveler profile.

---

##  Next Steps

- Automate monthly updates if live data becomes available
- Extend to continent-specific analysis
- Incorporate more environmental or event-based factors (festivals, seasons, etc.)

---

## Author

**Shumpei Komatsu**  
Master of Data Analytics | Passionate about travel, insights, and data-driven decision-making  
GitHub: [skomatsu1998](https://github.com/skomatsu1998)
