#' -------------------------------------------------------------------
#' Script II 6 - Score de résilience auto-évaluée (SERS)
#' -------------------------------------------------------------------
#' 
#' Ce script permet de :
#'   a) Analyse descriptive des 10 sous-énoncés Likert composant le SERS
#'   b) Calcul du score SERS normalisé (0–100) par min-max
#'   c) Cartographie du SERS moyen et de ses catégories par région et département
#' -------------------------------------------------------------------

# 1. Variables SERS et conversion -----------------------------------
# Liste des 10 sous-énoncés Likert (1-5) du module SERS
vars_sers <- c(
  "SERSRebondir",        # "Nous pouvons rebondir..."
  "SERSRevenue",         # "Nos revenus sont stables..."
  "SERSMoyen",           # "Nous avons les moyens..."
  "SERSDifficultes",     # "Nous gérons les difficultés..."
  "SERSSurvivre",        # "Nous pouvons survivre..."
  "SERSFamAmis",         # "Nous comptons sur familles/amis..."
  "SERSPoliticiens",     # "Nous faisons confiance à politiques..."
  "SERSLecons",          # "Nous tirons des leçons..."
  "SERSPreparerFuture",  # "Nous préparons l’avenir..."
  "SERSAvertissementEven" # "Nous sommes avertis des événements..."
)

# a) Analyse descriptive (n (%) par modalité Likert)
tbl_sers_desc <- Base_Principale %>%
  # convertir chaque variable haven_labelled en facteur R
  mutate(across(all_of(vars_sers), as_factor)) %>%
  select(all_of(vars_sers)) %>%
  tbl_summary(
    by        = NULL,
    statistic = all_categorical() ~ "{n} ({p}%)",
    digits    = all_categorical() ~ 1,
    label     = list(
      SERSRebondir        ~ "Capacité à rebondir",
      SERSRevenue         ~ "Stabilité des revenus",
      SERSMoyen           ~ "Moyens de subsistance",
      SERSDifficultes     ~ "Gestion des difficultés",
      SERSSurvivre        ~ "Capacité de survie",
      SERSFamAmis         ~ "Soutien familles/amis",
      SERSPoliticiens     ~ "Confiance en politiques",
      SERSLecons          ~ "Leçons tirées",
      SERSPreparerFuture  ~ "Préparation du futur",
      SERSAvertissementEven ~ "Avertissement aux événements"
    ),
    missing   = "no"
  )

# Affichage
tbl_sers_desc


# 2. Calcul du SERS (b) ---------------------------------------------
# a) repasser en numérique pour sommation (Likert codé 1–5)
Base_Principale <- Base_Principale %>%
  mutate(across(all_of(vars_sers), ~ as.numeric(as.character(.))))

# b) somme brute des réponses (x) et normalisation min-max → [0,100]
#    xmin = 10 (10×1), xmax = 50 (10×5)
Base_Principale <- Base_Principale %>%
  rowwise() %>%
  mutate(
    SERS_raw = sum(c_across(all_of(vars_sers)), na.rm = TRUE),
    SERS     = (SERS_raw - 10) / (50 - 10) * 100
  ) %>%
  ungroup()

# Statistiques du SERS normalisé
tbl_summary(
  Base_Principale,
  include   = SERS,
  statistic = SERS ~ "{mean} ({sd})",
  digits    = SERS ~ 1,
  label     = SERS ~ "Score de résilience auto-évaluée (SERS)"
)


# 3. Catégorisation du SERS -----------------------------------------
# terciles fixes : <33=Faible, 33–<66=Moyen, ≥66=Élevé
Base_Principale <- Base_Principale %>%
  mutate(
    SERS_cat = case_when(
      SERS < 33      ~ "Faible",
      SERS < 66      ~ "Moyen",
      TRUE           ~ "Élevé"
    ),
    SERS_cat = factor(SERS_cat, levels = c("Faible","Moyen","Élevé"))
  )

# Répartition par catégorie
tbl_sers_cat <- Base_Principale %>%
  tbl_summary(
    include   = SERS_cat,
    statistic = all_categorical() ~ "{n} ({p}%)",
    label     = SERS_cat ~ "Catégorie SERS"
  )

tbl_sers_cat


# 4. Cartographie du SERS par région et département (c) -------------
# 4.1 Charger et nettoyer les shapefiles (retirer "C" des PCODE)
adm1_shp <- st_read("data/shapefiles/tcd_admbnda_adm1_20250212_AB.shp") %>%
  mutate(adm1_ocha = str_remove(ADM1_PCODE, "C"))
adm2_shp <- st_read("data/shapefiles/tcd_admbnda_adm2_20250212_AB.shp") %>%
  mutate(adm2_ocha = str_remove(ADM2_PCODE, "C"))

# 4.2 Agréger le SERS moyen et la modalité majoritaire par zone
#   Région
agg_sers_reg <- Base_Principale %>%
  group_by(adm1_ocha) %>%
  summarise(
    mean_SERS  = mean(SERS, na.rm = TRUE),
    modal_SERS = names(sort(table(SERS_cat), decreasing = TRUE))[1],
    .groups = "drop"
  )

#   Département
agg_sers_dept <- Base_Principale %>%
  group_by(adm2_ocha) %>%
  summarise(
    mean_SERS  = mean(SERS, na.rm = TRUE),
    modal_SERS = names(sort(table(SERS_cat), decreasing = TRUE))[1],
    .groups = "drop"
  )

# 4.3 Jointure spatiale
adm1_map <- adm1_shp %>% left_join(agg_sers_reg, by = "adm1_ocha")
adm2_map <- adm2_shp %>% left_join(agg_sers_dept, by = "adm2_ocha")

# 4.4 Carte du SERS moyen par région
ggplot(adm1_map) +
  geom_sf(aes(fill = mean_SERS), color = "grey50") +
  scale_fill_viridis(name = "SERS moyen") +
  labs(title = "SERS moyen par région") +
  theme_minimal()

# 4.5 Carte du SERS moyen par département
ggplot(adm2_map) +
  geom_sf(aes(fill = mean_SERS), color = "grey70") +
  scale_fill_viridis(name = "SERS moyen", option = "magma") +
  labs(title = "SERS moyen par département") +
  theme_minimal()

# 4.6 Carte de la catégorie majoritaire par région
ggplot(adm1_map) +
  geom_sf(aes(fill = modal_SERS), color = "grey50") +
  scale_fill_brewer(name = "Catégorie SERS", palette = "Set2") +
  labs(title = "Catégorie SERS majoritaire par région") +
  theme_minimal()

# 4.7 Carte de la catégorie majoritaire par département
ggplot(adm2_map) +
  geom_sf(aes(fill = modal_SERS), color = "grey70") +
  scale_fill_brewer(name = "Catégorie SERS", palette = "Set3") +
  labs(title = "Catégorie SERS majoritaire par département") +
  theme_minimal()

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
