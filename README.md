# Projet-statistique-sous-R
 
Le cours de Projet Statistique sous R et Python est dispense par Mr Hema Aboubacar, [Analyste de Recherche a IFPRI](https://www.ifpri.org/profile/aboubacar-hema/) depuis 2022 aux etudiants de l'[ENSAE - Dakar](https://www.ensae.sn/).
Ce cours a pour but de permettre aux etudiant.e.s de maitriser l'exploration des donnees (EDA) avec R a savoir les etapes suivantes:

1 - Comprendre le probleme

     - Quel est l'objectif?
     - Quelles sont les variables clees/importantes
     - Y a t-il des contraintes specifiques?

2 - Chargement des donnees

     - Lecture du fichier (CSV, dta, Excel, SPSS, SQL, etc)
     - Apercu des premieres lignes
     - Verification de la dimension de la base
     - Informations generales sur les colonnes/variables

3 - Verification de la qualite des donnees

     - Valeurs manquantes
     - Doublons
     - Types de donnees
     - Detection de valeurs aberrantes (Boxplot, IQR, Z-score)
     

4 - Analyse univariee


5 - Analyse bivariee


6 - Traitement des variables


7 - Detection des valeurs aberrantes et anomalies/incoherence


8 - Gestion des valeurs manquantes


9 - Verification de la base finale


10 - Modelisation/Econometrie/etc

 **Encours de redaction**

## Data Credits

### TP 1

**Important**: Il ne faut pas importer les donnees dans le compte github.

### TP 2

### TP 3

A partir de Rmarkdown, reproduisez les rapports suivants:

- [Résumé de cours : Séries numériques](https://www.bibmath.net/ressources/index.php?action=affiche&quoi=mathsup/cours/series.html#:~:text=Dans%20toute%20la%20suite%2C%20%28un%29n%E2%88%88N%20%28u%20n%29%20n,%3D%20%E2%88%91%20k%20%3D%200%20n%20u%20k.)

- [Exercices corrigés - Séries numériques - études pratiques](https://bibmath.net/ressources/index.php?action=affiche&quoi=bde/analyse/suitesseries/serienum_prat&type=fexo)

### TP 4

En utilisant les enquetes EHCVM 2019 des pays de l'UEMOA, proposez une harmisation de ces bases de donnees au niveau administratif le plus fin (communes par exemple).
Le decoupage administratif a utilise est soit [HDX](https://data.humdata.org/) ou [geoBoundaries](https://www.geoboundaries.org/simplifiedDownloads.html)

### TP 5
Pour chacune des bases EHCVM 2021/2022, il faut:

- Sortir les statistiques descriptives ;
- Faire la jointure avec la base ménage; 
- Sortir des stats compte tenu de la jointure; 
- Sortir des résultats avec et sans poids
  
**Important**: Le TP est a faire sur Rmarkdown et l'utilisation du package [gtsummary](https://www.danieldsjoberg.com/gtsummary/) est recommande.
  
### TP 6

Pour chacune des bases EHCVM 2018/2019, il faut:

- Sortir les statistiques descriptives ;
- Faire la jointure avec la base ménage; 
- Sortir des stats compte tenu de la jointure; 
- Sortir des résultats avec et sans poids
  
**Important**: Le TP est a faire sur Rmarkdown et l'utilisation du package [gtsummary](https://www.danieldsjoberg.com/gtsummary/) est recommande.

### TP 7

**ISEP 3**

Structurer le **TP 4** sous forme de livre en ligne en utilisant [bookdown](https://bookdown.org/yihui/bookdown/).
Vous devriez avoir un seul lien qui regroupe toutes les etapes d'harmonisation des bases des donnees des differents pays.

**Bon courage!**

### TP 8

**Pour les ISE 1**

**Cartographie avec R**

En utilisant les outputs du **TP 4**, faites des cartes en affichant des variables/indicateurs suivant:
 - les pays
 - les regions/le 1er decoupage administratif du pays
 - les departements/le 2e decoupage administratif du pays
 - les communes/le 3e decoupage administratif du pays

**Echeance: lundi 10 mars 2025 a 23h59**

### TP 9

**Pour les ISE 1 et ISEP 3**

Ce TP consiste a merger les bases **welfare** des EHCVM 2018 ET 2021 en une seule base.

**Echeance: lundi 31 mars 2025 a 23h59**

### TP 10

- Theme 1: Application de l'Intelligence Artificiel(IA) avec R
- Theme 2: Pratique des enquetes avec R
              - [High-Frequency-Checks-R](https://github.com/J-PAL/high-frequency-checks-R/blob/master/R%20script/HFC_template.R)
- Theme 3: Reproduire un livre a l'aide de R
- Theme 4: Suivie de la collecte des donnees avec R
- Theme 5: Developpement d'un package sur R : Cas du package [sdmApp](https://github.com/Abson-dev/sdmApp)
- Theme 6: Le calcul parallele sur R
- Theme 7: Traitement de donnees avec le package tidyverse
- Theme 8: Le package janitor
- Theme 9: Tableaux avec gtsummary
- Theme 10: Le package reticulate: R et Python
- Theme 11: Developpement de package sur R
- Theme 12: Questionnaire d'enquete avec R
- Theme 13: Automatisation des rapports avec R : le package rmarkdown
- Theme 14: Tableaux de bord avec R shiny
- Theme 15: Traitement des questions ouvertes: text mining

 
 **Presentation: samedi 5 avril 2025**

### TP 11 : Synthese des presentations

Chacun.e fera une synthese des differentes presentations


### TP 12 : Examen de 4 a 5h sur table avec les ordinateurs pour les ISE 1 et ISEP 3

Vous aurez 4 a 5h pour faire votre examen final sur table avec les ordinateurs.
L'utilisation de ChatGPT, Gimini ou toute IA qui vous sera utile.



## License
This course material is licensed under a Creative Commons Attribution 4.0 International (CC BY 4.0). You are free to re-use and adapt the material but are required to give appropriate credit to the original author as below:

## References

- [Geocomputation with R](https://r.geocompx.org/)
- [Statistical Inference via Data Science](https://moderndive.com/)
- [R Markdown Cookbook](https://bookdown.org/yihui/rmarkdown-cookbook/)
- [Text Mining with R](https://www.tidytextmining.com/)
- [R Graphics Cookbook, 2nd edition](https://r-graphics.org/)
- [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/)
- [blogdown: Creating Websites with R Markdown](https://bookdown.org/yihui/blogdown/)
- [R Programming for Data Science](https://bookdown.org/rdpeng/rprogdatascience/)
- [Efficient R programming](https://csgillespie.github.io/efficientR/)
- [Advanced R](https://adv-r.hadley.nz/)
- [Data Visualization](https://socviz.co/)
- [Engineering Production-Grade Shiny Apps](https://engineering-shiny.org/)
- [Forecasting: Principles and Practice](https://otexts.com/fpp2/)
- [Fundamentals of Data Visualization](https://clauswilke.com/dataviz/)
- [Hands-On Programming with R](https://rstudio-education.github.io/hopr/)
- [R for Data Science](https://r4ds.had.co.nz/)
- [R Packages (2e)](https://r-pkgs.org/)

  
## Additional resources

- [The Epidemiologist R Handbook](https://epirhandbook.com/en/)
