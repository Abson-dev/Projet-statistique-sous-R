## Définissons le répertoire de travail

setwd("C:/Users/ANSD/Documents/ENSAE-ISE/SEMESTRE 2/R/Projet-statistique-sous-R/TP 1/KAFANDO")

## Importation des bases
base_me = read.csv("ehcvm_menage_bfa2021.csv")
base_co = read.csv("s00_co_bfa2021.csv")

### Visualisation des bases
View(base_co)
View(base_me)

## Description des bases

str(base_me)
# La base ménage contient 7176 observations sur 39 variables.
# Parmi les variables, 11 sont de type numéric et 28 de type charactère.



str(base_co)
# La base consommation contient 570 observations réparties sur 22 variables
# Parmi les variables, 04 sont de type numéric et 18 de type charactère
