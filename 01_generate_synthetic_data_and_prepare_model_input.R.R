# STEP 1: Load Required Packages
library(tidyverse)    # includes dplyr, ggplot2, readr, etc.
library(synthpop)     # for synthetic data generation
library(GGally)       # for ggpairs and correlation plots
library(patchwork)    # for arranging multiple ggplots

# STEP 2: Load and Clean Original Data
url <- "https://raw.githubusercontent.com/nmiuddin/UCI-Heart-Disease-Dataset/master/data/heart-disease-UCI.csv"
df <- read_csv(url) %>%
  filter(ca != 4)  # remove invalid or unknown ca values

# STEP 3: Convert Only Categorical Variables to Factors (retain numeric codes)
df_clean <- df %>%
  mutate(
    sex     = factor(sex),
    cp      = factor(cp),
    fbs     = factor(fbs),
    restecg = factor(restecg),
    exang   = factor(exang),
    slope   = factor(slope),
    ca      = factor(ca),
    thal    = factor(thal),
    target  = factor(target)
  )

# STEP 4: Prepare Data for Synthesis (drop NAs, keep usable variables)
df_for_synth <- df_clean %>%
  select(where(~ is.numeric(.x) || is.factor(.x))) %>%
  drop_na()

# STEP 5: Check and Store Real Class Distribution (target)
real_dist <- prop.table(table(df_for_synth$target))
print(real_dist)

# STEP 6: Generate Large Synthetic Dataset
set.seed(123)
synth_result <- syn(df_for_synth, m = 1, method = "cart")
df_synth_big <- synth_result$syn %>% sample_n(2000, replace = TRUE)

# STEP 7: Sample Synthetic Rows to Match Real Class Proportions
n_total <- 1000
n_yes   <- round(n_total * real_dist["1"])
n_no    <- n_total - n_yes

yes_synth <- df_synth_big %>% filter(target == "1") %>% sample_n(n_yes)
no_synth  <- df_synth_big %>% filter(target == "0") %>% sample_n(n_no)

df_synthetic_balanced <- bind_rows(yes_synth, no_synth)

# STEP 8: Label Source and Combine Real + Synthetic Data
df_for_synth$source <- "Real"
df_synthetic_balanced$source <- "Synthetic"
df_combined <- bind_rows(df_for_synth, df_synthetic_balanced)
df_combined$source <- as.factor(df_combined$source)

# STEP 9: Preview Combined Dataset
cat("\n✅ Target Distribution by Source:\n")
print(table(df_combined$target, df_combined$source))

cat("\n✅ Dimensions:\n")
print(dim(df_combined))

cat("\n✅ Sample Preview:\n")
print(head(df_combined))

# STEP 10: Rename Columns to Human-Readable Labels
df_combined <- df_combined %>%
  rename(
    `Age` = age,
    `Sex (0=Female, 1=Male)` = sex,
    `Chest Pain Type (4 Categories)` = cp,
    `Resting Blood Pressure (mm Hg)` = trestbps,
    `Serum Cholesterol (mg/dL)` = chol,
    `Fasting Blood Sugar > 120 mg/dL (1=Yes)` = fbs,
    `Resting Electrocardiographic Results` = restecg,
    `Maximum Heart Rate Achieved` = thalach,
    `Exercise-Induced Angina (1=Yes)` = exang,
    `ST Depression Induced by Exercise` = oldpeak,
    `Slope of the Peak Exercise ST Segment` = slope,
    `Number of Major Vessels Colored by Fluoroscopy` = ca,
    `Type of Thalassemia` = thal,
    `Presence of Heart Disease (1=Yes)` = target
  )

# STEP 11: Generate Core Visualizations

# Define custom colors
cp_colors <- c("#66c2a5", "#fc8d62", "#8da0cb", "#e78ac3")  # Chest pain types
hd_colors <- c("0" = "#66c2a5", "1" = "#fc8d62")            # Heart disease presence

# Plot 1: Chest Pain Type
p1 <- ggplot(df_combined, aes(x = `Chest Pain Type (4 Categories)`)) +
  geom_bar(aes(fill = `Chest Pain Type (4 Categories)`)) +
  scale_fill_manual(values = cp_colors) +
  labs(title = "Chest Pain Type", x = NULL, y = "Count") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(fill = "none")

# Plot 2: Heart Disease Presence
p2 <- ggplot(df_combined, aes(x = `Presence of Heart Disease (1=Yes)`, 
                              fill = `Presence of Heart Disease (1=Yes)`)) +
  geom_bar() +
  scale_fill_manual(values = hd_colors) +
  labs(title = "Heart Disease Presence", x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5)) +
  guides(fill = "none")

# Plot 3: Max Heart Rate Achieved
p3 <- ggplot(df_combined, aes(x = `Maximum Heart Rate Achieved`)) +
  geom_histogram(binwidth = 5, fill = "skyblue", color = "white") +
  geom_density(aes(y = ..count..), color = "#3b528b", size = 1) +
  labs(title = "Max Heart Rate Achieved", x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5))

# Plot 4: ST Depression by Exercise
p4 <- ggplot(df_combined, aes(x = `ST Depression Induced by Exercise`)) +
  geom_histogram(binwidth = 0.25, fill = "lightcoral", color = "white") +
  geom_density(aes(y = ..count..), color = "#c51b7d", size = 1) +
  labs(title = "ST Depression by Exercise", x = NULL, y = NULL) +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(hjust = 0.5))

# Combine all plots in a 1x4 layout
final_plot <- p1 | p2 | p3 | p4

# Display plot
print(final_plot)

# Start with a copy to preserve original
df_hot <- df_combined

