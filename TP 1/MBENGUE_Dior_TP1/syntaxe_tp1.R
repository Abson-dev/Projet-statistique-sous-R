#Fixation du répertoire de travail
setwd("C:/Users/THINKPAD/Desktop/MBENGUE_Dior_TP1")


#Importation des bases
ehcvm_conso_sen2021 <- read.csv("ehcvm_conso_sen2021.csv")
ehcvm_men_sen_2021<- read.csv("ehcvm_menage_sen2021.csv")
ehcvm_prix_sen2021<-read.csv("ehcvm_prix_sen2021.csv")


# Visualisation des bases
View(ehcvm_conso_sen2021)
View(ehcvm_prix_sen2021)
View(ehcvm_men_sen_2021)


# Structure des bases
str(ehcvm_conso_sen2021)
str(ehcvm_prix_sen2021)
str(ehcvm_men_sen_2021)
