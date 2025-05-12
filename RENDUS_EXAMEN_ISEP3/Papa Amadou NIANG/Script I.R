
#' ----------------------------------------------------------------------
#' Script I.R - Analyse consistance des bases de données
#' ----------------------------------------------------------------------
#' 
#' Ce script traite la première partie de l'examen de projet 
#' statistique sous R.
#' 
#' Il consiste à faire une analyse de consistence des bases 
#' de données 
#' 
#' Auteur : Papa Amadou NIANG
#' Enseignant: Aboubacar Hema
#' Date : 10-05-2025
#' ----------------------------------------------------------------------


# 0. Chargement des librairies --------------------------------------
# tidyverse  : manipulation de données (dplyr, tidyr, etc.)
# janitor    : diagnostics rapides (get_dupes, tabyl, bilan NA)
# lubridate  : gestion et extraction d’attributs de dates
library(tidyverse)
library(janitor)
library(lubridate)

# 1. Import des données ---------------------------------------------
Base_Principale <- haven::read_dta("data/ehcvm/Base_Principale.dta")
Base_MAD       <- haven::read_dta("data/ehcvm/Base_MAD.dta")

# 2. Dimensions et structure ----------------------------------------
# But : s’assurer qu’aucune ligne ou colonne n’a été perdue à l’import
cat("=== Base_Principale ===\n")
cat("Dimensions :", dim(Base_Principale), "\n")
glimpse(Base_Principale)  
cat("\n=== Base_MAD ===\n")
cat("Dimensions :", dim(Base_MAD), "\n")
glimpse(Base_MAD)

# 3. Identifiants : unicité et non-nullité -------------------------
# Justification : l’ID doit toujours être renseigné et unique
cat("\nIDs manquants (Principale)  :", sum(is.na(Base_Principale$ID)), "\n")
cat("IDs manquants (MAD)         :", sum(is.na(Base_MAD$ID)), "\n")

# Recherche de doublons avec janitor
dups_main <- get_dupes(Base_Principale, ID)
dups_mad  <- get_dupes(Base_MAD, ID)
cat("Doublons Base_Principale :", nrow(dups_main), "occurrences\n")
cat("Doublons Base_MAD       :", nrow(dups_mad),  "occurrences\n")
if (nrow(dups_main) > 0) print(dups_main)
if (nrow(dups_mad)  > 0) print(dups_mad)

# 4. Bilan global des valeurs manquantes ----------------------------
# But : identifier les variables avec trop de NA (>5 %) pour décider 
#       d’imputation, d’exclusion ou d’investigation approfondie
missing_main <- Base_Principale %>% 
  summarise_all(~ sum(is.na(.))) %>% 
  pivot_longer(everything(), names_to="variable", values_to="n_na") %>% 
  mutate(pct_na = n_na / nrow(Base_Principale) * 100)
missing_mad <- Base_MAD %>% 
  summarise_all(~ sum(is.na(.))) %>% 
  pivot_longer(everything(), names_to="variable", values_to="n_na") %>% 
  mutate(pct_na = n_na / nrow(Base_MAD) * 100)

cat("\nVariables > 5% de NA (Base_Principale) :\n")
missing_main %>% filter(pct_na > 5) %>% arrange(desc(pct_na)) %>% print()
cat("\nVariables > 5% de NA (Base_MAD) :\n")
missing_mad  %>% filter(pct_na > 5) %>% arrange(desc(pct_na)) %>% print()

# 5. Cohérence des dates (Base_Principale) --------------------------
# Vérifier que YEAR et SvyMonth correspondent vraiment à SvyDate
Base_Principale <- Base_Principale %>%
  mutate(
    year_extrait  = year(SvyDate),
    month_extrait = month(SvyDate)
  )
incons_dates <- Base_Principale %>%
  filter(year_extrait != YEAR | month_extrait != SvyMonth)
cat("\nIncohérences date <-> YEAR/SvyMonth :", nrow(incons_dates), "\n")
if (nrow(incons_dates) > 0) {
  head(incons_dates %>%
         select(ID, SvyDate, YEAR, SvyMonth, year_extrait, month_extrait)) %>% print()
}

# 6. Plages de valeurs et outliers ---------------------------------
# Exemple 6.1 : taille du ménage (HHSize) — doit être un entier ≥ 1 
#               et raisonnable (ex. ≤ 20)
cat("\nRésumé HHSize :\n"); summary(Base_Principale$HHSize)
outliers_hhsize <- Base_Principale %>%
  filter(HHSize < 1 | HHSize > 20) %>%
  select(ID, HHSize)
if (nrow(outliers_hhsize) > 0) {
  cat("Cas aberrants HHSize (principale) :\n"); print(outliers_hhsize)
}

