# US Real Estate Market Analysis — End-to-End Data Pipeline

An end-to-end data analytics project that ingests, models, and visualizes U.S. housing and real estate market data — from raw API/CSV sources to a governed relational database to an interactive Power BI dashboard.

## Project Overview

This project builds a complete data pipeline for analyzing residential real estate trends across U.S. zip codes: current listing activity alongside long-run home value trends. The goal is to answer questions such as:

- How do listing prices and inventory vary by location and property type?
- How has the Zillow Home Value Index (ZHVI) trended over time by zip code?
- Where do current listing prices diverge from long-run home value trends?

The pipeline covers the full lifecycle: **Extract → Clean → Model → Load → Visualize**.

## Tech Stack

| Layer | Tool |
|---|---|
| Data extraction & cleaning | Python (Pandas) |
| Database / data warehouse | PostgreSQL |
| Data modeling | Star schema (fact constellation) |
| Visualization / BI | Power BI |

## Data Sources

| Source | Description | Granularity |
|---|---|---|
| **Realty in US API** (RapidAPI, realtor.com listings) | Active listing data — prices, property type, location | Pulled by postal code |
| **Zillow Research — ZHVI** (Zillow Home Value Index) | Home value trend index | Monthly time series, by zip code |

## Data Model

The warehouse uses a **star schema / fact constellation** — two fact tables sharing a common set of dimensions, joined on zip code:

```
                dim_date
                   |
dim_property_type--+--dim_location
                   |
        +----------+----------+
        |                     |
 fact_listings         fact_home_value_trend
 (Realty in US)             (Zillow ZHVI)
```

- **dim_location** — zip code, city, state, region
- **dim_date** — calendar attributes for time-series analysis
- **dim_property_type** — property category/type
- **fact_listings** — listing-level facts from Realty in US (price, status, etc.)
- **fact_home_value_trend** — monthly ZHVI values by zip code

## Project Structure

```
us-real-estate-analysis/
├── data/
│   ├── raw/                # Unprocessed API pulls / downloaded CSVs
│   └── processed/          # Cleaned data ready for loading
├── notebooks/               # Exploration and cleaning notebooks
├── sql/
│   ├── schema/              # DDL for dimension and fact tables
│   └── load/                # Load / transform scripts
├── powerbi/                 # .pbix dashboard file(s)
├── src/                     # Reusable Python modules (extraction, cleaning, loading)
└── README.md
```

> Adjust folder names above to match your actual repo layout if it differs.

## Setup & Installation

1. **Clone the repo**
   ```bash
   git clone https://github.com/pandebipinX/us-real-estate-analysis.git
   cd us-real-estate-analysis
   ```

2. **Install dependencies**
   ```bash
   pip install pandas psycopg2-binary requests python-dotenv
   ```

3. **Set up PostgreSQL**
   - Create a local database
   - Run the DDL scripts in `sql/schema/` to create the star schema

4. **Configure API access**
   - Add your RapidAPI key (Realty in US) to a `.env` file
   - Zillow ZHVI data is downloaded directly from Zillow Research (no key required)

5. **Run the pipeline**
   - Execute the extraction/cleaning notebooks or scripts
   - Load cleaned data into PostgreSQL via the scripts in `sql/load/`

6. **Open the dashboard**
   - Open the `.pbix` file in Power BI Desktop and point it at the PostgreSQL database

## Pipeline Stages

1. **Extract** — Pull active listings from the Realty in US API by postal code; download Zillow ZHVI monthly time series by zip code.
2. **Clean** — Standardize location fields, handle missing/duplicate records, align date formats (Pandas).
3. **Model** — Design and build the star schema (dimension + fact tables).
4. **Load** — Load cleaned, modeled data into PostgreSQL.
5. **Visualize** — Three interactive Power BI dashboards connecting listing activity to long-run value trends.

## Current Status

- [x] Data extracted from both sources
- [x] Data cleaned (Pandas)
- [x] Star schema designed
- [x] Data loaded into PostgreSQL
- [x] Power BI dashboards (all three complete)

## Key Findings

### Market Overview
- 1,045 total listings and 108 new listings tracked, but volume is down 15% and average listing price is down 22% year-over-year (Aug 2025) — the market is cooling on both fronts, not just price.
- The 2000–2025 home value trend shows the full cycle: values rose from ~$150K to a mid-2000s peak near $250K, corrected to ~$180K by 2011–2012 after the 2008 crash, then climbed steadily to ~$340K by 2025. The post-2012 run-up is steeper and longer than the pre-2008 one.
- The dataset is heavily condo-weighted — condos make up 79.6% of listings, vs. 8.0% single-family, 6.3% multi-family, 2.4% land, 1.9% townhomes, and 1.7% co-ops. Any state or price comparison should account for this mix, since states with more condo inventory will skew differently than a single-family-heavy market would.
- The 2026 monthly listings trend drops sharply after month 8–9. Given today's date, that's almost certainly missing/incomplete data for the rest of 2026 rather than a real drop in listings — worth confirming before quoting this as a market signal.

### Property & Pricing
- Average listing price ($1.49M) over average property size (~1,774 sqft) implies ~$840/sqft, notably above the $761/sqft blended figure on the location dashboard — a sign that a small number of high-priced, smaller-footprint listings are pulling the average up.
- Price distribution is right-skewed: the lowest bin (~$499K) has roughly double the count of the top bins ($850K–$1.65M+). The mean ($1.49M) is likely well above the median — worth adding the median as a second reference point.
- The size-vs-price scatter shows a cluster of outliers around 5,000 sqft priced at $15–20M, well off the general size/price trend. These look like luxury outliers (or possible data errors) and are likely what's dragging the average price up — worth flagging separately from the "typical" market.
- 85% of listings are Active vs. 8.6% Pending and 6.2% Contingent — supply is sitting available rather than moving through the pipeline, consistent with the YoY volume decline.

### Market & Location
- NY leads on both average price ($3.01M) and price/sqft ($1,632) by a wide margin — a clear outlier relative to the other five states shown.
- CA and TX/WA diverge in an interesting way: CA has the 2nd-highest average price ($1.97M) but only the 4th-highest price/sqft ($600), behind WA ($904) and TX ($741). This suggests CA's high sticker price here is driven more by larger property size than by a higher per-square-foot premium.
- **Data quality flag:** the "Lowest Price State" KPI names CA at $739.77K, but the bar chart shows CO — not CA — as the lowest at $740K (CA is actually 2nd-highest at $1.97M). These two numbers can't both be right; the KPI card is likely pulling the wrong state field and should be fixed before this dashboard goes out.
- Only six states appear (NY, CA, TX, WA, IL, CO) — frame this as a subset, not a national ranking.

## Author

**Bipin Pandey**
Economics & Geography student, Tribhuvan University
📧 pandebipin321@gmail.com | 🔗 [LinkedIn](https://linkedin.com/in/bipin-pandey-860289287) | 💻 [GitHub](https://github.com/pandebipinX)
