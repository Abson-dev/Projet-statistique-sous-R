
#' -------------------------------------------------------------------
#' Script II 5 – Score de diversité alimentaire des ménages
#' -------------------------------------------------------------------
#' 
#' Ce script permet :
#'   a) Analyse descriptive des variables HDDS
#'   b) Calcul du score HDDS (nombre de groupes consommés)
#'   c) Cartographie du score HDDS moyen par région et département
#' -------------------------------------------------------------------

# 1. Analyse descriptive des variables HDDS (a) ---------------------
# Liste des 16 groupes alimentaires du module HDDS
vars_hdds <- c(
  "HDDSStapCer", "HDDSStapRoot", "HDDSPulse", 
  "HDDSVegOrg",  "HDDSVegGre",   "HDDSVegOth",
  "HDDSFruitOrg","HDDSFruitOth",
  "HDDSPrMeatF", "HDDSPrMeatO",  "HDDSPrFish","HDDSPrEgg",
  "HDDSDairy",   "HDDSSugar",    "HDDSFat",   "HDDSCond"
)

# Conversion des variables labeled en facteurs pour gtsummary
hd_data <- Base_Principale %>%
  mutate(across(all_of(vars_hdds), ~ as_factor(as.integer(.)))) 

# Tableau descriptif : n (%) de ménages ayant consommé chaque groupe
tbl_hdds_desc <- hd_data %>%
  select(all_of(vars_hdds)) %>%
  tbl_summary(
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits    = all_categorical() ~ 1,
    label = list(
      HDDSStapCer  ~ "Céréales & dérivés",
      HDDSStapRoot ~ "Tubercules & racines",
      HDDSPulse    ~ "Légumineuses/oléagineux",
      HDDSVegOrg   ~ "Légumes org.",
      HDDSVegGre   ~ "Légumes verts",
      HDDSVegOth   ~ "Autres légumes",
      HDDSFruitOrg ~ "Fruits org.",
      HDDSFruitOth ~ "Autres fruits",
      HDDSPrMeatF  ~ "Viande fraîche",
      HDDSPrMeatO  ~ "Viande transformée",
      HDDSPrFish   ~ "Poisson",
      HDDSPrEgg    ~ "Œufs",
      HDDSDairy    ~ "Produits laitiers",
      HDDSSugar    ~ "Sucre",
      HDDSFat      ~ "Matières grasses",
      HDDSCond     ~ "Condiments"
    ),
    missing = "no"
  )

# Affichage
tbl_hdds_desc


# 2. Calcul du score HDDS (b) ---------------------------------------
# Le score HDDS est la somme des groupes consommés (0 ou 1 chacun)
Base_Principale <- Base_Principale %>%
  mutate(
    HDDS_score = rowSums(
      across(all_of(vars_hdds), ~ as.numeric(.x)), 
      na.rm = TRUE
    )
  )

# Statistiques du score (mean ± sd)
tbl_summary(
  Base_Principale,
  include   = HDDS_score,
  statistic = HDDS_score ~ "{mean} ({sd})",
  digits    = HDDS_score ~ 1,
  label     = HDDS_score ~ "Score de diversité alimentaire (HDDS)"
)


# 3. Cartographie du score HDDS (c) --------------------------------
# 3.1 Préparer shapefiles en nettoyant les PCODE (retirer "C")
adm1_shp <- st_read("data/shapefiles/tcd_admbnda_adm1_20250212_AB.shp") %>%
  mutate(adm1_ocha = str_remove(ADM1_PCODE, "C"))
adm2_shp <- st_read("data/shapefiles/tcd_admbnda_adm2_20250212_AB.shp") %>%
  mutate(adm2_ocha = str_remove(ADM2_PCODE, "C"))

# 3.2 Agréger le HDDS_score moyen par région et par département
hd_region <- Base_Principale %>%
  group_by(adm1_ocha = adm1_ocha) %>%
  summarise(mean_HDDS = mean(HDDS_score, na.rm = TRUE), .groups = "drop")

hd_dept <- Base_Principale %>%
  group_by(adm2_ocha = adm2_ocha) %>%
  summarise(mean_HDDS = mean(HDDS_score, na.rm = TRUE), .groups = "drop")

# 3.3 Jointure spatiale
adm1_map <- adm1_shp %>% left_join(hd_region, by = "adm1_ocha")
adm2_map <- adm2_shp %>% left_join(hd_dept, by = "adm2_ocha")

# 3.4 Carte du HDDS moyen par région
ggplot(adm1_map) +
  geom_sf(aes(fill = mean_HDDS), color = "grey50") +
  scale_fill_viridis(name = "HDDS moyen") +
  labs(
    title = "Score de diversité alimentaire moyen par région",
    subtitle = "Nombre de groupes consommés"
  ) +
  theme_minimal()

# 3.5 Carte du HDDS moyen par département
ggplot(adm2_map) +
  geom_sf(aes(fill = mean_HDDS), color = "grey70") +
  scale_fill_viridis(name = "HDDS moyen", option = "magma") +
  labs(
    title = "Score de diversité alimentaire moyen par département",
    subtitle = "Nombre de groupes consommés"
  ) +
  theme_minimal()

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
