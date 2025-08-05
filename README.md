# Explainable AI Thesis Code
This repository contains code and experiments for my EMBA thesis on explainability in high-risk AI systems under the EU AI Act.

## 📊 Synthetic Data Generation (R)

The script [`01_generate_synthetic_data_and_prepare_model_input.R`](r_scripts/01_generate_synthetic_data_and_prepare_model_input.R) performs the following:

- Loads and cleans the UCI Heart Disease dataset
- Generates synthetic data using the CART method (`synthpop`)
- Balances class distribution
- Creates interpretable dummy variables
- Visualizes real vs synthetic distributions
- Saves final dataset as `heart_hotwired.csv` for modeling

> 📁 Output location: Saved locally — adjust path for your own environment.
