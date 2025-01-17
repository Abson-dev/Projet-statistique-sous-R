# Chargement des bibliothèques nécessaires

library(readr)  # Fournit des fonctions rapides et faciles pour lire des fichiers CSV (ex: read_csv)
library(dplyr)  # Fournit des outils pour manipuler et transformer des données de manière efficace

# Définition du répertoire de travail
# Le répertoire de travail est défini pour accéder facilement aux fichiers de données. 

setwd("C:/Users/yvesd/Desktop/ISE1/Projet-statistique-sous-R/TP 1")

# Chargement du fichier ehcvm_ihpc_sen2021.csv

ehcvm_ihpc_sen2021 <- read_csv(
  "ehcvm_ihpc_sen2021.csv",  # Nom du fichier CSV à charger
  col_names = TRUE,          # La première ligne du fichier contient les noms des colonnes
  show_col_types = FALSE     # Désactive l'affichage des types de colonnes détectés
)

# Affiche le contenu du fichier dans une fenêtre de visualisation
View(ehcvm_ihpc_sen2021)

# Affiche la structure du dataframe (types de colonnes, aperçu des données, etc.)
str(ehcvm_ihpc_sen2021)

# Chargement du fichier ehcvm_individu_sen2021.csv
ehcvm_individu_sen2021 <- read_csv(
  "ehcvm_individu_sen2021.csv",  # Nom du fichier CSV à charger
  col_names = TRUE,              # La première ligne contient les noms des colonnes
  show_col_types = FALSE         # Désactive l'affichage des types détectés
)

# Affiche le contenu du fichier dans une fenêtre de visualisation
View(ehcvm_individu_sen2021)

# Affiche la structure du dataframe
str(ehcvm_individu_sen2021)

# Chargement du fichier ehcvm_menage_sen2021.csv
ehcvm_menage_sen2021 <- read_csv(
  "ehcvm_menage_sen2021.csv",  # Nom du fichier CSV à charger
  col_names = TRUE,            # La première ligne contient les noms des colonnes
  show_col_types = FALSE       # Désactive l'affichage des types détectés
)

# Affiche le contenu du fichier dans une fenêtre de visualisation
View(ehcvm_menage_sen2021)

# Affiche la structure du dataframe
str(ehcvm_menage_sen2021)

