# ==============================================================================
# ANALIZĂ COMPARATIVĂ: OLS vs. LAG vs. ERROR vs. MANSKI
# ==============================================================================

# 1. Librării
library(sf)
library(spdep)
library(spatialreg)
library(readr)
library(Matrix)

# 2. Încărcare Date
path_shp <- "C:/Users/cteod/OneDrive/Desktop/proiect econometrie spatiala/usa_shapefiles/cb_2018_us_county_5m.shp"
path_csv <- "C:/Users/cteod/OneDrive/Desktop/proiect econometrie spatiala/bd.csv"

usa_map <- st_read(path_shp)
date_proiect <- read_csv(path_csv)

# 3. Pregătire Join (FIPS fix)
usa_map$GEOID <- as.character(usa_map$GEOID)
date_proiect$FIPS <- sprintf("%05d", as.numeric(date_proiect$FIPS))
usa_data <- merge(usa_map, date_proiect, by.x = "GEOID", by.y = "FIPS")

# 4. Matrice de ponderi (Queen)
nb <- poly2nb(usa_data, queen = TRUE)
lw <- nb2listw(nb, style = "W", zero.policy = TRUE)

# 5. Formula de regresie
formula_reg <- OBESITY_CrudePrev ~ CHECKUP_CrudePrev + DEPRESSION_CrudePrev + 
  GHLTH_CrudePrev + HIGHCHOLESTEROL_CrudePrev + 
  LPA_CrudePrev + SLEEP_CrudePrev + 
  NoHighSchoolDiploma + BachelorDegree

# 6. Rularea modelelor

# MODEL 0: CLASIC (OLS) - Regresia liniară simplă
m_ols <- lm(formula_reg, data = usa_data)

# MODEL 1: SPATIAL LAG (SAR)
m_lag <- lagsarlm(formula_reg, data = usa_data, listw = lw, method = "Matrix", quiet = TRUE, zero.policy = TRUE)

# MODEL 2: SPATIAL ERROR (SEM)
m_err <- errorsarlm(formula_reg, data = usa_data, listw = lw, method = "Matrix", quiet = TRUE, zero.policy = TRUE)

# MODEL 3: MANSKI (SAC/ROBUST)
m_robust <- sacsarlm(formula_reg, data = usa_data, listw = lw, method = "Matrix", quiet = TRUE, zero.policy = TRUE)

# 7. Crearea tabelului comparativ final
tabel_final <- data.frame(
  Indicator = c("Log-Likelihood", "AIC", "Schwarz (BIC)", "R-Squared / Pseudo R2"),
  
  OLS = c(
    as.numeric(logLik(m_ols)),
    AIC(m_ols),
    BIC(m_ols),
    summary(m_ols)$r.squared
  ),
  
  Spatial_Lag = c(
    as.numeric(logLik(m_lag)),
    AIC(m_lag),
    BIC(m_lag),
    cor(usa_data$OBESITY_CrudePrev, m_lag$fitted.values)^2
  ),
  
  Spatial_Error = c(
    as.numeric(logLik(m_err)),
    AIC(m_err),
    BIC(m_err),
    cor(usa_data$OBESITY_CrudePrev, m_err$fitted.values)^2
  ),
  
  Manski_Robust = c(
    as.numeric(logLik(m_robust)),
    AIC(m_robust),
    BIC(m_robust),
    cor(usa_data$OBESITY_CrudePrev, m_robust$fitted.values)^2
  )
)

# 8. Afișare rezultate
cat("\n\n========================================================\n")
cat("          TABEL COMPARATIV FINAL (TOATE MODELELE)\n")
cat("========================================================\n")
print(tabel_final, digits = 4)
cat("========================================================\n")

summary(m_robust)

# ==============================================================================
# DIAGNOSTIC MODEL MANSKI (SAC / SARAR)
# DOAR TESTE APLICABILE DIRECT PE SAC
# ==============================================================================

library(spdep)
library(tseries)

# ------------------------------------------------------------------------------
# 1. AUTOCORELAȚIE SPAȚIALĂ REZIDUALĂ
# Moran I pe reziduurile modelului Manski
# H0: nu există autocorelație spațială reziduală
# ------------------------------------------------------------------------------
resid_manski <- residuals(m_robust)

moran_manski <- moran.test(
  resid_manski,
  lw,
  zero.policy = TRUE
)

cat("\n--------------------------------------------------\n")
cat("Moran I pe reziduurile Modelului Manski (SAC)\n")
cat("--------------------------------------------------\n")
print(moran_manski)


# ------------------------------------------------------------------------------
# 2. NORMALITATEA REZIDUURILOR (INFORMATIV)
# Jarque-Bera aplicat reziduurilor SAC
# ------------------------------------------------------------------------------
jb_manski <- jarque.bera.test(resid_manski)

cat("\n--------------------------------------------------\n")
cat("Jarque-Bera – Normalitatea reziduurilor (SAC)\n")
cat("--------------------------------------------------\n")
print(jb_manski)


# ------------------------------------------------------------------------------
# 3. Q-Q PLOT – VERIFICARE VIZUALĂ
# ------------------------------------------------------------------------------
qqnorm(
  resid_manski,
  main = "Q-Q Plot – Reziduuri Model Manski (SAC)"
)
qqline(resid_manski, col = "red")


# ------------------------------------------------------------------------------
# 4. PSEUDO R-SQUARED (FIT STATISTIC PENTRU SAC)
# ------------------------------------------------------------------------------
pseudo_r2_manski <- cor(
  usa_data$OBESITY_CrudePrev,
  m_robust$fitted.values
)^2

cat("\n--------------------------------------------------\n")
cat("Pseudo R-squared – Model Manski (SAC)\n")
cat("--------------------------------------------------\n")
print(pseudo_r2_manski)

# ==============================================================================
# SFÂRȘIT DIAGNOSTIC MODEL MANSKI
# ==============================================================================
