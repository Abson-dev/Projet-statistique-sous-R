
#' -------------------------------------------------------------------
#' Script III – Analyse comparative des indicateurs selon le genre 
#' du chef de ménage
#' -------------------------------------------------------------------
#' 
#' Ce script permet de comparer les principaux indicateurs 
#' (continus et catégoriels) entre ménages à chef homme vs chef femme.
#' 
#' -------------------------------------------------------------------


# 1. Préparation des données ---------------------------------------
# On s'assure que HHHSex est un facteur lisible
Base_Principale <- Base_Principale %>%
  mutate(
    HHHSex = as_factor(HHHSex)  # 1=Homme, 2=Femme
  )

# 2. Table des indicateurs continus -------------------------------
# Indicateurs : SCA, rCSI, HDDS_score, SERS
tbl_continuous_indic <- Base_Principale %>%
  select(HHHSex, SCA, rCSI, HDDS_score, SERS) %>%
  tbl_summary(
    by        = HHHSex,
    type      = all_continuous() ~ "continuous2",
    statistic = all_continuous() ~ "{mean} ({sd})",
    digits    = all_continuous() ~ 1,
    label     = list(
      SCA         ~ "Score de conso. alimentaire (SCA)",
      rCSI        ~ "Indice réduit Stratégies de survie (rCSI)",
      HDDS_score  ~ "Score diversité alimentaire (HDDS)",
      SERS        ~ "Score résilience auto-évaluée (SERS)"
    ),
    missing   = "no"
  ) %>%
  add_overall() %>%                              # colonne globale
  add_p(test = list(all_continuous() ~ "t.test")) %>%  # t-test homme vs femme
  bold_labels()

tbl_continuous_indic


# 3. Table des indicateurs catégoriels — comparaison homme vs femme
# Avant de construire la table, on s’assure que Base_Principale contient
# les indicateurs binaires stress/crise/urgence et les catégories SCA/SERS.

Base_Principale <- Base_Principale %>%
  # 3.1 Créer les indicateurs binaires à partir des LhCSI*
  mutate(
    # passer d’abord en numérique pour pouvoir tester >1
    across(starts_with("LhCSIStress"), ~ as.numeric(.x), .names = "num_{col}"),
    across(starts_with("LhCSICrisis"), ~ as.numeric(.x), .names = "num_{col}"),
    across(starts_with("LhCSIEmergency"), ~ as.numeric(.x), .names = "num_{col}")
  ) %>%
  mutate(
    stress_utilise   = if_else(
      rowSums(across(starts_with("num_LhCSIStress"), ~ .x > 1), na.rm = TRUE) > 0,
      "Oui", "Non"
    ),
    crise_utilise    = if_else(
      rowSums(across(starts_with("num_LhCSICrisis"), ~ .x > 1), na.rm = TRUE) > 0,
      "Oui", "Non"
    ),
    urgence_utilise  = if_else(
      rowSums(across(starts_with("num_LhCSIEmergency"), ~ .x > 1), na.rm = TRUE) > 0,
      "Oui", "Non"
    )
  ) %>%
  # 3.2 S’assurer que les catégories SCA et SERS existent et sont facteurs
  mutate(
    SCA_cat_21_35 = factor(SCA_cat_21_35, levels = c("Faible","Moyen","Élevé")),
    SCA_cat_28_42 = factor(SCA_cat_28_42, levels = c("Faible","Moyen","Élevé")),
    SERS_cat      = factor(SERS_cat,      levels = c("Faible","Moyen","Élevé"))
  )

# 3.3 Construire la table gtsummary
tbl_categorical_indic <- Base_Principale %>%
  select(
    HHHSex,
    SCA_cat_21_35, SCA_cat_28_42,
    stress_utilise, crise_utilise, urgence_utilise,
    SERS_cat
  ) %>%
  # convertir HHHSex en facteur lisible si pas déjà fait
  mutate(HHHSex = as_factor(HHHSex)) %>%
  tbl_summary(
    by        = HHHSex,
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits    = all_categorical() ~ 1,
    label     = list(
      SCA_cat_21_35   ~ "Catégorie SCA (21/35)",
      SCA_cat_28_42   ~ "Catégorie SCA (28/42)",
      stress_utilise  ~ "Stratégies Stress utilisées",
      crise_utilise   ~ "Stratégies Crise utilisées",
      urgence_utilise ~ "Stratégies Urgence utilisées",
      SERS_cat        ~ "Catégorie SERS"
    ),
    missing   = "no"
  ) %>%
  add_overall() %>%                                # colonne globale
  add_p(test = all_categorical() ~ "chisq.test") %>%  # test du chi²
  bold_labels()

# Affichage dans R Markdown
tbl_categorical_indic

# Saving des bases
haven::write_dta(Base_Principale, "data/Base_Principale_finale.dta")
haven::write_dta(Base_MAD,       "data/Base_MAD_finale.dta")

sf::st_write(adm1_shp,
         dsn = "data/TD_adm1_clean.shp",
         delete_layer = TRUE)

sf::st_write(adm2_shp,
         dsn = "data/TD_adm2_clean.shp",
         delete_layer = TRUE)

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
