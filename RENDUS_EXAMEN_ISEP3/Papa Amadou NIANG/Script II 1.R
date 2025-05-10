
#' -------------------------------------------------------------------
#' Script II 1 - Analyse socio-démographique des ménages
#' -------------------------------------------------------------------
#'
#' Ce script décrit les caractéristiques des ménages enquêtés :
#'   - taille du ménage
#'   - profil du chef de ménage (sexe, âge, éducation, activité, 
#'                               statut matrimonial)
#'   - composition par âges et sexes
#'
#' -------------------------------------------------------------------

# 0. Chargement des librairies --------------------------------------
# gtsummary : création de tableaux récapitulatifs élégants
# haven : pour la conversion as_factor()
library(haven)
library(gtsummary)

# 1. Table des variables continues : taille du ménage et âge du chef
# Justification : on présente la moyenne (écart-type) pour décrire 
#                la distribution de ces indicateurs clés.
tbl_continuous <- Base_Principale %>%
  select(
    HHSize,    # taille du ménage (nombre de personnes)
    HHHAge     # âge du chef de ménage
  ) %>%
  tbl_summary(
    statistic = all_continuous() ~ "{mean} ({sd})",
    digits    = all_continuous() ~ 1,
    label = list(
      HHSize ~ "Taille du ménage",
      HHHAge ~ "Âge du chef de ménage"
    ),
    missing = "no"
  )

# Afficher immédiatement dans R Markdown
tbl_continuous


# 2. Table des variables catégorielles : profil du chef de ménage
# Justification : conversion des colonnes labellisées en facteurs
#                pour un fonctionnement correct de tbl_summary()

tbl_categorical <- Base_Principale %>%
  # Conversion des colonnes haven_labelled en factors R
  mutate(across(
    c(HHHSex, HHHEdu, HHHMainActivity, HHHMatrimonial),
    ~ as_factor(.)
  )) %>%
  select(
    HHHSex,           # sexe du chef de ménage (Homme/Femme)
    HHHEdu,           # niveau d’éducation du chef
    HHHMainActivity,  # activité principale du chef
    HHHMatrimonial    # statut matrimonial du chef
  ) %>%
  tbl_summary(
    # Afficher n (pourcentage) par modalité
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits    = all_categorical() ~ 1,
    label = list(
      HHHSex          ~ "Sexe du chef de ménage",
      HHHEdu          ~ "Niveau d'éducation du chef",
      HHHMainActivity ~ "Activité principale du chef",
      HHHMatrimonial  ~ "Statut matrimonial du chef"
    ),
    missing = "no"  # ne pas afficher les NA
  )

# Affichage de la table dans R Markdown
tbl_categorical



# 3. Composition moyenne du ménage par groupe d’âge et sexe
# On calcule le % de chaque groupe dans chaque ménage, puis on
# présente la moyenne (écart-type) de ces pourcentages.
Base_Principale_prop <- Base_Principale %>%
  mutate(
    pct_0_5M   = HHSize05M    / HHSize * 100,
    pct_5_14M  = HHSize5114M  / HHSize * 100,
    pct_15_49M = HHSize1549M  / HHSize * 100,
    pct_50pM   = (HHSize5064M + HHSize65AboveM) / HHSize * 100,
    pct_0_5F   = HHSize05F    / HHSize * 100,
    pct_5_14F  = HHSize5114F  / HHSize * 100,
    pct_15_49F = HHSize1549F  / HHSize * 100,
    pct_50pF   = (HHSize5064F + HHSize65AboveF) / HHSize * 100
  )

tbl_composition <- Base_Principale_prop %>%
  select(starts_with("pct_")) %>%
  tbl_summary(
    statistic = all_continuous() ~ "{mean} ({sd})",
    digits    = all_continuous() ~ 1,
    label = list(
      pct_0_5M   ~ "Enfants 0–5 ans (M) (%)",
      pct_5_14M  ~ "Enfants 5–14 ans (M) (%)",
      pct_15_49M ~ "Adultes 15–49 ans (M) (%)",
      pct_50pM   ~ "Personnes ≥50 ans (M) (%)",
      pct_0_5F   ~ "Enfants 0–5 ans (F) (%)",
      pct_5_14F  ~ "Enfants 5–14 ans (F) (%)",
      pct_15_49F ~ "Adultes 15–49 ans (F) (%)",
      pct_50pF   ~ "Personnes ≥50 ans (F) (%)"
    ),
    missing = "no"
  )

tbl_composition


# -------------------------------------------------------------------
# Fin de la Partie II.1 – Analyse socio-démographique des ménages
# -------------------------------------------------------------------
