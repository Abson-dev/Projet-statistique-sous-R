# Importation des bases

conso<-read.csv("ehcvm_conso_bfa2021.csv")
menage<-read.csv("ehcvm_menage_bfa2021.csv")
prix<-read.csv("ehcvm_prix_bfa2021.csv")

# Structure de la base

# Dans la base ehcvm consommation du Burkina Faso en 2021, il y a 452 083 observations et 12 variables
str(conso)
#Dans la base ehcvm menage du Burkina Faso en 2021, il y a 7 176 observations et 39 variables
str(menage)
#Dans la base ehcvm menage du Burkina Faso en 2021, il y a 214 270 observations et 28 variables
str(prix)
