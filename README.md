# 🗺️ Geospatial Analysis of Obesity in the United States at County Level (2023)

🏛️ **Academia de Studii Economice din București**  
📚 Faculty of Cybernetics, Statistics and Economic Informatics  
📊 Specialization: Applied Statistics and Data Science

**👨‍🎓 Author:** Constantin Teodor-Vasile  
**👨‍🏫 Supervisors:** Prof. univ. Prada Elena Maria, Prof. univ. Cimpoeru Smaranda  
**📅 Year:** 2026

---

## 🌟 Overview

This project applies **Spatial Econometrics** to investigate the geographic distribution of obesity across US counties in 2023.

Rather than treating counties as independent observations, the analysis explicitly accounts for **spatial dependence** — the idea that neighboring counties tend to share similar health outcomes due to common socioeconomic, cultural, and infrastructural characteristics.

The analytical workflow progresses from:

📍 Exploratory Mapping → 📊 Spatial Autocorrelation → 📈 OLS Regression → 🌐 Spatial Models → 🏆 Manski (SAC) Model

---

## 📂 Data

### 📊 Sample

- 🇺🇸 3,103 contiguous US counties
- ❌ Alaska and Hawaii excluded to ensure spatial continuity
- 🔄 Missing values imputed using variable means

### 📚 Sources

- 🏥 CDC PLACES 2023 — County Health Data
- 🌾 USDA ERS — County-Level Education Data
- 🗺️ US Census Bureau — County Shapefiles

### 📋 Variables

| Variable | Description | Unit |
|-----------|-------------|------|
| `OBESITY` | Adult obesity prevalence | % |
| `LPA` | Lack of physical activity | % |
| `CHECKUP` | Routine medical checkup | % |
| `DEPRESSION` | Diagnosed depression prevalence | % |
| `GHLTH` | Fair/Poor self-rated health | % |
| `SLEEP` | Short sleep duration | % |
| `HIGHCHOL` | High cholesterol prevalence | % |
| `NIHIGHSCH` | Adults without high school diploma | % |
| `BACHELOR` | Adults with bachelor's degree or higher | % |

---

# 🔬 Methods

## 1️⃣ Exploratory Spatial Data Analysis (ESDA)

📍 Natural Breaks (Jenks) choropleth maps were produced for all variables.

### Key Patterns

- 🔴 Obesity and physical inactivity cluster in the Deep South and Appalachia
- 🔵 Higher education levels concentrate in coastal metropolitan regions
- 🟢 Strong regional patterns suggest spatial dependence

---

## 2️⃣ Spatial Autocorrelation

### 🌐 Global Moran's I

Measures whether obesity is randomly distributed or spatially clustered.

| Statistic | Value |
|------------|---------|
| Moran's I | **0.509** |
| z-score | **43.57** |
| p-value | **0.001** |

✅ Strong positive spatial autocorrelation detected.

### 🔗 Bivariate Moran's I (Obesity × Physical Inactivity)

| Statistic | Value |
|------------|---------|
| Moran's I | **0.428** |
| z-score | **42.49** |
| p-value | **0.001** |

✅ Physical inactivity is strongly associated with obesity across neighboring counties.

### 📍 LISA Cluster Analysis

#### 🔥 High-High Hotspots

- Mississippi
- Louisiana
- Arkansas
- West Virginia
- Kentucky

#### ❄️ Low-Low Coldspots

- Idaho
- Wyoming
- Montana
- New England States

#### 🎯 Low-High Spatial Outliers

- Selected counties in Florida
- Selected counties in North Carolina

These may indicate locally successful health interventions.

---

## 3️⃣ Regression Modeling

Four competing models were estimated and compared.

| Model | Description | R² / Pseudo R² | Log-Likelihood | AIC |
|---------|-------------|-------------|-------------|-------------|
| 📈 OLS | Classical Linear Regression | 0.631 | — | 14,764 |
| 🌐 SAR | Spatial Lag Model | 0.723 | −6,284.5 | 12,587 |
| 🔄 SEM | Spatial Error Model | 0.680 | −6,412.2 | 12,844 |
| 🏆 SAC (Manski) | Spatial Lag + Error | **0.7765** | **−6,957.8** | **13,940** |

