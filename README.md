# Geospatial Analysis of Obesity in the United States at County Level (2023)

**Academia de Studii Economice din București**  
Faculty of Cybernetics, Statistics and Economic Informatics  
Specialization: Applied Statistics and Data Science

**Author:** Constantin Teodor-Vasile  
**Supervisors:** Prof. univ. Prada Elena Maria, Prof. univ. Cimpoeru Smaranda  
**Year:** 2026

---

## Overview

This project applies **spatial econometrics** to investigate the geographic distribution of obesity across US counties in 2023. Rather than treating counties as independent observations, the analysis explicitly accounts for spatial dependence — the idea that neighboring counties tend to share similar health outcomes due to shared culture, infrastructure, and socioeconomic conditions.

The analysis progresses from exploratory mapping → spatial autocorrelation testing → OLS regression → spatial model comparison → robust Manski (SAC) model estimation.

---

## Data

**Sample:** 3,103 contiguous US counties (Alaska and Hawaii excluded to ensure spatial continuity). Missing values imputed with variable means.

**Sources:**
- [CDC PLACES 2023 — County Data](https://data.cdc.gov/500-Cities-Places/PLACES-County-Data-GIS-Friendly-Format-2025-releas/i46a-9kgh/about_data)
- [USDA ERS — County-Level Education Data](https://www.ers.usda.gov/data-products/county-level-data-sets/county-level-data-sets-download-data)
- [US Census Bureau — County Shapefiles (cb_2018_us_county_5m)](https://www.census.gov/geographies/mapping-files/time-series/geo/carto-boundary-file.html)

**Variables:**

| Variable | Description | Unit |
|---|---|---|
| `OBESITY` (Y) | Adult obesity prevalence | % |
| `LPA` | Lack of physical activity (leisure-time) | % |
| `CHECKUP` | Routine medical checkup in the past year | % |
| `DEPRESSION` | Diagnosed depression prevalence | % |
| `GHLTH` | Self-rated health as "fair/poor" | % |
| `SLEEP` | Short sleep duration | % |
| `HIGHCHOL` | High cholesterol prevalence | % |
| `NIHIGHSCH` | Adults without a high school diploma | % |
| `BACHELOR` | Adults with at least a bachelor's degree | % |

---

## Methods

### 1. Exploratory Spatial Data Analysis (ESDA)
Natural breaks (Jenks) choropleth maps are produced for all key variables. These reveal strong geographic clustering: obesity and physical inactivity concentrate in the Deep South and Appalachia, while higher education rates cluster in coastal urban corridors.

### 2. Spatial Autocorrelation

**Global Moran's I** tests whether obesity is randomly distributed or spatially clustered:
- Moran's I = **0.509** (z = 43.57, p = 0.001) → significant positive autocorrelation

**Bivariate Moran's I** (Obesity × LPA):
- Moran's I = **0.428** (z = 42.49, p = 0.001) → physical inactivity is a strong spatial predictor of obesity in neighboring counties

**LISA (Local Indicators of Spatial Association)** identifies local cluster types:
- **High-High hotspots:** Mississippi, Louisiana, Arkansas, West Virginia, Kentucky (Deep South + Appalachia)
- **Low-Low coldspots:** Idaho, Wyoming, Montana, New England states
- **Low-High outliers:** Isolated counties in Florida and North Carolina, suggesting locally effective health policies

### 3. Regression Modeling

Four models are estimated and compared:

| Model | Description | R² / Pseudo R² | Log-Likelihood | AIC |
|---|---|---|---|---|
| OLS | Classical linear regression | 0.631 | — | 14,764 |
| Spatial Lag (SAR) | Spatially lagged dependent variable | 0.723 | −6,284.5 | 12,587 |
| Spatial Error (SEM) | Spatially correlated error term | 0.680 | −6,412.2 | 12,844 |
| **Manski / SAC (Robust)** | Combined Lag + Error (Rho + Lambda) | **0.7765** | **−6,957.8** | **13,940** |

OLS diagnostics (Breusch-Pagan, Koenker-Bassett) confirmed heteroscedasticity and spatial dependence, justifying the use of spatial models. The **Manski (SAC)** model was estimated via **Maximum Likelihood (ML)** — enabling AIC/Log-Likelihood comparison — and achieved the best overall fit.

### 4. Manski (SAC) Model Results

```
σ²_t = β·X + ρ·W·y + λ·W·ε
```

**Spatial components:**
- **Lambda (λ) = 0.669** (p < 2.2e-16) — strong spatial error dependence; unobserved regional factors (culture, state health policy) are geographically clustered
- **Rho (ρ) = −0.074** (p = 0.239) — direct neighborhood contagion is not the primary driver once other factors are controlled

**Key coefficient estimates:**

| Variable | Coefficient | Interpretation |
|---|---|---|
| `LPA` | +0.427 | Strongest risk factor — physical inactivity drives obesity |
| `CHECKUP` | +0.299 | Higher checkup rates in high-obesity areas (reactive healthcare) |
| `DEPRESSION` | +0.087 | Mental health is positively linked to obesity prevalence |
| `BACHELOR` | −0.112 | Higher education is a significant protective factor |

### 5. Model Diagnostics

- **Pseudo R² = 0.7765** — the model explains ~78% of county-level obesity variation
- **Moran's I on residuals:** p > 0.05 — spatial autocorrelation successfully absorbed; residuals are geographically random
- **Jarque-Bera:** χ² = 18.67 (p = 8.8e-05) — residuals deviate slightly from normality (consistent with real-world health data; informational only)
- **Q-Q Plot:** Residuals follow the theoretical line centrally, with minor tail deviations

---

## Repository Structure

```
proiect_econometrie_spatiala/
│
├── proiectR.R                        # Full R script (all models + diagnostics)
├── proiect_econometrie_spatiala.docx # Project report
│
├── bd.csv                            # Merged dataset (CDC PLACES + USDA education)
│
└── usa_shapefiles/
    └── cb_2018_us_county_5m.shp      # US county shapefile (Census Bureau)
```

---

## How to Run

### Requirements

```r
install.packages(c("sf", "spdep", "spatialreg", "readr", "Matrix", "tseries"))
```

### Steps

1. Place `bd.csv` and the `usa_shapefiles/` folder at the paths specified in the script, or update `path_shp` and `path_csv` in `proiectR.R`
2. Run `proiectR.R` end-to-end — the script will:
   - Load and merge spatial + tabular data via FIPS codes
   - Build a Queen contiguity weights matrix
   - Estimate OLS, SAR, SEM, and Manski (SAC) models
   - Print a comparative model table
   - Run Moran's I, Jarque-Bera, and Pseudo R² diagnostics on the SAC model
   - Display a Q-Q plot of SAC residuals

---

## Key Findings

- Obesity in the US is **not randomly distributed** — it clusters strongly in the Deep South and Appalachia (Moran's I = 0.509)
- **Physical inactivity (LPA)** is the dominant predictor of obesity at county level (β = 0.427)
- **Higher education (BACHELOR)** is the strongest protective factor (β = −0.112)
- A large share of spatial dependence is driven by **unobserved regional factors** (Lambda = 0.669), such as food culture and state-level health infrastructure — not just direct neighbor contagion
- Public health interventions should be **regionally targeted**, addressing structural and cultural determinants alongside individual behavior

---

## References

- Michimi, A., & Wimberly, M. C. (2010). Spatial Patterns of Obesity and Associated Risk Factors in the Conterminous U.S. *American Journal of Preventive Medicine*, 39(2), e1–e12.
- Jonah, J., et al. (2024). Understanding regional disparities in obesity: a multiscale geographically weighted analysis. *BMC Public Health*, 24, 512.
- Xinyi, Y., et al. (2022). Exploring the Spatial Association between Obesity and Selected Underlying factors among Adults in the United States. *NIU Honors Capstones*.
- Slack, T., et al. (2014). The Geographic Concentration of US Adult Obesity Prevalence and Associated Social, Economic, and Environmental Factors. *Rural Sociology*, 79(3), 295–327.
- Gala, et al. (2025). The examination of the spatial and contextual disparities of determinant factors of adult obesity among communities. *Discover Public Health*, 22(1).