# 1. Sex (0 = Female, 1 = Male)
df_hot <- df_hot %>%
  mutate(
    `Sex: Female` = ifelse(`Sex (0=Female, 1=Male)` == 0, 1, 0),
    `Sex: Male`   = ifelse(`Sex (0=Female, 1=Male)` == 1, 1, 0)
  )

# 2. Chest Pain Type (0–3)
df_hot <- df_hot %>%
  mutate(
    `Chest Pain: Typical Angina`     = ifelse(`Chest Pain Type (4 Categories)` == 0, 1, 0),
    `Chest Pain: Atypical Angina`    = ifelse(`Chest Pain Type (4 Categories)` == 1, 1, 0),
    `Chest Pain: Non-Anginal`        = ifelse(`Chest Pain Type (4 Categories)` == 2, 1, 0),
    `Chest Pain: Asymptomatic`       = ifelse(`Chest Pain Type (4 Categories)` == 3, 1, 0)
  )

# 3. Fasting Blood Sugar
df_hot <- df_hot %>%
  mutate(
    `Fasting Blood Sugar: Yes` = ifelse(`Fasting Blood Sugar > 120 mg/dL (1=Yes)` == 1, 1, 0),
    `Fasting Blood Sugar: No`  = ifelse(`Fasting Blood Sugar > 120 mg/dL (1=Yes)` == 0, 1, 0)
  )

# 4. Resting ECG
df_hot <- df_hot %>%
  mutate(
    `Resting ECG: Normal`                   = ifelse(`Resting Electrocardiographic Results` == 0, 1, 0),
    `Resting ECG: ST Abnormality`          = ifelse(`Resting Electrocardiographic Results` == 1, 1, 0),
    `Resting ECG: Left Ventricular Hypertrophy` = ifelse(`Resting Electrocardiographic Results` == 2, 1, 0)
  )

# 5. Exercise-Induced Angina
df_hot <- df_hot %>%
  mutate(
    `Exercise-Induced Angina: Yes` = ifelse(`Exercise-Induced Angina (1=Yes)` == 1, 1, 0),
    `Exercise-Induced Angina: No`  = ifelse(`Exercise-Induced Angina (1=Yes)` == 0, 1, 0)
  )

# 6. Slope of ST Segment
df_hot <- df_hot %>%
  mutate(
    `ST Slope: Upsloping`   = ifelse(`Slope of the Peak Exercise ST Segment` == 0, 1, 0),
    `ST Slope: Flat`        = ifelse(`Slope of the Peak Exercise ST Segment` == 1, 1, 0),
    `ST Slope: Downsloping` = ifelse(`Slope of the Peak Exercise ST Segment` == 2, 1, 0)
  )

# 7. Thalassemia
df_hot <- df_hot %>%
  mutate(
    `Thalassemia: Normal`            = ifelse(`Type of Thalassemia` == 0, 1, 0),
    `Thalassemia: Fixed Defect`      = ifelse(`Type of Thalassemia` == 1, 1, 0),
    `Thalassemia: Reversible Defect` = ifelse(`Type of Thalassemia` == 2, 1, 0)
  )

# 8. Number of Vessels by Fluoroscopy
df_hot <- df_hot %>%
  mutate(
    `Fluoroscopy: 0 Vessels` = ifelse(`Number of Major Vessels Colored by Fluoroscopy` == 0, 1, 0),
    `Fluoroscopy: 1 Vessel`  = ifelse(`Number of Major Vessels Colored by Fluoroscopy` == 1, 1, 0),
    `Fluoroscopy: 2 Vessels` = ifelse(`Number of Major Vessels Colored by Fluoroscopy` == 2, 1, 0),
    `Fluoroscopy: 3 Vessels` = ifelse(`Number of Major Vessels Colored by Fluoroscopy` == 3, 1, 0)
  )

# Optional: Drop original categorical columns (retain only human-readable dummies)
df_hot <- df_hot %>%
  select(-c(
    `Sex (0=Female, 1=Male)`,
    `Chest Pain Type (4 Categories)`,
    `Fasting Blood Sugar > 120 mg/dL (1=Yes)`,
    `Resting Electrocardiographic Results`,
    `Exercise-Induced Angina (1=Yes)`,
    `Slope of the Peak Exercise ST Segment`,
    `Type of Thalassemia`,
    `Number of Major Vessels Colored by Fluoroscopy`
  ))

# Optional: Convert all 0/1 dummy columns to factors
df_hot <- df_hot %>%
  mutate(across(where(~ all(.x %in% c(0,1))), as.factor))

# ✅ Preview updated dataset
glimpse(df_hot)

write_csv(df_hot, "C:/Users/Vladimir/Desktop/heart_hotwired.csv")

library(ggplot2)

# Example: Maximum Heart Rate
ggplot(df_combined, aes(x = `Maximum Heart Rate Achieved`, fill = source)) +
  geom_density(alpha = 0.5) +
  labs(title = "Distribution of Max Heart Rate: Real vs. Synthetic", x = NULL, y = "Density") +
  theme_minimal()

# Example: Chest Pain Type
ggplot(df_combined, aes(x = `Chest Pain Type (4 Categories)`, fill = source)) +
  geom_bar(position = "dodge") +
  labs(title = "Chest Pain Type: Real vs. Synthetic", x = "Type", y = "Count") +
  theme_minimal()

library(GGally)

ggpairs(df_combined, columns = c("Age", "Maximum Heart Rate Achieved", 
                                 "Resting Blood Pressure (mm Hg)", 
                                 "ST Depression Induced by Exercise"),
        aes(color = source, alpha = 0.5))


