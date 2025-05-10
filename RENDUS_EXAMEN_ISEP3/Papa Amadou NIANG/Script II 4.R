
#' -------------------------------------------------------------------
#' Script II 4 -Stratégies d'adaptation aux moyens d'existence (LhCSI)
#' -------------------------------------------------------------------
#' 
#' Ce script permet de :
#'   a) Analyse descriptive des variables composant le LhCSI
#'   b) Proportion de ménages en situation de stress, crise, urgence en 2022 vs 2023
#'   c) Cartographie des stratégies d’adaptation par région et département
#'
#' -------------------------------------------------------------------

# 1. Analyse descriptive des variables LhCSI (a) --------------------
# Justification : présenter la distribution (n et %) de chaque stratégie
lhd_vars <- c(
  paste0("LhCSIStress", 1:4),
  paste0("LhCSICrisis", 1:3),
  paste0("LhCSIEmergency", 1:3)
)

# Préparer un jeu de données pour la description
desc_LhCSI <- Base_Principale %>%
  # convertir les variables labelled en facteurs R avec leurs labels
  mutate(across(all_of(lhd_vars), as_factor))

# Tableau descriptif : n (%) par modalité pour chaque variable
tbl_LhCSI_desc <- desc_LhCSI %>%
  select(all_of(lhd_vars)) %>%
  tbl_summary(
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits    = all_categorical() ~ 1,
    label = list(
      LhCSIStress1    ~ "Stress 1",
      LhCSIStress2    ~ "Stress 2",
      LhCSIStress3    ~ "Stress 3",
      LhCSIStress4    ~ "Stress 4",
      LhCSICrisis1    ~ "Crise 1",
      LhCSICrisis2    ~ "Crise 2",
      LhCSICrisis3    ~ "Crise 3",
      LhCSIEmergency1 ~ "Urgence 1",
      LhCSIEmergency2 ~ "Urgence 2",
      LhCSIEmergency3 ~ "Urgence 3"
    ),
    missing = "no"
  )

# Affichage de la table
tbl_LhCSI_desc

# 2. Proportions de ménages stress/crise/urgence par année (b) -------
# On construit des indicateurs binaires (Oui/Non) : si un ménage
# a utilisé au moins une stratégie de chaque type.

# a) convertir en numérique pour détecter utilisation (>1 = utilisé)
classif_LhCSI <- Base_Principale %>%
  mutate(across(all_of(lhd_vars), ~ as.numeric(.))) %>%
  mutate(
    stress_utilise   = if_else(
      rowSums(across(starts_with("LhCSIStress"), ~ .x > 1), na.rm = TRUE) > 0,
      "Oui", "Non"
    ),
    crise_utilise    = if_else(
      rowSums(across(starts_with("LhCSICrisis"), ~ .x > 1), na.rm = TRUE) > 0,
      "Oui", "Non"
    ),
    urgence_utilise  = if_else(
      rowSums(across(starts_with("LhCSIEmergency"), ~ .x > 1), na.rm = TRUE) > 0,
      "Oui", "Non"
    ),
    # on s’assure que YEAR est bien numérique
    YEAR = as.integer(YEAR)
  )

# Tableau de répartition par YEAR (avec gtsummary)
tbl_adapt_par_annee <- classif_LhCSI %>%
  select(YEAR, stress_utilise, crise_utilise, urgence_utilise) %>%
  tbl_summary(
    by = YEAR,
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits    = all_categorical() ~ 1,
    label = list(
      stress_utilise  ~ "Stratégie Stress utilisée",
      crise_utilise   ~ "Stratégie Crise utilisée",
      urgence_utilise ~ "Stratégie Urgence utilisée"
    ),
    missing = "no"
  ) %>%
  add_overall()  # ajoute une colonne “Overall” si pertinent

tbl_adapt_par_annee


# 3. Cartographie des stratégies d’adaptation (c) -------------------
# Justification : visualiser la répartition géographique des ménages
# utilisant au moins une stratégie de chaque type.

# 3.1 Nettoyage des PCODE dans les shapefiles
adm1_shp <- st_read("data/shapefiles/tcd_admbnda_adm1_20250212_AB.shp") %>%
  mutate(adm1_ocha = str_remove(ADM1_PCODE, "C"))

adm2_shp <- st_read("data/shapefiles/tcd_admbnda_adm2_20250212_AB.shp") %>%
  mutate(adm2_ocha = str_remove(ADM2_PCODE, "C"))

# 3.2 Agrégation : proportion de ménages par région / département
agg_adapt_region <- classif_LhCSI %>%
  group_by(adm1_ocha, YEAR) %>%
  summarise(
    pct_stress  = mean(stress_utilise == "Oui", na.rm = TRUE) * 100,
    pct_crise   = mean(crise_utilise  == "Oui", na.rm = TRUE) * 100,
    pct_urgence = mean(urgence_utilise== "Oui", na.rm = TRUE) * 100,
    .groups = "drop"
  )

agg_adapt_dept <- classif_LhCSI %>%
  group_by(adm2_ocha, YEAR) %>%
  summarise(
    pct_stress  = mean(stress_utilise == "Oui", na.rm = TRUE) * 100,
    pct_crise   = mean(crise_utilise  == "Oui", na.rm = TRUE) * 100,
    pct_urgence = mean(urgence_utilise== "Oui", na.rm = TRUE) * 100,
    .groups = "drop"
  )

# 3.3 Jointure spatiale et cartographie
# Exemple : carte du % Stress utilisé en 2023 par région
map_region_stress_2023 <- adm1_shp %>%
  left_join(filter(agg_adapt_region, YEAR == 2023), by = "adm1_ocha") %>%
  ggplot() +
  geom_sf(aes(fill = pct_stress), color = "grey50") +
  scale_fill_viridis(name = "% Stress (2023)") +
  labs(
    title = "Proportion de ménages utilisant une stratégie Stress",
    subtitle = "Année 2023, par région"
  ) +
  theme_minimal()

# De même, pour crise et urgence :
map_region_crise_2023 <- adm1_shp %>%
  left_join(filter(agg_adapt_region, YEAR == 2023), by = "adm1_ocha") %>%
  ggplot() +
  geom_sf(aes(fill = pct_crise), color = "grey50") +
  scale_fill_viridis(name = "% Crise (2023)") +
  labs(title = "… stratégie Crise …") +
  theme_minimal()

map_region_urgence_2023 <- adm1_shp %>%
  left_join(filter(agg_adapt_region, YEAR == 2023), by = "adm1_ocha") %>%
  ggplot() +
  geom_sf(aes(fill = pct_urgence), color = "grey50") +
  scale_fill_viridis(name = "% Urgence (2023)") +
  labs(title = "… stratégie Urgence …") +
  theme_minimal()

# Et pour les départements (ex. Stress 2022)
map_dept_stress_2022 <- adm2_shp %>%
  left_join(filter(agg_adapt_dept, YEAR == 2022), by = "adm2_ocha") %>%
  ggplot() +
  geom_sf(aes(fill = pct_stress), color = "grey70") +
  scale_fill_viridis(name = "% Stress (2022)") +
  labs(
    title = "Proportion de ménages utilisant Stress",
    subtitle = "Année 2022, par département"
  ) +
  theme_minimal()

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
