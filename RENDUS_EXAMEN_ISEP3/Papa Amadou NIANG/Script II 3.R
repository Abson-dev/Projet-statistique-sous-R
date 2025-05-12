
#' -------------------------------------------------------------------
#' Script II 3 - Indice réduit des stratégies de survie (rCSI)
#' -------------------------------------------------------------------
#' 
#' Ce script permet de :
#'   a) Analyse descriptive des variables composant le rCSI
#'   b) Calcul de l’indice rCSI pour chaque ménage
#'   c) Tableau des poids attribués à chaque variable (somme = 21)
#'   d) Cartographie du rCSI par région et département
#' -------------------------------------------------------------------

# 1. Analyse descriptive des variables rCSI (a) ---------------------
# Variables (jours 0–7) :
rCSI_vars <- c("rCSILessQlty", "rCSIBorrow",
               "rCSIMealSize","rCSIMealAdult","rCSIMealNb")

# Préparation : convertir en numérique et limiter à [0,7]
Base_Principale <- Base_Principale %>%
  mutate(across(all_of(rCSI_vars),
                ~ as.numeric(.) %>% pmax(0) %>% pmin(7)))

# Tableau descriptif (médiane [25e–75e]) avec gtsummary
tbl_rCSI_desc <- Base_Principale %>%
  select(all_of(rCSI_vars)) %>%
  tbl_summary(
    statistic = all_continuous() ~ "{median} ({p25}, {p75})",
    digits    = all_continuous() ~ 1,
    label = list(
      rCSILessQlty  ~ "Moins bonne qualité d’aliments (jours)",
      rCSIBorrow    ~ "Emprunt de nourriture/argent (jours)",
      rCSIMealSize  ~ "Réduction taille des repas (jours)",
      rCSIMealAdult ~ "Adultes se restreignent (jours)",
      rCSIMealNb    ~ "Nombre de repas réduit (jours)"
    ),
    missing = "no"
  )

tbl_rCSI_desc


# 2. Calcul du rCSI (b) ---------------------------------------------
# Poids de sévérité d’origine (Maxwell & Caldwell) : 
#   eat less-preferred = 1, borrow = 2, limit portion = 1,
#   restrict adults = 3, reduce meals = 1  (somme = 8)
orig_weights <- c(1, 2, 1, 3, 1)
weights_rCSI <- tibble(
  variable = rCSI_vars,
  weight   = orig_weights * norm_factor
)

# Tableau des poids (c) ---------------------------------------------
tbl_weights_rCSI <- weights_rCSI %>%
  tbl_summary(
    include   = weight,
    statistic = all_continuous() ~ "{median}",
    digits    = all_continuous() ~ 2,
    label = list(
      weight ~ "**Poids**"
    ),
    missing = "no"
  ) %>%
  modify_header(stat_0 ~ "**Variable**") %>%
  modify_spanning_header(all_stat_cols() ~ "Poids attribués (somme = 8)")

tbl_weights_rCSI

# Ajout du calcul du score rCSI à la base (b)
# On applique à chaque ménage : sum(fréquence * poids)
Base_Principale <- Base_Principale %>%
  rowwise() %>%
  mutate(
    rCSI = sum(c_across(all_of(rCSI_vars)) * weights_rCSI$weight)
  ) %>%
  ungroup()

# Synthèse du rCSI
tbl_summary(
  Base_Principale,
  include   = rCSI,
  statistic = rCSI ~ "{mean} ({sd})",
  digits    = rCSI ~ 1,
  label     = rCSI ~ "Indice réduit Stratégies de Survie (rCSI)"
)


# 3. Cartographie du rCSI (d) ---------------------------------------
# 3.1. Nettoyage des codes OCHA dans les shapefiles
#     (ex. TCD19 → TD19)
adm1_shp <- st_read("data/shapefiles/tcd_admbnda_adm1_20250212_AB.shp") %>%
  mutate(adm1_ocha = str_remove(ADM1_PCODE, "C"))

adm2_shp <- st_read("data/shapefiles/tcd_admbnda_adm2_20250212_AB.shp") %>%
  mutate(adm2_ocha = str_remove(ADM2_PCODE, "C"))

# 3.2. Agrégation du rCSI moyen par région et département
rCSI_region <- Base_Principale %>%
  group_by(adm1_ocha = adm1_ocha) %>%
  summarise(mean_rCSI = mean(rCSI, na.rm = TRUE), .groups="drop")

rCSI_dept <- Base_Principale %>%
  group_by(adm2_ocha = adm2_ocha) %>%
  summarise(mean_rCSI = mean(rCSI, na.rm = TRUE), .groups="drop")

# 3.3. Jointure spatiale
adm1_map <- adm1_shp %>% left_join(rCSI_region, by = "adm1_ocha")
adm2_map <- adm2_shp %>% left_join(rCSI_dept, by = "adm2_ocha")

# 3.4. Carte du rCSI moyen par région
ggplot(adm1_map) +
  geom_sf(aes(fill = mean_rCSI), color = "grey50") +
  scale_fill_viridis(name = "rCSI moyen") +
  labs(title = "rCSI moyen par région (7 derniers jours)") +
  theme_minimal()

# 3.5. Carte du rCSI moyen par département
ggplot(adm2_map) +
  geom_sf(aes(fill = mean_rCSI), color = "grey70") +
  scale_fill_viridis(name = "rCSI moyen", option = "magma") +
  labs(title = "rCSI moyen par département (7 derniers jours)") +
  theme_minimal()

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
