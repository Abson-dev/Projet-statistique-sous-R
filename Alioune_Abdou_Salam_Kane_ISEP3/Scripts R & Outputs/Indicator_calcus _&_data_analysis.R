# Je tiens à préciser que toutes les visualisations se feront via l'application shiny 


# ===============================================================
# TABLEAU SOCIO-DÉMOGRAPHIQUE – Version “Femmes vs Hommes”
# ===============================================================
#
# Objectif : produire un tableau clair et complet des caractéristiques
#            des ménages, stratifié par le sexe du chef de ménage.
#            Les libellés STATA sont automatiquement convertis en facteurs
#            pour afficher « Femme » / « Homme », etc. au lieu des codes.

# 1. Chargement des packages nécessaires
# Chargement des packages nécessaires
library(tidyverse)     # Pour la manipulation de données (inclut dplyr, ggplot2, etc.)
library(haven)         # Pour lire les fichiers .dta (Stata) et autres formats SPSS/SAS
library(janitor)       # Pour nettoyer les noms de variables avec clean_names()
library(labelled)      # Pour gérer les variables avec labels (ex. convertir en facteur avec as_factor())
library(gtsummary)     # Pour produire des tableaux de résumé statistiques propres
library(flextable)     # Pour mettre en forme les tableaux (export Word/PowerPoint)


# 2. Importation de la base nettoyée et nettoyage des noms
base_corrigee <- read_dta("data/Base_Principale_corrigee.dta") %>%
  clean_names()

# 3. Conversion des variables labelisées en facteurs
base_corrigee <- base_corrigee %>%
  mutate(across(
    where(is.labelled), 
    haven::as_factor
  ))

# 4. Sélection des variables à décrire
vars_a_decrire <- c(
  "hhh_age",     # Âge du chef de ménage
  "hh_size",     # Taille du ménage
  "hhh_edu"      # Diplôme le plus élevé
)

