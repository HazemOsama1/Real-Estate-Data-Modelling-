# 🏠 Real Estate DWH — dbt Transformation Project

A full **dimensional data warehouse** for Egyptian real estate listings, built with **dbt (data build tool)** on top of **Microsoft SQL Server**. Raw property listing data scraped from a real estate platform is transformed from a normalised OLTP schema into a clean, analytics-ready star schema.

---
## 📐 Architecture Overview

```

RealEstateDB (OLTP source)          RealEstate_DWH (target DWH)
─────────────────────────           ─────────────────────────────
realestate.listings                 dbt_transform_marts.fact_listings
realestate.locations        ──►     dbt_transform_marts.dim_location
realestate.agents                   dbt_transform_marts.dim_agent
realestate.brokers                  dbt_transform_marts.dim_property
realestate.property_categories      dbt_transform_marts.dim_listing_flags
realestate.amenities                dbt_transform_marts.dim_date
realestate.listing_amenities        dbt_transform_marts.bridge_listing_amenities
realestate.agent_languages          dbt_transform_staging.*  (views)
realestate.languages
```

The pipeline has three layers:

| Layer | Schema | Materialisation | Purpose |
|---|---|---|---|
| **Staging** | `dbt_transform_staging` | View | 1-to-1 mirror of source tables, lightly cleaned and typed |
| **Marts** | `dbt_transform_marts` | Table | Final star-schema dimensions and fact table |
| **Seeds** | `dbt_transform_marts` | Table | Static `dim_date` calendar table |

---

## 🗂️ Source Schema (RealEstateDB)
Source ERD:
<img width="772" height="793" alt="2" src="https://github.com/user-attachments/assets/8ba6f970-d956-485b-a4d5-715048978503" />


The OLTP source lives in the `realestate` schema and contains 11 tables:

| Table | Description |
|---|---|
| `listings` | Core fact — one row per property advertisement |
| `locations` | 4-level geographic hierarchy (city → town → district → subdistrict) |
| `property_categories` | Classification of listings by type, offering, and completion status |
| `agents` | Real estate agents with super-agent flag |
| `brokers` | Real estate agencies that agents belong to |
| `languages` | Reference table of spoken languages |
| `agent_languages` | M2M junction — which languages each agent speaks |
| `amenities` | Reference table of property features (pool, gym, parking, etc.) |
| `listing_amenities` | M2M junction — which amenities each listing has |
| `listing_contacts` | Normalised contacts per listing (phone / whatsapp / email) |
| `listing_images` | Image URLs per listing with display order |
| `stg_listings_raw` | Landing zone — raw CSV data before normalisation |

---

## ⭐ Target Schema (Star Schema)

Dimensional Modelling:

<img width="1062" height="807" alt="1" src="https://github.com/user-attachments/assets/be9e47a9-c53f-4c1d-ad61-6281f41566a9" />

### Fact Table

**`fact_listings`** — one row per listing, with foreign keys to all dimensions and numeric measures.

| Column | Type | Description |
|---|---|---|
| `listing_key` | varchar (surrogate) | Primary key |
| `dim_date_key` | int (YYYYMMDD) | FK → dim_date |
| `location_key` | varchar (surrogate) | FK → dim_location |
| `property_key` | varchar (surrogate) | FK → dim_property |
| `agent_key` | varchar (surrogate) | FK → dim_agent |
| `flags_key` | varchar (surrogate) | FK → dim_listing_flags |
| `price_egp` | decimal | Listing price in EGP |
| `area_value` | decimal | Property size |
| `bedrooms` | smallint | Number of bedrooms |
| `bathrooms` | smallint | Number of bathrooms |
| `images_count` | int | Number of listing images |

### Dimensions

| Dimension | Grain | Key columns |
|---|---|---|
| `dim_date` | One row per calendar day (2020–2030) | year, quarter, month, week, day_name, is_weekend |
| `dim_location` | One row per city/town/district/subdistrict combination | city, town, district, subdistrict, lat, lon |
| `dim_property` | One row per property classification combination | category, property_type, listing_type, offering_type, completion_status |
| `dim_agent` | One row per agent (joined with broker and languages) | agent_name, is_super, broker_name, languages |
| `dim_listing_flags` | One row per unique combination of 6 boolean flags | is_premium, is_verified, is_featured, is_new_construction, is_direct_from_dev, is_exclusive |

### Bridge Table

**`bridge_listing_amenities`** — resolves the many-to-many relationship between listings and amenities. Query by joining `fact_listings → bridge_listing_amenities → dim_amenity`.

---

## 🛠️ Tech Stack

