This repository contains the code developed for the master’s thesis:

**“Balancing Compliance and Innovation: Addressing Explainability in AI Systems under the EU AI Act”**
by Vladimir Boshnjakovski
Executive MBA in Data Science and Digital Transformation
Vienna University of Economics and Business

The thesis explores how businesses can implement explainability in high-risk AI systems in line with the EU Artificial Intelligence Act (AI Act), without sacrificing performance or innovation. This repository provides all supporting code and experiments, including global and local explainability techniques, comparison of white-box and black-box models, and visualizations used in the thesis.

**🧪 Dataset**
This project uses the UCI Heart Disease Dataset, a widely recognized dataset in healthcare-related machine learning tasks. It contains anonymized clinical data on patients, with the goal of predicting the presence of heart disease based on various health indicators such as blood pressure, cholesterol levels, chest pain type, and more.

**⚙️ Preprocessing for Interpretability:**
Manual one-hot encoding was applied to categorical variables to maintain full control over the structure and naming of new features. Feature names were renamed to be self-explanatory (e.g., "Sex: Female" instead of "sex = 0"), improving clarity for stakeholders and aligning with the goals of explainable AI.

**🧪 Data Usage Across Models:**
The original dataset was used for training white-box models (e.g., decision trees, logistic regression), where interpretability is inherently built-in. A synthetic version of the dataset was created and used exclusively to train the black-box model (deep neural network). This allowed for controlled testing of post-hoc explainability techniques like SHAP, LIME, and counterfactual explanations.

**📄 License**
This repository is shared for academic and educational purposes. For any commercial use, please contact the author directly