### 🔍 Diagnostics

OLS diagnostics revealed:

- ⚠️ Heteroscedasticity
- ⚠️ Spatial dependence

These findings justified the transition toward spatial econometric models.

---

## 4️⃣ Manski (SAC) Model Results

### 📐 Model Specification

```math
σ²_t = βX + ρWy + λWε
```

### 🌐 Spatial Components

| Parameter | Estimate | Interpretation |
|------------|------------|------------|
| λ (Lambda) | **0.669** | Strong spatial error dependence |
| ρ (Rho) | **−0.074** | Weak direct neighborhood contagion |

### 📊 Main Effects

| Variable | Coefficient | Interpretation |
|------------|------------|------------|
| 🏃 `LPA` | +0.427 | Strongest obesity risk factor |
| 🏥 `CHECKUP` | +0.299 | Higher healthcare utilization in high-obesity areas |
| 🧠 `DEPRESSION` | +0.087 | Positive association with obesity |
| 🎓 `BACHELOR` | −0.112 | Strong protective factor |

---

## 5️⃣ Model Diagnostics

### ✅ Goodness of Fit

| Metric | Value |
|----------|---------|
| Pseudo R² | **0.7765** |
| Explained Variation | **77.65%** |

### 🧪 Residual Diagnostics

- ✅ Moran's I on residuals: p > 0.05
- ✅ Spatial dependence successfully removed
- ⚠️ Jarque-Bera = 18.67 (p = 8.8e-05)
- 📈 Q-Q plot indicates minor tail deviations

---

# 📁 Repository Structure

```text
proiect_econometrie_spatiala/
│
├── 📜 proiectR.R
├── 📄 proiect_econometrie_spatiala.docx
│
├── 📊 bd.csv
│
└── 🗺️ usa_shapefiles/
    └── cb_2018_us_county_5m.shp
```

---

# 🚀 How to Run

## 📦 Requirements

```r
install.packages(c(
  "sf",
  "spdep",
  "spatialreg",
  "readr",
  "Matrix",
  "tseries"
))
```

## ▶️ Steps

1. 📂 Place `bd.csv` and `usa_shapefiles/` in the specified directories
2. ▶️ Run `proiectR.R`
3. 🔄 The script will:

   - 📥 Load and merge datasets
   - 🗺️ Build Queen contiguity weights
   - 📈 Estimate OLS model
   - 🌐 Estimate SAR model
   - 🔄 Estimate SEM model
   - 🏆 Estimate SAC (Manski) model
   - 📊 Generate model comparison tables
   - 🧪 Run spatial diagnostics
   - 📈 Display residual Q-Q plots

---

# 🔑 Key Findings

### 🌐 Spatial Clustering Exists

Obesity is **not randomly distributed** across the United States.

📊 Moran's I = **0.509**

### 🏃 Physical Inactivity Dominates

`LPA` is the strongest predictor of obesity.

📈 β = **0.427**

### 🎓 Education Protects

Higher educational attainment significantly reduces obesity prevalence.

📉 β = **−0.112**

### 🏛️ Regional Context Matters

Most spatial dependence originates from:

- Food culture 🍔
- Regional lifestyles 🚶
- State-level health policies 🏥
- Economic conditions 💰

rather than simple neighbor-to-neighbor contagion.

### 🎯 Policy Implication

Public health interventions should be:

- 📍 Regionally targeted
- 🏘️ Community focused
- 🎓 Education oriented
- 🏃 Physical activity promoting

---

# 📖 References

- Michimi & Wimberly (2010) — *American Journal of Preventive Medicine*
- Jonah et al. (2024) — *BMC Public Health*
- Xinyi et al. (2022) — *NIU Honors Capstones*
- Slack et al. (2014) — *Rural Sociology*
- Gala et al. (2025) — *Discover Public Health*

---

⭐ **Main Contribution:** This study demonstrates that obesity in the United States is fundamentally a **spatial phenomenon**, requiring geographically informed public health policies and spatial econometric methods to fully understand its determinants.