- **Database:** Microsoft SQL Server 2019 (local instance)
- **Transformation:** [dbt](https://www.getdbt.com/) with [`dbt-sqlserver`](https://github.com/dbt-msft/dbt-sqlserver) adapter
- **Authentication:** Windows Authentication (no username/password required)
- **Packages:** [`dbt-labs/dbt_utils`](https://hub.getdbt.com/dbt-labs/dbt_utils/latest/) for surrogate key generation
- **Driver:** ODBC Driver 17 for SQL Server

---

## 📁 Project Structure

```
realestate_dwh/
│
├── models/
│   ├── staging/
│   │   ├── sources.yml              # Source definitions pointing to RealEstateDB
│   │   ├── stg_listings.sql
│   │   ├── stg_locations.sql
│   │   ├── stg_agents.sql
│   │   ├── stg_brokers.sql
│   │   ├── stg_property_categories.sql
│   │   ├── stg_amenities.sql
│   │   └── stg_agent_languages.sql
│   │
│   └── marts/
│       ├── schema.yml               # Tests and documentation
│       ├── dim_date.sql
│       ├── dim_location.sql
│       ├── dim_property.sql
│       ├── dim_agent.sql
│       ├── dim_listing_flags.sql
│       ├── fact_listings.sql
│       └── bridge_listing_amenities.sql
│
├── seeds/
│   └── dim_date.csv                 # Static calendar table (2020–2030)
│
├── macros/                          # Custom dbt macros (if any)
├── tests/                           # Custom singular tests (if any)
├── packages.yml                     # dbt package dependencies
├── dbt_project.yml                  # Project configuration
└── README.md
```

---

## ⚙️ Setup & Installation

### Prerequisites

- SQL Server 2019 or later (local or remote)
- Python 3.8+
- ODBC Driver 17 (or 18) for SQL Server
- Both `RealEstateDB` and `RealEstate_DWH` databases created on the same instance

### 1. Clone the repository

```bash
git clone https://github.com/HazemOsama1/realestate-dwh.git
cd realestate-dwh
```

### 2. Install Python dependencies

```bash
pip install dbt-sqlserver dbt-utils
```

### 3. Install dbt packages

```bash
dbt deps
```

### 4. Configure your profile

Your `profiles.yml` should be located at `~/.dbt/profiles.yml` (not inside the project folder):

```yaml
realestate_dwh:
  outputs:
    dev:
      type: sqlserver
      driver: 'ODBC Driver 17 for SQL Server'
      server: '.'
      port: 1433
      database: 'RealEstate_DWH'
      schema: 'dbt_transform'
      windows_login: True
      encrypt: false
      threads: 1
  target: dev
```

> **Note:** Change `'ODBC Driver 17 for SQL Server'` to `18` if you have version 18 installed.

### 5. Test the connection

```bash
dbt debug
```

All checks should pass before proceeding.

---

## 🚀 Running the Pipeline

Run the steps in this order:

```bash
# 1. Load the static calendar table into the DWH
dbt seed

# 2. Build all staging views (reads from RealEstateDB)
dbt run --select staging.*

# 3. Build all dimension and fact tables (writes to RealEstate_DWH)
dbt run --select marts.*

# 4. Run data quality tests
dbt test

# 5. (Optional) Generate and browse documentation
dbt docs generate
dbt docs serve
```

To run everything in one command:

```bash
dbt build
```

---

## 🧪 Data Tests

Tests are defined in `models/marts/schema.yml` and cover:

| Test | Applied to |
|---|---|
| `unique` + `not_null` | All surrogate keys in every dimension and fact table |
| `not_null` | All foreign keys in `fact_listings` |
| `accepted_range` (price ≥ 0) | `fact_listings.price_egp` |
| `relationships` | FK integrity between fact and each dimension |

Run tests with:

```bash
dbt test
```

---

## 🔄 Incremental Loading

After the initial full load, `fact_listings` can be switched to incremental mode to append only new rows on each run. Add the following to `fact_listings.sql`:

```sql
{{ config(materialized='incremental', unique_key='listing_key') }}

...

{% if is_incremental() %}
  where l.scraped_at > (select max(scraped_at) from {{ this }})
{% endif %}
```

The `scraped_at` timestamp in the source tracks when each listing was collected by the scraper, making it a reliable watermark for incremental ETL.

---

## 📊 Example Queries

**Average price per city:**
```sql
select
    l.city,
    count(*)              as listings,
    avg(f.price_egp)      as avg_price_egp
from dbt_transform_marts.fact_listings f
join dbt_transform_marts.dim_location  l on l.location_key = f.location_key
group by l.city
order by avg_price_egp desc;
```

**Listings with a pool by property type:**
```sql
select
    p.property_type,
    count(distinct f.listing_key) as listings_with_pool
from dbt_transform_marts.fact_listings          f
join dbt_transform_marts.bridge_listing_amenities b on b.listing_key = f.listing_key
join dbt_transform_marts.dim_property            p on p.property_key = f.property_key
where b.amenity_name = 'Swimming Pool'
group by p.property_type;
```

**Monthly listing volume:**
```sql
select
    d.year,
    d.month_name,
    count(*) as new_listings
from dbt_transform_marts.fact_listings f
join dbt_transform_marts.dim_date      d on d.date_key = f.dim_date_key
group by d.year, d.month, d.month_name
order by d.year, d.month;
```

---
Here are some insights:

<img width="1280" height="711" alt="8" src="https://github.com/user-attachments/assets/6a21fc58-95d9-4f0c-93b2-d55cc1b01fa3" />

<img width="1271" height="716" alt="7" src="https://github.com/user-attachments/assets/6cc6c787-64e3-429f-b176-e5ed42745c4a" />

<img width="1277" height="720" alt="9" src="https://github.com/user-attachments/assets/53b91233-8672-4d61-b176-f720238e28cf" />