# 5. Création du tableau descriptif stratifié
tableau_sociodemo <- base_corrigee %>%
  select(all_of(vars_a_decrire), hhh_sex) %>%
  tbl_summary(
    by = hhh_sex,
    type = list(
      hhh_age ~ "continuous",
      hh_size ~ "continuous"
    ),
    statistic = list(
      all_continuous()  ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 2,
    label = list(
      hhh_age   ~ "Âge du chef de ménage",
      hh_size   ~ "Taille du ménage",
      hhh_edu   ~ "Diplôme le plus élevé"
    ),
    missing = "ifany"
  ) %>%
  add_n(col_label = "**Effectif**", statistic = "{N_nonmiss}") %>%
  modify_header(
    label  ~ "**Variable**",
    stat_1 ~ "**Femmes**",
    stat_2 ~ "**Hommes**"
  ) %>%
  bold_labels() %>%
  italicize_levels()

# 6. Conversion en flextable pour export Word propre
tableau_sociodemo_ft <- tableau_sociodemo %>%
  as_flex_table() %>%
  flextable::set_table_properties(width = 1, layout = "autofit") %>%
  flextable::fontsize(part = "all", size = 10) %>%
  flextable::padding(padding = 4, part = "all") %>%
  flextable::align(align = "left", part = "all")

# 7. Affichage
tableau_sociodemo_ft






# ----------------------------------------------------------------
# 📊 ANALYSE DESCRIPTIVE – VARIABLES DU SCORE DE CONSOMMATION ALIMENTAIRE (SCA)
# ----------------------------------------------------------------
# Objectif : Résumer la fréquence moyenne de consommation (en jours / 7) des groupes alimentaires
# selon les standards du SCA du Programme Alimentaire Mondial (PAM)

# ✅ Chaque variable représente : 
# Combien de jours, au cours des 7 derniers jours, les membres du ménage ont consommé un groupe alimentaire

# 📦 Variables sélectionnées et leurs libellés :
# fcs_stap   : Céréales, racines, tubercules (riz, pain, pommes de terre, manioc…)
# fcs_pulse  : Légumineuses (haricots, lentilles, pois chiches, arachides)
# fcs_dairy  : Produits laitiers (lait, yaourt, fromage)
# fcs_pr     : Protéines animales (viande, poisson, œufs)
# fcs_veg    : Légumes (toutes variétés)
# fcs_fruit  : Fruits (toutes variétés)
# fcs_fat    : Matières grasses (huile, beurre, margarine)
# fcs_sugar  : Produits sucrés (sucre, bonbons, boissons sucrées)
# fcs_cond   : Condiments, café/thé, épices, sel



# ------------------------------------------------------------------
# 📁 2. IMPORTATION DE LA BASE CORRIGÉE
# ------------------------------------------------------------------
base_corrigee <- read_dta("data/Base_Principale_corrigee.dta") |>
  clean_names() |>
  mutate(
    across(where(is.labelled), as_factor)   # Codes STATA → facteurs R
  )

# ------------------------------------------------------------------
# 🍽️ 3. VARIABLES DU SCA : fréquence (fois) de consommation en 7 jours
# ------------------------------------------------------------------
vars_sca <- c(
  "fcs_stap",   # Céréales / tubercules
  "fcs_pulse",  # Légumineuses
  "fcs_dairy",  # Produits laitiers
  "fcs_pr",     # Viande / poisson / œufs
  "fcs_veg",    # Légumes
  "fcs_fruit",  # Fruits
  "fcs_fat",    # Graisses / huiles
  "fcs_sugar",  # Sucre / sucreries
  "fcs_cond"    # Condiments / épices
)

# ------------------------------------------------------------------
# 🗒️ 4. LIBELLÉS lisibles pour le tableau
# ------------------------------------------------------------------
libelles_sca <- list(
  fcs_stap  ~ "Céréales / tubercules (nb. de fois sur 7 j)",
  fcs_pulse ~ "Légumineuses (nb. de fois sur 7 j)",
  fcs_dairy ~ "Produits laitiers (nb. de fois sur 7 j)",
  fcs_pr    ~ "Viande / poisson / œufs (nb. de fois sur 7 j)",
  fcs_veg   ~ "Légumes (nb. de fois sur 7 j)",
  fcs_fruit ~ "Fruits (nb. de fois sur 7 j)",
  fcs_fat   ~ "Graisses / huiles (nb. de fois sur 7 j)",
  fcs_sugar ~ "Sucre / sucreries (nb. de fois sur 7 j)",
  fcs_cond  ~ "Condiments / épices (nb. de fois sur 7 j)"
)

# ------------------------------------------------------------------
# 📊 5-A. TABLEAU GLOBAL (toutes observations)
# ------------------------------------------------------------------
tableau_sca_global <- base_corrigee |>
  select(all_of(vars_sca)) |>
  tbl_summary(
    statistic = all_continuous() ~ "{mean} ({sd})",
    digits    = all_continuous() ~ 2,
    label     = libelles_sca,
    missing   = "no"
  ) |>
  add_n(col_label = "**Effectif**") |>
  modify_header(
    label  ~ "**Groupe alimentaire**",
    stat_0 ~ "**Moyenne (écart-type)**"
  ) |>
  bold_labels() |>
  modify_caption(
    "**Distribution de la fréquence de consommation des différentes denrées au cours des 7 derniers jours – Ensemble de l’échantillon**"
  )

# ------------------------------------------------------------------
# 📊 5-B. TABLEAU CROISÉ PAR NIVEAU D’ÉDUCATION DU CHEF
# ------------------------------------------------------------------
tableau_sca_edu <- base_corrigee |>
  select(all_of(vars_sca), hhh_edu) |>
  tbl_summary(
    by        = hhh_edu,
    statistic = all_continuous() ~ "{mean} ({sd})",
    digits    = all_continuous() ~ 2,
    label     = libelles_sca,
    missing   = "no"
  ) |>
  add_overall() |>
  add_n(col_label = "**Effectif**") |>
  modify_spanning_header(
    starts_with("stat_") ~ "**Niveau d'éducation du chef de ménage**"
  ) |>
  bold_labels() |>
  modify_caption(
    "**Distribution de la fréquence de consommation des différentes denrées au cours des 7 derniers jours, selon le niveau d'éducation du chef de ménage**"
  )

# ------------------------------------------------------------------
# 🖨️ 6. EXPORT EN FLEXSABLE (Word / PPT) – facultatif
# ------------------------------------------------------------------
tableau_sca_global_ft <- tableau_sca_global |> as_flex_table()
tableau_sca_edu_ft    <- tableau_sca_edu    |> as_flex_table()

# ------------------------------------------------------------------
# 👁️ 7. AFFICHAGE (RStudio / R Markdown)
# ------------------------------------------------------------------
tableau_sca_global_ft
tableau_sca_edu_ft






# ----------------------------------------------------------------
#  CALCUL DU SCORE DE CONSOMMATION ALIMENTAIRE (SCA)
# ----------------------------------------------------------------
#
# Norme de référence : 
# On s’appuie sur la méthodologie WFP (2018) – Food Consumption Score –  
# pour attribuer des *poids* relatifs à chaque groupe alimentaire.
# Poids standards WFP (somme = 16) :
#   Céréales/tubercules  = 2
#   Légumineuses         = 3
#   Produits laitiers    = 4
#   Viande/poisson/œufs  = 4
#   Légumes              = 1
#   Fruits               = 1
#   Huiles                = 0.5
#   Sucre                 = 0.5
#   Condiments            = 0 (pas inclus dans le score)
#
# Pour simplifier l’interprétation, nous *divisons* tous les poids par 2,
# de sorte que la somme des poids = 8 tout en conservant les proportions.
#
# Seuils de classification (WFP) :
#  – Pauvre      : SCA < 21
#  – Limite      : 21 ≤ SCA ≤ 35
#  – Acceptable  : SCA > 35
# On ajoute une seconde grille (plus stricte) 28/42 pour comparaison.

library(dplyr)
library(haven)     # read_dta(), as_factor
library(janitor)   # clean_names()
library(labelled)  # is.labelled()

# 1) Importer la base déjà corrigée et nettoyer les noms
base_corrigee <- read_dta("data/Base_Principale_corrigee.dta") %>%
  clean_names() %>%
  mutate(across(where(is.labelled), ~ as_factor(.x)))

# 2) Définir les poids *divisés par 2* (somme = 8)
weights <- c(
  fcs_stap  = 2/2,    # Céréales/tubercules
  fcs_pulse = 3/2,    # Légumineuses
  fcs_dairy = 4/2,    # Produits laitiers
  fcs_pr    = 4/2,    # Viande/poisson/œufs
  fcs_veg   = 1/2,    # Légumes
  fcs_fruit = 1/2,    # Fruits
  fcs_fat   = 0.5/2,  # Graisses / huiles
  fcs_sugar = 0.5/2,  # Sucre / sucreries
  fcs_cond  = 0       # Condiments / épices (non pondérés)
)
stopifnot(sum(weights) == 8)  # vérification rapide

# 3) Calcul du score pondéré pour chaque ménage
base_corrigee <- base_corrigee %>%
  rowwise() %>%
  mutate(
    sca_weighted = sum(
      c_across(names(weights)) * weights[names(weights)],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

# 4) Classification du SCA
base_corrigee <- base_corrigee %>%
  mutate(
    # classification WFP standard
    sca_cat_21_35 = case_when(
      sca_weighted < 21             ~ "Pauvre",
      sca_weighted <= 35            ~ "Limite",
      sca_weighted > 35             ~ "Acceptable"
    ),
    # classification alternative stricte
    sca_cat_28_42 = case_when(
      sca_weighted < 28             ~ "Pauvre",
      sca_weighted <= 42            ~ "Limite",
      sca_weighted > 42             ~ "Acceptable"
    )
  )

# 5) Tableau des poids utilisés
library(tibble)
poids_sca <- enframe(weights, name = "variable", value = "poids") %>%
  mutate(label = recode(variable,
                        fcs_stap  = "Céréales / tubercules",
                        fcs_pulse = "Légumineuses",
                        fcs_dairy = "Produits laitiers",
                        fcs_pr    = "Viande / poisson / œufs",
                        fcs_veg   = "Légumes",
                        fcs_fruit = "Fruits",
                        fcs_fat   = "Graisses / huiles",
                        fcs_sugar = "Sucre / sucreries",
                        fcs_cond  = "Condiments / épices"
  ))

# (Optionnel) visualiser ce petit tableau pour vérification
print(poids_sca)

# ----------------------------------------------------------------
# VISUALISATION DU SCORE DE CONSOMMATION ALIMENTAIRE (SCA)
# ----------------------------------------------------------------
library(ggplot2)

# 1) Histogramme de la distribution du SCA pondéré
ggplot(base_corrigee, aes(x = sca_weighted)) +
  geom_histogram(binwidth = 1, fill = "steelblue", color = "white", boundary = 0) +
  labs(
    title    = "Distribution du Score de Consommation Alimentaire pondéré",
    x        = "Score SCA (pondéré)",
    y        = "Nombre de ménages"
  ) +
  theme_minimal()

# 2) Répartition par catégorie (grille 21–35)
ggplot(base_corrigee, aes(x = sca_cat_21_35)) +
  geom_bar(fill = "coral", color = "white") +
  labs(
    title    = "Répartition des ménages par catégorie SCA (seuils 21/35)",
    x        = "Catégorie SCA",
    y        = "Effectif"
  ) +
  theme_minimal()

# 3) Boxplots du SCA pondéré selon le niveau d'éducation
ggplot(base_corrigee, aes(x = hhh_edu, y = sca_weighted)) +
  geom_boxplot(fill = "lightgreen") +
  labs(
    title    = "Score SCA pondéré selon le niveau d'éducation du chef de ménage",
    x        = "Niveau d'éducation",
    y        = "Score SCA (pondéré)"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))



# ----------------------------------------------------------------
# ▶️ Tableau de synthèse SCA avec gtsummary
# ----------------------------------------------------------------
# Objectif : fournir, pour l’ensemble de l’échantillon,
# - la moyenne (écart-type) du Score de Consommation Alimentaire pondéré
# - la répartition en effectifs (%) des catégories selon les seuils 21/35 et 28/42

library(dplyr)
library(gtsummary)

tableau_sca_summary <- base_corrigee %>%
  select(
    sca_weighted,    # Score SCA pondéré (jours * poids, somme des poids = 8)
    sca_cat_21_35,   # Catégorie standard (21/35)
    sca_cat_28_42    # Catégorie alternative (28/42)
  ) %>%
  tbl_summary(
    # type continu pour le score, catégoriel pour les classifications
    type      = list(sca_weighted ~ "continuous"),
    statistic = list(
      sca_weighted  ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits    = list(sca_weighted ~ 2),
    label     = list(
      sca_weighted  ~ "Score SCA pondéré",
      sca_cat_21_35 ~ "Catégorie SCA (21/35)",
      sca_cat_28_42 ~ "Catégorie SCA (28/42)"
    ),
    missing   = "no"
  ) %>%
  add_overall(       # ajoute une colonne « Global »
    col_label = "**Ensemble**"
  ) %>%
  modify_header(
    label  ~ "**Indicateur**",
    stat_0 ~ "**Ensemble**"
  ) %>%
  bold_labels()

# Affichage  
tableau_sca_summary


# ----------------------------------------------------------------
# ▶️ Tableau de synthèse SCA avec gtsummary (version globale)
# ----------------------------------------------------------------
# Objectif : 
#   - Moyenne (écart-type) du Score de Consommation Alimentaire pondéré
#   - Répartition en effectifs (%) des catégories selon les seuils 21/35 et 28/42

library(dplyr)
library(gtsummary)

tableau_sca_summary <- base_corrigee %>%
  select(
    sca_weighted,    # Score SCA pondéré (jours * poids, somme des poids = 8)
    sca_cat_21_35,   # Catégorie standard (21/35)
    sca_cat_28_42    # Catégorie alternative (28/42)
  ) %>%
  tbl_summary(
    # On précise les types : continu pour le score, catégoriel pour les classifications
    type      = list(sca_weighted ~ "continuous"),
    statistic = list(
      sca_weighted  ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    digits    = list(sca_weighted ~ 2),
    label     = list(
      sca_weighted  ~ "Score SCA pondéré",
      sca_cat_21_35 ~ "Catégorie SCA (21/35)",
      sca_cat_28_42 ~ "Catégorie SCA (28/42)"
    ),
    missing   = "no"  # on n’inclut pas les NA
  ) %>%
  # Renommer les en-têtes
  modify_header(
    label  ~ "**Indicateur**",
    stat_0 ~ "**Global**"
  ) %>%
  bold_labels()      # étiquettes en gras

# Affichage
tableau_sca_summary
 



# ----------------------------------------------------------------
#  INDICE RÉDUIT DES STRATÉGIES DE SURVIE (rCSI)
# ----------------------------------------------------------------
#
# Références méthodologiques :
# - WFP (2018), "Reduced Coping Strategies Index (rCSI) Guidelines"
#   https://docs.wfp.org/api/documents/WFP-0000072558/download/
#
# a) Variables composant le rCSI (5 stratégies de consommation)
#    • r_csi_less_qlty  : Relied on less preferred, less expensive food  
#    • r_csi_borrow     : Borrowed food or relied on help from friends/relatives  
#    • r_csi_meal_size  : Reduced portion size of meals at meal time  
#    • r_csi_meal_adult : Restricted consumption by adults for children  
#    • r_csi_meal_nb    : Reduced the number of meals eaten per day  
#
# b) Analyse descriptive des variables (effectifs & moyennes)
# c) Définition des poids : méthode WFP classique (somme originale = 7), 
#    puis multipliée par 3 → somme = 21 (pour respecter votre consigne)
#    Poids standards WFP : 
#      - r_csi_less_qlty  = 2  
#      - r_csi_borrow     = 2  
#      - r_csi_meal_size  = 1  
#      - r_csi_meal_adult = 1  
#      - r_csi_meal_nb    = 1  
#    Multipliés par 3 →  
#      - r_csi_less_qlty  = 6  
#      - r_csi_borrow     = 6  
#      - r_csi_meal_size  = 3  
#      - r_csi_meal_adult = 3  
#      - r_csi_meal_nb    = 3  
#    Somme des poids = 6+6+3+3+3 = 21
#
# ----------------------------------------------------------------
library(dplyr)
library(haven)       # read_dta(), as_factor()
library(janitor)     # clean_names()
library(labelled)    # is.labelled()
library(gtsummary)   # tbl_summary()
library(tibble)      # enframe(), tibble()

# 1) Import et nettoyage
base_corrigee <- read_dta("data/Base_Principale_corrigee.dta") %>%
  clean_names() %>%
  mutate(across(where(is.labelled), ~ as_factor(.x)))

# 2) Définir la liste des variables rCSI
vars_rcsi <- c(
  "r_csi_less_qlty",   # moins-prefered food
  "r_csi_borrow",      # emprunt nourriture
  "r_csi_meal_size",   # portion réduite
  "r_csi_meal_adult",  # adultes restreints
  "r_csi_meal_nb"      # nb. repas réduits
)

# 3) a) Analyse descriptive avec gtsummary
tableau_rcsi_desc <- base_corrigee %>%
  select(all_of(vars_rcsi)) %>%
  tbl_summary(
    type      = all_continuous() ~ "continuous",
    statistic = all_continuous() ~ "{mean} ({sd})", 
    digits    = all_continuous() ~ 2,
    label     = list(
      r_csi_less_qlty  ~ "Days relied on less preferred food",
      r_csi_borrow     ~ "Days borrowed food or help",
      r_csi_meal_size  ~ "Days reduced meal size",
      r_csi_meal_adult ~ "Days adults restricted for children",
      r_csi_meal_nb    ~ "Days number of meals reduced"
    ),
    missing   = "ifany"
  ) %>%
  add_n(col_label = "**Effectif**") %>%
  modify_header(
    label  ~ "**Stratégie**",
    stat_0 ~ "**Moyenne (écart-type)**"
  ) %>%
  bold_labels()

# 4) b & c) Définition des poids (somme = 21) et calcul du score rCSI
weights_rcsi <- c(
  r_csi_less_qlty  = 6,
  r_csi_borrow     = 6,
  r_csi_meal_size  = 3,
  r_csi_meal_adult = 3,
  r_csi_meal_nb    = 3
)
stopifnot(sum(weights_rcsi) == 21)  # vérif somme

# Tableau des poids pour reporting
poids_rcsi <- enframe(weights_rcsi, name = "variable", value = "poids") %>%
  mutate(label = recode(variable,
                        r_csi_less_qlty  = "Less preferred food",
                        r_csi_borrow     = "Borrowed food/help",
                        r_csi_meal_size  = "Reduced meal size",
                        r_csi_meal_adult = "Adults restricted",
                        r_csi_meal_nb    = "Meals number reduced"
  ))

# 5) Calcul de l'indice pondéré
base_corrigee <- base_corrigee %>%
  rowwise() %>%
  mutate(
    rcsi_score = sum(
      c_across(all_of(names(weights_rcsi))) * weights_rcsi[names(weights_rcsi)],
      na.rm = TRUE
    )
  ) %>%
  ungroup()

# (Optionnel) Afficher les résultats
print(tableau_rcsi_desc)
print(poids_rcsi)



# ----------------------------------------------------------------
# 4. STRATÉGIES D'ADAPTATION AUX MOYENS D'EXISTENCE (LhCSI-FS)
# ----------------------------------------------------------------
#
# Les indicateurs LhCSI-FS (Livelihood Coping Strategies – Food Security)
# mesurent les actions prises par les ménages pour faire face à un choc
# alimentaire. On distingue trois niveaux de gravité :
#  • Stress    : actions réversibles (ex : vendre épargne, emprunter)
#  • Crise     : actions plus structurelles (ex : vendre actifs productifs)
#  • Urgence   : actions dramatiques (ex : vendre la maison, mendicité)
#
# Références :
#   WFP (2020) LCS-FS Guidelines.

library(dplyr)      # « %>% », mutate, across…
library(haven)      # read_dta(), as_factor()
library(janitor)    # clean_names()
library(labelled)   # is.labelled()
library(gtsummary)  # tbl_summary(), add_n()…
library(sf)         # gestion des shapefiles pour carto
library(ggplot2)    # visualisation

# 1) Import et préparation
base_corrigee <- read_dta("data/Base_Principale_corrigee.dta") %>%
  clean_names() %>% 
  # transformer les variables STATA labelisées en facteurs R
  mutate(across(where(is.labelled), ~ as_factor(.x)))

# 2) Variables LhCSI-FS
lhcsi_vars <- c(
  "lh_csi_stress1",  # vendu actifs simples
  "lh_csi_stress2",  # dépensé épargne
  "lh_csi_stress3",  # envoyé membres vivre ailleurs
  "lh_csi_stress4",  # achats à crédit
  "lh_csi_crisis1",  # vendu actifs productifs
  "lh_csi_crisis2",  # réduit dépenses santé
  "lh_csi_crisis3",  # retrait des enfants de l'école
  "lh_csi_emergency1", # hypothéqué/vendu terre ou maison
  "lh_csi_emergency2", # mendicité/pillage
  "lh_csi_emergency3"  # activités illégales
)

# --- a) Analyse descriptive des stratégies ---
table_lhcsi_desc <- base_corrigee %>%
  select(all_of(lhcsi_vars)) %>%
  tbl_summary(
    type      = all_continuous() ~ "continuous",
    statistic = all_continuous() ~ "{mean} ({sd})",
    digits    = all_continuous() ~ 2,
    label     = list(
      lh_csi_stress1   ~ "Stress – vendu actifs simples",
      lh_csi_stress2   ~ "Stress – dépensé épargne",
      lh_csi_stress3   ~ "Stress – envoyé membres",
      lh_csi_stress4   ~ "Stress – achats à crédit",
      lh_csi_crisis1   ~ "Crise  – vendu actifs productifs",
      lh_csi_crisis2   ~ "Crise  – réduit dépenses santé",
      lh_csi_crisis3   ~ "Crise  – retrait enfants école",
      lh_csi_emergency1~ "Urgence – hypothèque/vente logement",
      lh_csi_emergency2~ "Urgence – mendicité/pillage",
      lh_csi_emergency3~ "Urgence – activités illégales"
    ),
    missing   = "no"
  ) %>%
  add_n(col_label = "**N ménages**") %>%
  modify_header(
    label  ~ "**Stratégie LhCSI**",
    stat_0 ~ "**Moyenne (±SD)**"
  ) %>%
  modify_caption(
    "**Tableau 4a – Fréquence moyenne d’adoption des stratégies LhCSI-FS (jours/7)**"
  ) %>%
  bold_labels()

# --- b) Classification des ménages par niveau de gravité ---
# On assigne à chaque ménage la gravité maximale qu’il a utilisée
base_corrigee <- base_corrigee %>%
  rowwise() %>%
  mutate(
    lhcsi_cat = case_when(
      c_across(starts_with("lh_csi_emergency")) %>% sum(na.rm = TRUE) > 0 ~ "Urgence",
      c_across(starts_with("lh_csi_crisis"   )) %>% sum(na.rm = TRUE) > 0 ~ "Crise",
      c_across(starts_with("lh_csi_stress"   )) %>% sum(na.rm = TRUE) > 0 ~ "Stress",
      TRUE                                                           ~ "Aucune"
    )
  ) %>%
  ungroup()

# Proportions par année (2022 vs 2023)
prop_lhcsi_year <- base_corrigee %>%
  filter(year %in% c(2022, 2023)) %>%
  count(year, lhcsi_cat) %>%
  group_by(year) %>%
  mutate(pct = n / sum(n) * 100)





# ----------------------------------------------------------------
# 4. STRATÉGIES D'ADAPTATION AUX MOYENS DE SUBSISTANCE (LhCSI-FS)
# ----------------------------------------------------------------
#
# Références :
# - Méthodologie WFP (2020), "LCS-FS Guidelines"
#   L'indicateur évalue les mécanismes utilisés par les ménages
#   pour s'adapter à des situations de pénurie alimentaire.
# - On utilise ici la version Food Security (LCS-FS), centrée
#   sur les stratégies en lien avec la sécurité alimentaire.
#

# 🔁 Chargement des packages utiles
library(dplyr)      # manipulation de données
library(haven)      # import de fichiers STATA
library(janitor)    # nettoyage des noms
library(labelled)   # transformation des labels STATA
library(gtsummary)  # tableau statistique descriptif

# 1️⃣ Importation de la base nettoyée + nettoyage des noms
base_corrigee <- read_dta("data/Base_Principale_corrigee.dta") %>%  # chargement de la base
  clean_names() %>%                                                 # noms propres (minuscules, _)
  mutate(across(where(is.labelled), ~ as_factor(.x)))               # labels STATA → facteurs lisibles

# 2️⃣ Définition des variables composant le LhCSI-FS
# Chaque variable indique combien de jours le ménage a utilisé une stratégie donnée (0 à 7)
lhcsi_vars <- c(
  "lh_csi_stress1",  # vendu actifs simples (stress)
  "lh_csi_stress2",  # dépensé épargne (stress)
  "lh_csi_stress3",  # envoyé membres vivre ailleurs (stress)
  "lh_csi_stress4",  # achats à crédit (stress)
  "lh_csi_crisis1",  # vendu actifs productifs (crise)
  "lh_csi_crisis2",  # réduit dépenses santé (crise)
  "lh_csi_crisis3",  # enfants retirés de l'école (crise)
  "lh_csi_emergency1", # vente maison / terrain (urgence)
  "lh_csi_emergency2", # mendicité ou pillage (urgence)
  "lh_csi_emergency3"  # activités illégales (urgence)
)

# 3️⃣ a) Analyse descriptive des fréquences d’utilisation de chaque stratégie
table_lhcsi_desc <- base_corrigee %>%
  select(all_of(lhcsi_vars)) %>%                    # sélection uniquement des variables LhCSI
  tbl_summary(                                       # création du tableau résumé
    type      = all_continuous() ~ "continuous",    # variables continues : nombre de jours
    statistic = all_continuous() ~ "{mean} ({sd})", # on affiche moyenne et écart-type
    digits    = all_continuous() ~ 2,               # deux décimales
    label     = list(                               # libellés compréhensibles pour chaque stratégie
      lh_csi_stress1    ~ "Stress – vendu actifs simples",
      lh_csi_stress2    ~ "Stress – dépensé épargne",
      lh_csi_stress3    ~ "Stress – envoyé membres ailleurs",
      lh_csi_stress4    ~ "Stress – achats à crédit",
      lh_csi_crisis1    ~ "Crise – vendu biens productifs",
      lh_csi_crisis2    ~ "Crise – réduit dépenses santé",
      lh_csi_crisis3    ~ "Crise – enfants retirés école",
      lh_csi_emergency1 ~ "Urgence – vendu maison / terrain",
      lh_csi_emergency2 ~ "Urgence – mendicité / pillage",
      lh_csi_emergency3 ~ "Urgence – activités illégales"
    ),
    missing = "no"                                   # on n'affiche pas les valeurs manquantes
  ) %>%
  add_n(col_label = "**N ménages**") %>%             # ajoute le nombre de non-NA par variable
  modify_header(                                     # noms des colonnes du tableau
    label  ~ "**Stratégie LhCSI**",
    stat_0 ~ "**Moyenne (±SD) jours/7**"
  ) %>%
  modify_caption(                                    # titre du tableau
    "**Tableau 4a – Fréquence moyenne d’adoption des stratégies LhCSI-FS (jours sur 7)**"
  ) %>%
  bold_labels()                                      # mettre les variables en gras

# 4️⃣ b) Création d'une variable qui catégorise chaque ménage selon la stratégie la plus grave utilisée
base_corrigee <- base_corrigee %>%
  rowwise() %>%
  mutate(
    lhcsi_cat = case_when(
      sum(c_across(starts_with("lh_csi_emergency")), na.rm = TRUE) > 0 ~ "Urgence",
      sum(c_across(starts_with("lh_csi_crisis")), na.rm = TRUE) > 0    ~ "Crise",
      sum(c_across(starts_with("lh_csi_stress")), na.rm = TRUE) > 0    ~ "Stress",
      TRUE                                                             ~ "Aucune"
    )
  ) %>%
  ungroup()

# Logique :
# → Si un ménage a utilisé au moins UNE stratégie d'urgence, il est classé en "Urgence"
# → Sinon s’il a utilisé au moins UNE stratégie de crise, il est classé en "Crise"
# → Sinon s’il a utilisé au moins UNE stratégie de stress, il est "Stress"
# → Sinon "Aucune"

# 5️⃣ c) Créer un tableau de répartition des niveaux LhCSI selon l’année
# Pour observer s'il y a eu une évolution entre 2022 et 2023
table_lhcsi_year <- base_corrigee %>%
  filter(year %in% c(2022, 2023)) %>%      # on garde uniquement 2022 et 2023
  select(year, lhcsi_cat) %>%             # on garde l'année et la nouvelle variable catégorielle
  tbl_summary(
    by        = year,                     # on compare par année
    type      = all_categorical() ~ "categorical",
    statistic = all_categorical() ~ "{n} ({p}%)", # on affiche effectif + %
    label     = list(
      lhcsi_cat ~ "Catégorie LhCSI"
    ),
    missing   = "no"
  ) %>%
  add_n(col_label = "**Total**") %>%
  modify_header(
    label   ~ "**Catégorie**",
    stat_1  ~ "**2022**",
    stat_2  ~ "**2023**"
  ) %>%
  modify_caption(
    "**Tableau 4b – Proportion de ménages par niveau LhCSI-FS en 2022 et 2023**"
  ) %>%
  bold_labels()

# 🔍 Affichage final des tableaux
table_lhcsi_desc   # résumé descriptif des fréquences
table_lhcsi_year   # répartition selon l’année


