


########## Lawa Foumsou Prosper ISE_1_eco_TP1

### Installation de quelques packages

install.packages("bookdown")
install.packages("dplyr")
install.packages("ggplot2")


### Importation d'une base

### Fixation de l'environement de travail

setwd("C:/Users/user/Desktop/as3/economie informelle/ehcvm")

### Chargement du package haven pour importer une base sous format stata

library(haven)

base_1 <- read_dta("ehcvm_individu_SEN2018.dta")
base_2 <- read_dta("ehcvm_menage_SEN2018.dta")
base_3 <- read_dta("ehcvm_welfare_SEN2018.dta")

# Afficher un aperçu de la base_1
head(base_1)
View(base_1)

# Afficher un aperçu de la base_2
head(base_2)
View(base_2)

# Afficher un aperçu de la base_3
head(base_3)
View(base_3)

### Visualisation de la structure d'une base

str(base_1)
str(base_2)
str(base_3)

########################## Fin du TP1

