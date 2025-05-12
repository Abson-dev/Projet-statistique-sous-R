
#' -------------------------------------------------------------------
#' Script II 2 - Score de consommation alimentaire (SCA) 
#'--------------------------------------------------------------------
#'
#' Ce script permet :
#'   a) Décrire les variables composant le SCA
#'   b) Calculer le score SCA pour chaque ménage
#'   c) Présenter les poids attribués à chaque groupe (somme = 16)
#'   d) Catégoriser le SCA selon les seuils 21/35 et 28/42
#'   e) Cartographier le SCA et ses catégories par région et département
#'
#' -------------------------------------------------------------------

# 0. Chargement des librairies nécessaires --------------------------
library(sf)          # pour la cartographie
library(viridis)     # palettes de couleurs
library(stringr)  # pour str_remove()

# 1. Analyse descriptive des variables SCA (a) -----------------------
# Justification : examiner la distribution (jours de 0 à 7) de chaque
# groupe alimentaire avant de composer le score.

# Liste des variables composants le SCA
sca_vars <- c("FCSStap", "FCSPulse", "FCSVeg", "FCSFruit",
              "FCSPr", "FCSDairy", "FCSSugar", "FCSFat")

# Préparer les données : convertir from haven_labelled à numeric,
# puis clamp entre 0 et 7 pour respecter le questionnaire.
Base_Principale <- Base_Principale %>%
  mutate(across(
    all_of(sca_vars),
    ~ as.numeric(.) %>% pmax(0) %>% pmin(7)
  ))

# Tableau descriptif (médiane [25e–75e]) avec gtsummary
tbl_sca_desc <- Base_Principale %>%
  select(all_of(sca_vars)) %>%
  tbl_summary(
    statistic = all_continuous() ~ "{median} ({p25}, {p75})",
    digits    = all_continuous() ~ 1,
    label = list(
      FCSStap  ~ "Céréales & tubercules (jours)",
      FCSPulse ~ "Légumineuses/noix (jours)",
      FCSVeg   ~ "Légumes (jours)",
      FCSFruit ~ "Fruits (jours)",
      FCSPr    ~ "Viande/poisson/œufs (jours)",
      FCSDairy ~ "Produits laitiers (jours)",
      FCSSugar ~ "Sucre (jours)",
      FCSFat   ~ "Matières grasses (jours)"
    ),
    missing = "no"
  )

# Afficher dans R Markdown
tbl_sca_desc


# 2. Calcul du SCA (b) -----------------------------------------------
# Formule (WFP) : SCA = 2×staples + 3×pulses + 1×veg + 1×fruit +
#                  4×protein + 4×dairy + 0.5×sugar + 0.5×fat

Base_Principale <- Base_Principale %>%
  mutate(
    SCA = 2 * FCSStap +
      3 * FCSPulse +
      1 * FCSVeg +
      1 * FCSFruit +
      4 * FCSPr +
      4 * FCSDairy +
      0.5 * FCSSugar +
      0.5 * FCSFat
  )

# Vérification rapide des statistiques du score
tbl_summary(
  Base_Principale,
  include   = SCA,
  statistic = SCA ~ "{mean} ({sd})",
  digits    = SCA ~ 1,
  label     = SCA ~ "Score de conso. alimentaire (SCA)"
)


# 3. Tableau des poids par groupe (c) --------------------------------
# On crée un tibble avec les poids, puis on présente
# ces poids dans un tableau (médiane = poids fixe).
weights <- tibble(
  Céréales   = 2,
  Légumineuses = 3,
  Légumes    = 1,
  Fruits     = 1,
  Protéines  = 4,
  Laitiers   = 4,
  Sucre      = 0.5,
  Graisses   = 0.5
)

tbl_weights <- weights %>%
  tbl_summary(
    include   = everything(),
    statistic = all_continuous() ~ "{median}",
    digits    = all_continuous() ~ 1,
    label = list(
      Céréales     ~ "Céréales & tubercules",
      Légumineuses ~ "Légumineuses/noix",
      Légumes      ~ "Légumes",
      Fruits       ~ "Fruits",
      Protéines    ~ "Viande/poisson/œufs",
      Laitiers     ~ "Produits laitiers",
      Sucre        ~ "Sucre",
      Graisses     ~ "Matières grasses"
    ),
    missing = "no"
  )

# Contrôle programmatique de la somme des poids
stopifnot(sum(unlist(weights)) == 16)

# Afficher
tbl_weights


