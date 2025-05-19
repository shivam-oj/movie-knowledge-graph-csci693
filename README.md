# movie-knowledge-graph-csci693

A Movie Knowledge Graph for predicting box office success using network analysis and machine learning.

---

## 📁 Data Acquisition and Preprocessing

**Datasets on Google Cloud Storage**:  
🔗 [GCS Public Bucket - IMDb Dataset](https://storage.googleapis.com/imdb_ncdataset/)

- **Raw** – Datasets from [IMDb](https://developer.imdb.com/non-commercial-datasets/) and Box Office Mojo ([Kaggle](https://www.kaggle.com/datasets/igorkirko/wwwboxofficemojocom-movies-with-budget-listed))
- **Refined** – Processed datasets from [Google BigQuery](./data_preprocessing.csv)

---

## 🏗️ Graph Construction

Cypher queries used to create and populate the Neo4j database:

- `graph_construction.cypher` – Constructs nodes and relationships from processed data
- `feature_engineering.cypher` – Adds engineered node/edge properties
- `project_graph.cypher` – Final graph build script

---

## 📊 Graph Embeddings and Centrality

Located in: `graph_embeddings/`

Subfolders:
- `domestic/`, `international/`, `worldwide/` — Each contains:
  - `*_pr.cypher`: PageRank
  - `*_bc.cypher`: Betweenness centrality
  - `*_dc.cypher`: Degree centrality
  - `*_frp.cypher`: FastRP
  - `*_n2v.cypher`: Node2Vec
  - `*_n2v_and_cm.cypher`: Node2Vec + Community metrics

---

## 📈 Visualizations and Analysis

Located in: `vis/`

Jupyter Notebooks:
- `vis_roi_class_distribution.ipynb` – Class distribution of ROI categories
- `vis_fastrp_and_node2vec.ipynb` – Graph embedding visualization

---

## 📋 Tables and Reference Data

Located in: `tables/`

- `domestic_class.xlsx`
- `international_class.xlsx`
- `worldwide_class.xlsx`

These Excel files represent class-wise aggregated results used for classification and visualization.

---

## 📁 Miscellaneous

- `.gitignore` – Python and notebook-related ignores
- `LICENSE` – MIT License
- `data_preprocessing.csv` – Record of preprocessing steps

---

## 🔖 License

This project is licensed under the [MIT License](./LICENSE).  
Created as part of a California State University project for CSCI 693.

---

## 💬 Citation

If you use this project or datasets, please consider citing or referencing this repository.
