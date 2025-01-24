###Importation des bases EHCVM

#Installation des packages
install.packages(c("haven","readr"))
library(readr)
library(haven)

#*Base ménage du Niger
  Base_niger <-  read_dta("ehcvm_menage_ner2021.dta")
  # Affichage de la base
  View(Base_niger)
  
  # Avoir une structure de la base et le type de chaque variable
  str(Base_niger)
  
  #Nombre d'observation de variable
  dim(Base_niger)
  #La base contient 6622 observations et 38 variables
  

#*Base individu du Sénégal
Base_sen<- read.csv("ehcvm_individu_sen2021.csv")
  str(Base_sen)

#*Base ihpc du Togo
Base_togo<- read.csv("ehcvm_ihpc_tgo2021.csv")
  str(Base_togo)