# 4. Catégorisation du SCA (d) ---------------------------------------
# Seuils WFP courants (21/35 et 28/42)
Base_Principale <- Base_Principale %>%
  mutate(
    SCA_cat_21_35 = case_when(
      SCA <= 21       ~ "Faible",
      SCA <= 35       ~ "Moyen",
      TRUE            ~ "Élevé"
    ),
    SCA_cat_28_42 = case_when(
      SCA <= 28       ~ "Faible",
      SCA <= 42       ~ "Moyen",
      TRUE            ~ "Élevé"
    ),
    across(starts_with("SCA_cat_"), ~ factor(.x, levels = c("Faible","Moyen","Élevé")))
  )

# Tableaux de répartition
tbl_cat_21_35 <- Base_Principale %>%
  tbl_summary(
    include   = SCA_cat_21_35,
    statistic = all_categorical() ~ "{n} ({p}%)",
    label     = SCA_cat_21_35 ~ "Catégorie SCA (21/35)",
    missing   = "no"
  )
tbl_cat_21_35

tbl_cat_28_42 <- Base_Principale %>%
  tbl_summary(
    include   = SCA_cat_28_42,
    statistic = all_categorical() ~ "{n} ({p}%)",
    label     = SCA_cat_28_42 ~ "Catégorie SCA (28/42)",
    missing   = "no"
  )
tbl_cat_28_42


# 5. Représentation spatiale (e) ------------------------------------
# Adaptations à vos shapefiles : ajuster les noms de colonnes pour la jointure.

# 5.1 Charger les shapefiles (régions/départements)
# polygones régionaux
adm1_shp <- st_read("data/shapefiles/tcd_admbnda_adm1_20250212_AB.shp")
adm1_shp <- adm1_shp %>%
  mutate(
    adm1_ocha = str_remove(ADM1_PCODE, "C")
  )

# polygones départements
adm2_shp <- st_read("data/shapefiles/tcd_admbnda_adm2_20250212_AB.shp")
adm2_shp <- adm2_shp %>%
  mutate(
    adm2_ocha = str_remove(ADM2_PCODE, "C")
  )

# 5.2 Agréger le SCA moyen par région & département
sca_region <- Base_Principale %>%
  group_by(adm1_ocha) %>%
  summarise(mean_SCA = mean(SCA, na.rm = TRUE), .groups="drop")

sca_dept <- Base_Principale %>%
  group_by(adm2_ocha) %>%
  summarise(mean_SCA = mean(SCA, na.rm = TRUE), .groups="drop")

# 5.3 Jointure spatiale
adm1_map <- adm1_shp %>%
  left_join(sca_region, by = "adm1_ocha")
adm2_map <- adm2_shp %>%
  left_join(sca_dept, by = "adm2_ocha")

# 5.4 Carte du SCA moyen par région
ggplot(adm1_map) +
  geom_sf(aes(fill = mean_SCA), color = "grey50") +
  scale_fill_viridis(name="SCA moyen") +
  labs(title="SCA moyen par région (7 derniers jours)") +
  theme_minimal()

# 5.5 Carte du SCA moyen par département
ggplot(adm2_map) +
  geom_sf(aes(fill = mean_SCA), color = "grey70") +
  scale_fill_viridis(name="SCA moyen", option="magma") +
  labs(title="SCA moyen par département (7 derniers jours)") +
  theme_minimal()

# 5.6 Carte de la catégorie SCA majoritaire (21/35) par région
modal_region <- Base_Principale %>%
  count(adm1_ocha, SCA_cat_21_35, name="n") %>%
  group_by(adm1_ocha) %>%
  slice_max(n, n=1) %>%
  select(adm1_ocha, modal_cat = SCA_cat_21_35)

adm1_map_cat <- adm1_shp %>%
  left_join(modal_region, by = "adm1_ocha")

ggplot(adm1_map_cat) +
  geom_sf(aes(fill = modal_cat), color="grey50") +
  scale_fill_brewer(name="Catégorie SCA", palette="Set2") +
  labs(title="Catégorie SCA (21/35) majoritaire par région") +
  theme_minimal()

# 5.7 Carte de la catégorie SCA majoritaire (21/35) par département
modal_dept <- Base_Principale %>%
  count(adm2_ocha, SCA_cat_21_35, name="n") %>%
  group_by(adm2_ocha) %>%
  slice_max(n, n=1) %>%
  select(adm2_ocha, modal_cat = SCA_cat_21_35)

adm2_map_cat <- adm2_shp %>%
  left_join(modal_dept, by = "adm2_ocha")

ggplot(adm2_map_cat) +
  geom_sf(aes(fill = modal_cat), color="grey70") +
  scale_fill_brewer(name="Catégorie SCA", palette="Set3") +
  labs(title="Catégorie SCA (21/35) majoritaire par département") +
  theme_minimal()

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