# Exemple 6.2 : âge du répondant MAD_resp_age — doit être entre 0 et 120
cat("\nRésumé MAD_resp_age :\n"); summary(Base_MAD$MAD_resp_age)
outliers_age <- Base_MAD %>%
  filter(MAD_resp_age < 0 | MAD_resp_age > 120) %>%
  select(ID, MAD_resp_age)
if (nrow(outliers_age) > 0) {
  cat("Cas aberrants MAD_resp_age (MAD) :\n"); print(outliers_age)
}

# 7. Vérification des sommes de sous-catégories --------------------
# Exemple : somme des composantes d'âge/genre doit == HHSize
vars_age_sex <- c("HHSize05M","HHSize23M","HHSize59M","HHSize5114M",
                  "HHSize1549M","HHSize5064M","HHSize65AboveM",
                  "HHSize05F","HHSize23F","HHSize59F","HHSize5114F",
                  "HHSize1549F","HHSize5064F","HHSize65AboveF")
Base_Principale <- Base_Principale %>%
  mutate(
    sum_cat = rowSums(across(all_of(vars_age_sex))),
    diff_HH  = HHSize - sum_cat
  )
erreurs_cat <- Base_Principale %>% filter(diff_HH != 0) %>% select(ID, HHSize, sum_cat, diff_HH)
cat("\nLignes où HHSize ≠ somme des catégories (n = ", nrow(erreurs_cat),"):\n", sep = "")
if (nrow(erreurs_cat) > 0) print(head(erreurs_cat))

# 8. Contrôle des modalités des variables labellisées ---------------
# But : repérer des labels inattendus ou mal codés (ex. EverBreastF)
cat("\nModalités EverBreastF (Base_MAD) :\n")
Base_MAD %>% tabyl(EverBreastF) %>% adorn_pct_formatting() %>% print()

# Autres exemples : HDDSStapCer, HDDSStapRoot, etc.
cat("\nModalités HDDSStapCer (Principale) :\n")
Base_Principale %>% tabyl(HDDSStapCer) %>% adorn_pct_formatting() %>% print()

# 9. Cohérence des codes administratifs ----------------------------
# Vérifier que chaque nom d’admin1 correspond toujours au même code OCHA
dup_admin1 <- Base_Principale %>%
  count(ADMIN1Name, adm1_ocha) %>%
  group_by(ADMIN1Name) %>%
  filter(n() > 1)
cat("\nCas où un ADMIN1Name a plusieurs adm1_ocha différents:\n")
if (nrow(dup_admin1) > 0) print(dup_admin1) else cat("Aucun cas trouvé\n")

# Même vérification pour admin2
dup_admin2 <- Base_Principale %>%
  count(ADMIN2Name, adm2_ocha) %>%
  group_by(ADMIN2Name) %>%
  filter(n() > 1)
cat("\nCas où un ADMIN2Name a plusieurs adm2_ocha différents:\n")
if (nrow(dup_admin2) > 0) print(dup_admin2) else cat("Aucun cas trouvé\n")

# 10. Cohérence inter-bases via ID ----------------------------------
# But : préparer la fusion sans perdre d’observations
ids_only_in_mad  <- setdiff(Base_MAD$ID, Base_Principale$ID)
ids_only_in_main <- setdiff(Base_Principale$ID, Base_MAD$ID)
cat("\nID dans MAD mais pas dans Principale :", length(ids_only_in_mad), "\n")
cat("ID dans Principale mais pas dans MAD :", length(ids_only_in_main), "\n")
if (length(ids_only_in_mad) > 0)  print(head(ids_only_in_mad))
if (length(ids_only_in_main) > 0) print(head(ids_only_in_main))

# 11. Synthèse automatisée ------------------------------------------
consistency_report <- list(
  dims_Principale   = dim(Base_Principale),
  dims_MAD          = dim(Base_MAD),
  missing_max_P     = missing_main %>% summarise(max_pct = max(pct_na)) %>% pull(max_pct),
  missing_max_M     = missing_mad  %>% summarise(max_pct = max(pct_na)) %>% pull(max_pct),
  n_dup_main        = nrow(dups_main),
  n_dup_mad         = nrow(dups_mad),
  n_incons_dates    = nrow(incons_dates),
  n_err_cat_sum     = nrow(erreurs_cat),
  admin1_issues     = nrow(dup_admin1),
  admin2_issues     = nrow(dup_admin2),
  unmatched_in_MAD  = length(ids_only_in_mad),
  unmatched_in_Main = length(ids_only_in_main)
)
cat("\n--- Rapport de consistance ---\n")
print(consistency_report)


#' ----------------------------------------------------------------------
#' Fin du script
#' ----------------------------------------------------------------------
