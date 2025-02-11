#importation base ECHVM CONS
basecons=read.csv("C:/ISE/Dossier R/Projet-statistique-sous-R/TP 1/ehcvm_conso_sen2021.csv")
base
print(base)
View(basecons)
#description de la basecons
str(basecons)
# la basecons est constititué de 14 variables et compte 545801 observations.

#importation base ECHVM IHPC
baseihpc=read.csv("C:/ISE/Dossier R/Projet-statistique-sous-R/TP 1/ehcvm_ihpc_sen2021.csv")
View(baseihpc)
#description de la base del'Indice harmonisé des Prix à la Consommation
str(baseihpc)
# la base ihpc est constitué de 5 variables et compte 60 observations.
#importation base ECHVM MENAGE
basemenage=read.csv("C:/ISE/Dossier R/Projet-statistique-sous-R/TP 1/ehcvm_menage_sen2021.csv")
View(basemenage)
#Description  de la base 
str(basemenage)
# la base ménage est constitué de 38 variables et compte 7120 observations.
