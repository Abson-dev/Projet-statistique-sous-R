
##Charger la library
library(haven)

##Importation de deux bases EDS 
data_enfant <- read_dta("C:/Formation ISE/ISE 1/Logiciel R/Bases/Enfant.dta")
data_femme <- read_dta("C:/Formation ISE/ISE 1/Logiciel R/Bases/Femme.dta")

##Structure des données
str(data_femme)
str(data_enfant)

