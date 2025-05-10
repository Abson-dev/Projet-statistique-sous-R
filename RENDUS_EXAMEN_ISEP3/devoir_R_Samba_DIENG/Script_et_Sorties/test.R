library(tidyverse)
library(janitor)
library(flextable)
library(haven)

base_principale <- read_dta("Data/Base_Principale.dta")
base_mad <- read_dta("Data/Base_MAD.dta")

# Aperçu des données
head(base_principale)
head(base_mad)
str(base_principale)
str(base_mad)
dim(base_principale)
dim(base_mad)





# Vérification des valeurs manquantes
summary(base_principale)
summary(base_mad)


# Comptage des variables quantitatives et qualitatives
quant_vars_principale <- base_principale %>% select(where(is.numeric))
quali_vars_principale <- base_principale %>% select(where(~ !is.numeric(.)))

quant_vars_mad <- base_mad %>% select(where(is.numeric))
quali_vars_mad <- base_mad %>% select(where(~ !is.numeric(.)))

# Résumé
nb_quant_principale <- ncol(quant_vars_principale)
nb_quali_principale <- ncol(quali_vars_principale)

nb_quant_mad <- ncol(quant_vars_mad)
nb_quali_mad <- ncol(quali_vars_mad)

cat("Base Principale:\n")
cat("Variables quantitatives :", nb_quant_principale, "\n")
cat("Variables qualitatives :", nb_quali_principale, "\n\n")

cat("Base MAD:\n")
cat("Variables quantitatives :", nb_quant_mad, "\n")
cat("Variables qualitatives :", nb_quali_mad, "\n")

# Vérification des colonnes avec beaucoup de valeurs manquantes
missing_principale <- base_principale %>% 
  summarise(across(everything(), ~mean(is.na(.)))) %>% 
  pivot_longer(cols = everything(), names_to = "variable", values_to = "missing_rate") %>% 
  arrange(desc(missing_rate))

missing_mad <- base_mad %>% 
  summarise(across(everything(), ~mean(is.na(.)))) %>% 
  pivot_longer(cols = everything(), names_to = "variable", values_to = "missing_rate") %>% 
  arrange(desc(missing_rate))

# Affichage des 10 variables les plus affectées
library(flextable)
missing_principale %>% head(10) %>% flextable() %>% autofit()
missing_mad %>% head(10) %>% flextable() %>% autofit()



# Vérification des doublons dans les deux bases
nb_lignes_principale_avant <- nrow(base_principale)
nb_lignes_mad_avant <- nrow(base_mad)

# Suppression des doublons
base_principale <- base_principale %>% distinct()
base_mad <- base_mad %>% distinct()

nb_lignes_principale_apres <- nrow(base_principale)
nb_lignes_mad_apres <- nrow(base_mad)

# Résumé des doublons trouvés
cat("Base Principale:\n")
cat("Lignes avant nettoyage :", nb_lignes_principale_avant, "\n")
cat("Lignes après nettoyage :", nb_lignes_principale_apres, "\n")
cat("Nombre de doublons supprimés :", nb_lignes_principale_avant - nb_lignes_principale_apres, "\n\n")
