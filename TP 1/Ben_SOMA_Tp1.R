

# Charger le package
library(readr)

# Chemin vers le fichier
file_path <- "C:/Users/USER/Desktop/ise math/projet de R/BFA_2021_EHCVM-2_v01_M_CSV/ehcvm_conso_bfa2021.csv"

# Lire le fichier CSV
data <- read_csv(file_path)

# Afficher les premières lignes du fichier
print(data)

