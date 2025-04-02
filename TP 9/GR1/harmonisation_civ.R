library(haven)
library(dplyr)
library(labelled)
library(sjPlot)


civ2018pre <- read_dta("pre_merging_datasets/civ2018_welfare_premerge.dta")
civ2021pre <- read_dta("pre_merging_datasets/civ2021_welfare_premerge.dta")


### hmstat -----

# les fréquences avant harmonisation pour comparer

sjPlot::plot_frq(civ2018pre$hmstat, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hmstat, coord.flip = TRUE, show.na = TRUE)


# Appliquer uniquement les bons labels si besoin
civ2018pre$hmstat <- labelled::labelled(civ2018pre$hmstat, c(
  "Célibataire" = 1,
  "Marié(e) monogame" = 2,
  "Marié(e) polygame" = 3,
  "Union libre" = 4,
  "Veuf(ve)" = 5,
  "Divorcé(e)" = 6,
  "Séparé" = 7
))


# les fréquences après harmonisation pour comparer

sjPlot::plot_frq(civ2018pre$hmstat, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hmstat, coord.flip = TRUE, show.na = TRUE)


### hnation ----

sjPlot::plot_frq(civ2018pre$hnation, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hnation, coord.flip = TRUE, show.na = TRUE)


# Recodage de 2018 selon les modalités 2021
civ2018pre <- civ2018pre %>%
  dplyr::mutate_at(c("hnation"), recode,
                   "1" = 1,  # Bénin
                   "2" = 2,  # Burkina Faso
                   "3" = 4,  # Côte d'Ivoire
                   "4" = 8,  # Guinée Bissau
                   "5" = 10, # Mali
                   "6" = 11, # Niger
                   "7" = 13, # Sénégal
                   "8" = 15, # Togo
                   "9" = 12, # Nigeria
                   "10" = 16, # Autre CEDEAO
                   "11" = 17, # Autre Afrique
                   "12" = 18  # Autre hors Afrique
  )

# Réassigner les labels harmonisés
civ2018pre$hnation <- labelled::labelled(civ2018pre$hnation, c(
  "Bénin" = 1,
  "Burkina Faso" = 2,
  "Cape-vert" = 3,
  "Cote d'ivoire" = 4,
  "Gambie" = 5,
  "Ghana" = 6,
  "Guinee" = 7,
  "Guinée Bissau" = 8,
  "Liberia" = 9,
  "Mali" = 10,
  "Niger" = 11,
  "Nigeria" = 12,
  "Sénégal" = 13,
  "Serra-Leonne" = 14,
  "Togo" = 15,
  "Autre CEDEAO" = 16,
  "Autre Afrique" = 17,
  "Autre pays hors Afrique" = 18
))

sjPlot::plot_frq(civ2018pre$hnation, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hnation, coord.flip = TRUE, show.na = TRUE)


## hdiploma----

sjPlot::plot_frq(civ2018pre$hdiploma, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hdiploma, coord.flip = TRUE, show.na = TRUE)


civ2018pre$hdiploma <- labelled::labelled(
  civ2018pre$hdiploma,
  labels = c(
    "Aucun" = 0,
    "cepe" = 1,
    "bepc" = 2,
    "cap" = 3,
    "bt" = 4,
    "bac" = 5,
    "DEUG, DUT, BTS" = 6,
    "Licence" = 7,
    "Maitrise / Ingénieur des travaux" = 8,
    "Master/DEA/DESS/Ingénieur de conception" = 9,
    "Doctorat/Phd" = 10
  )
)

sjPlot::plot_frq(civ2018pre$hdiploma, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hdiploma, coord.flip = TRUE, show.na = TRUE)


## hactiv7j-------

sjPlot::plot_frq(civ2018pre$hactiv7j, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hactiv7j, coord.flip = TRUE, show.na = TRUE)

civ2018pre <- civ2018pre %>%
  dplyr::mutate_at(c("hactiv7j"), recode,
                   "1" = 1,  # Occupe
                   "2" = 4,  # Chômeur devient 4
                   "3" = 2,  # TF cherchant emploi devient 2
                   "4" = 3,  # TF ne cherchant pas devient 3
                   "5" = 5,  # Inactif
                   "6" = 6   # Moins de 5 ans
  )

civ2018pre$hactiv7j <- labelled::labelled(
  civ2018pre$hactiv7j,
  c(
    "Occupe" = 1,
    "TF cherchant emploi" = 2,
    "TF cherchant pas" = 3,
    "Chomeur" = 4,
    "Inactif" = 5,
    "Moins de 5 ans" = 6
  )
)

sjPlot::plot_frq(civ2018pre$hactiv7j, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hactiv7j, coord.flip = TRUE, show.na = TRUE)






###hbranch -------

sjPlot::plot_frq(civ2018pre$hbranch, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hbranch, coord.flip = TRUE, show.na = TRUE)


civ2018pre$hbranch <- labelled::labelled(
  civ2018pre$hbranch,
  c(
    "Agriculture" = 1,
    "Elevage/syl./peche" = 2,
    "Indust. extr." = 3,
    "Autr. indust." = 4,
    "btp" = 5,
    "Commerce" = 6,
    "Restaurant/Hotel" = 7,
    "Trans./Comm." = 8,
    "Education/Sante" = 9,
    "Services perso." = 10,
    "Aut. services" = 11
  )
)

sjPlot::plot_frq(civ2018pre$hbranch, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hbranch, coord.flip = TRUE, show.na = TRUE)


##hcsp----------


# les fréquences avant harmonisation pour comparer
sjPlot::plot_frq(civ2018pre$hcsp, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hcsp, coord.flip = TRUE, show.na = TRUE)

civ2018pre$hcsp <- labelled::labelled(
  civ2018pre$hcsp,
  c(
    "Cadre supérieur" = 1,
    "Cadre moyen/agent de maîtrise" = 2,
    "Ouvrier ou employé qualifié" = 3,
    "Ouvrier ou employé non qualifié" = 4,
    "Manœuvre, aide ménagère" = 5,
    "Stagiaire ou Apprenti rénuméré" = 6,
    "Stagiaire ou Apprenti non rénuméré" = 7,
    "Travailleur Familial contribuant pour une entreprise familial" = 8,
    "Travailleur pour compte propre" = 9,
    "Patron/Employeur" = 10
  )
)
# les fréquences après harmonisation pour comparer si c bon

sjPlot::plot_frq(civ2018pre$hcsp, coord.flip = TRUE, show.na = TRUE)
sjPlot::plot_frq(civ2021pre$hcsp, coord.flip = TRUE, show.na = TRUE)
