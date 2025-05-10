#------------------------------------
#0-importation des libraries et base
#----------------------------------
# 1- Importation et manipulation de données
library(haven)        # Pour lire les fichiers et importer ls jeux de donnée
library(tidyverse)    # Inclut dplyr, ggplot2, tidyr, readr...
library(janitor)      # Pour nettoyer les noms de variables
library(gtsummary)
library(tidyr)
library(labelled)
library(ggplot2)
library(ggspatial)
library(sf)
#2- Cartographie et données spatiales
library(sf)           # Pour manipuler les shapefiles (géométries spatiales)
library(tmap)         # Pour créer des cartes thématiques
library(leaflet)      # Pour des cartes interactives

#3- Importation des jeux des  donnée
#-------------------------------------
base_Mad<-read_dta("./data/Base_MAD.dta")
base_prin<-read_dta("./data/Base_Principale.dta")

#---------------------------------------------
#I-Analyse de consistence des jeux de données
#--------------------------------------------


#I-1 Base_Mad
#------------

#I-1-1 Visualisation
#-------------------
str(base_Mad)
# Aperçu rapide des types
map_chr(base_Mad, typeof)


#visualisation des valeur manquantes  
#----------------------------------

#recodage des variable

#recodage de la variable sexe
base_Mad <- base_Mad %>%
  mutate(
    MAD_sex = factor(case_when(
      MAD_sex == 1 ~ "Homme",
      MAD_sex == 0 ~ "Femme",
      TRUE ~ NA_character_
    ), levels = c("Homme", "Femme"))
  )

# Fonction de recodage
recode_oui_non_ncp <- function(df) {
  df %>%
    mutate(across(
      .cols = where(~ all(na.omit(unique(.)) %in% c(0, 1, 888))),  
      .fns = ~ factor(case_when(
        . == 0 ~ "Oui",
        . == 1 ~ "Non",
        . == 888 ~ "NCP",
        TRUE ~ NA_character_
      ), levels = c("Oui", "Non", "NCP"))
    ))
}
#Elle identifie automatiquement toutes les colonnes du jeu de données qui ne contiennent que les modalités 0, 1, 888 (hors valeurs manquantes), puis les recode en facteurs labellisés avec des niveaux lisibles : "Oui", "Non" et "NCP".
base_Mad <- recode_oui_non_ncp(base_Mad)
# Compter les valeurs manquantes
base_Mad %>%
  summarise(across(everything(), ~sum(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "nb_manquants") %>%
  arrange(desc(nb_manquants))


#I-2 Base_prin
#------------
#I-1-1 Visualisation
#-------------------

str(base_prin)
# Aperçu rapide des types
map_chr(base_prin, typeof)

# Compter les valeurs manquantes

# 1. Calcul du taux de valeurs manquantes
taux_na <- base_prin %>%
  summarise(across(everything(), ~ mean(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "variable", values_to = "taux_na") %>%
  mutate(
    pourcentage_na = round(100 * taux_na, 1),
    statut = case_when(
      pourcentage_na <= 5 ~ "Pas d’opération",
      pourcentage_na <= 20 ~ "Nécessite une imputation",
      pourcentage_na <= 50 ~ "Imputation risquée",
      pourcentage_na > 50 ~ "À exclure"
    )
  )
tableau_statut <- taux_na %>% 
  tbl_summary(
    include = "statut",
    type = list(statut ~ "categorical"),
    statistic = list(all_categorical() ~ "{n} ({p}%)"),
    label = list(statut ~ "Statut des variables")
  ) %>%
  modify_header(
    stat_0 ~ "**Résumé (Effectif en %)**"
  ) %>% 
  modify_footnote(everything() ~ NA) %>% 
  bold_labels()

tableau_statut
# 1. Identifier les variables à imputer (5% < NA <= 20%)
vars_a_imputer <- taux_na %>% 
  filter(statut == "Nécessite une imputation") %>% 
  pull(variable)

# 2. Imputation par la médiane (moins sensible aux outliers)
base_imputee <- base_prin %>% 
  mutate(across(
    all_of(vars_a_imputer),
    ~ if_else(is.na(.), median(., na.rm = TRUE), .)
  ))

#----------------------------------------------
#II-Analyse des données et calcul d’indicateurs
#----------------------------------------------

#II-1. Ananlyse socio-démographiques pertinentes
#-----------------------------------------------
socio_vars <- base_imputee%>%
  select(
    HHHSex,            # Sexe du chef de ménage (1=Femme, 2=Homme)
    HHHAge,            # Âge du chef de ménage (en années)
    HHHEdu,            # Niveau d'éducation (1=Aucune à 5=Supérieur)
    HHSize,            # Taille totale du ménage
    ADMIN1Name,        # Région administrative
    HHSourceIncome     # Source de revenu principale
  ) %>%
  # Convertir les variables labellisées en facteurs
  mutate(across(where(is.labelled), as_factor))

# 2. Nettoyage des libellés ----
var_label(socio_vars) <- list(
  HHHSex = "Sexe du chef de ménage",
  HHHAge = "Âge (années)",
  HHHEdu = "Niveau d'éducation",
  HHSize = "Taille du ménage",
  ADMIN1Name = "Région",
  HHSourceIncome = "Source de revenu"
)
# 3. Tableau descriptif ajusté ----
tbl_socio <- socio_vars %>%
  tbl_summary(
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    label = list(
      HHHSex ~ "Sexe du chef",
      HHHAge ~ "Âge moyen (années)",
      HHHEdu ~ "Niveau d'éducation",
      HHSize ~ "Taille ménage",
      ADMIN1Name ~ "Région",
      HHSourceIncome ~ "Source revenu"
    ),
    missing = "no", # Masquer les NA car variables exclues
    digits = all_continuous() ~ 1
  ) %>%
  modify_caption("**Tableau 1 : Caractéristiques socio-démographiques (variables non-informatives exclues)**")
tbl_socio

# 4. Visualisations complémentaires ----

## Croisement éducation/sexe ----
educ_sex <- socio_vars %>%
  tbl_strata(
    strata = HHHSex,
    ~ tbl_summary(.x, include = HHHEdu),
    .header = "Sexe : **{strata}**"
  ) %>%
  modify_caption("**Niveau d'éducation par sexe du chef de ménage**")

educ_sex

#source de revenus par region
income_region <- socio_vars%>%
   tbl_cross(
     row = HHSourceIncome,
     col = ADMIN1Name,
     percent = "row"
   ) %>%
   modify_caption("**Sources de revenu principales par région**")
income_region

#Graphiques
#---------
# Distribution d'âge ----
age_dist <- ggplot(socio_vars, aes(x = HHHAge)) +
  geom_histogram(fill = "steelblue", bins = 20, alpha = 0.8) +
  geom_vline(aes(xintercept = mean(HHHAge, na.rm = TRUE)), 
             color = "red", linetype = "dashed") +
  labs(title = "Distribution de l'âge des chefs de ménage",
       subtitle = paste("Moyenne =", round(mean(socio_vars$HHHAge, na.rm = TRUE),1), "ans"),
       x = "Âge", y = "Nombre") 
print(age_dist)

#Répartition par sexe
sex_dist <- socio_vars %>%
  count(HHHSex) %>%
  mutate(pct = n/sum(n)) %>%
  ggplot(aes(x = HHHSex, y = pct, fill = HHHSex)) +
  geom_col() +
  geom_text(aes(label = scales::percent(pct)), vjust = -0.5) +
  scale_fill_manual(values = c("Femme" = "#f28e2b", "Homme" = "#4e79a7")) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Répartition par sexe", x = "", y = "") +
  theme_minimal() +
  theme(legend.position = "none")
print(sex_dist)

#Niveau d'éducation ----
educ_dist <- socio_vars %>%
  filter(!is.na(HHHEdu)) %>%
  ggplot(aes(x = fct_infreq(HHHEdu))) +
  geom_bar(fill = "#59a14f") +
  coord_flip() +
  labs(title = "Niveau d'éducation des chefs de ménage",
       x = "", y = "Nombre") +
  theme(axis.text.y = element_text(size = 8))
print(educ_dist)

# ---------------------------
# PARTIE II.2 : SCORE DE CONSOMMATION ALIMENTAIRE (SCA)
# ---------------------------

# A. Préparation des données ----
sca_data <- base_imputee %>%
  select(
    HDDSStapCer,    # Céréales
    HDDSStapRoot,   # Tubercules
    HDDSPulse,      # Légumineuses
    HDDSVegOrg,     # Légumes vitaminés
    HDDSVegGre,     # Légumes verts
    HDDSVegOth,     # Autres légumes
    HDDSFruitOrg,   # Fruits vitaminés
    HDDSFruitOth,   # Autres fruits
    HDDSPrMeatF,    # Viande
    HDDSPrFish,     # Poisson
    HDDSPrEgg,      # Œufs
    HDDSDairy,      # Produits laitiers
    HDDSSugar,      # Sucres
    HDDSFat,        # Matières grasses
    HDDSCond,       # Condiments
    ADMIN1Name,     # Région
    ADMIN2Name      # Département
  ) %>%
  mutate(across(where(is.labelled), as_factor))
# B. Analyse descriptive des composantes ----
tbl_sca_components <- sca_data %>%
  select(-ADMIN1Name, -ADMIN2Name) %>%
  tbl_summary(
    statistic = all_categorical() ~ "{n} ({p}%)",
    label = list(
      HDDSStapCer ~ "Céréales",
      HDDSStapRoot ~ "Tubercules",
      HDDSPulse ~ "Légumineuses",
      HDDSVegOrg ~ "Légumes vitaminés",
      HDDSVegGre ~ "Légumes verts",
      HDDSVegOth ~ "Autres légumes",
      HDDSFruitOrg ~ "Fruits vitaminés",
      HDDSFruitOth ~ "Autres fruits",
      HDDSPrMeatF ~ "Viande",
      HDDSPrFish ~ "Poisson",
      HDDSPrEgg ~ "Œufs",
      HDDSDairy ~ "Produits laitiers",
      HDDSSugar ~ "Sucres",
      HDDSFat ~ "Matières grasses",
      HDDSCond ~ "Condiments"
    ),
    digits = all_categorical() ~ 1
  ) %>%
  modify_header(label = "**Groupe alimentaire**") %>%
  modify_caption("**Tableau 1 : Consommation des groupes alimentaires (7 derniers jours)**")
tbl_sca_components
# C. Calcul du SCA ----
poids_sca <- c(
  HDDSStapCer = 2,
  HDDSStapRoot = 2,
  HDDSPulse = 3,
  HDDSVegOrg = 1,
  HDDSVegGre = 1,
  HDDSVegOth = 1,
  HDDSFruitOrg = 1,
  HDDSFruitOth = 1,
  HDDSPrMeatF = 4,
  HDDSPrFish = 4,
  HDDSPrEgg = 4,
  HDDSDairy = 4,
  HDDSSugar = 0.5,
  HDDSFat = 0.5,
  HDDSCond = 0
)

sca_data <- sca_data %>%
  mutate(
    SCA = across(names(poids_sca), ~.x == "Oui") %>%
      as.data.frame() %>%
      mutate(across(everything(), ~.x * poids_sca[cur_column()])) %>%
      rowSums(na.rm = TRUE)
  )

# Vérification des poids
tbl_poids <- tibble(
  Groupe = names(poids_sca),
  Poids = poids_sca
) %>%
  gt() %>%
  tab_header(title = "Pondérations SCA") %>%
  fmt_number(columns = Poids, decimals = 1) %>%
  grand_summary_rows(columns = Poids, fns = list(Total = ~sum(.)))

# D. Catégorisation SCA ----
sca_data <- sca_data %>%
  mutate(
    Cat_SCA = case_when(
      SCA < 21 ~ "Insuffisant",
      SCA >= 21 & SCA < 28 ~ "Limite",
      SCA >= 28 & SCA < 35 ~ "Acceptable",
      SCA >= 35 ~ "Bon"
    ) %>% factor(levels = c("Insuffisant", "Limite", "Acceptable", "Bon"))
  )

# E. Visualisations spatiales ----
# Préparation des données géographiques
regions <- sca_data %>%
  group_by(ADMIN1Name) %>%
  summarise(
    SCA_moyen = mean(SCA, na.rm = TRUE),
    .groups = "drop"
  )

# Carte choroplèthe régionale
carte_regions <- ggplot(regions) +
  geom_sf(aes(fill = SCA_moyen)) +
  scale_fill_viridis_c(
    name = "SCA moyen",
    option = "plasma",
    direction = -1
  ) +
  annotation_scale(location = "br") +
  labs(title = "Score de Consommation Alimentaire par région") +
  theme_void()

# Diagramme en barres par département
plot_departement <- sca_data %>%
  count(ADMIN2Name, Cat_SCA) %>%
  group_by(ADMIN2Name) %>%
  mutate(pct = n/sum(n)) %>%
  ggplot(aes(x = ADMIN2Name, y = pct, fill = Cat_SCA)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = scales::percent) +
  scale_fill_brewer(palette = "Set2") +
  labs(x = "", y = "Proportion", fill = "Catégorie SCA") +
  theme_minimal(base_size = 9)

# F. Résultats interactifs ----
# Tableau récapitulatif final
tbl_sca_final <- sca_data %>%
  select(SCA, Cat_SCA, ADMIN1Name) %>%
  tbl_summary(
    by = ADMIN1Name,
    statistic = list(
      SCA ~ "{mean} ({sd})",
      Cat_SCA ~ "{n} ({p}%)"
    ),
    digits = all_continuous() ~ 1,
    label = list(
      SCA ~ "Score moyen",
      Cat_SCA ~ "Répartition catégorielle"
    )
  ) %>%
  modify_header(label ~ "**Variable**") %>%
  bold_labels()
#visualisation
print(tbl_sca_components)
print(tbl_poids)
print(tbl_sca_final)
carte_regions
plot_departement

# -----------------------------------------------------
# PARTIE II.3 : indice réduit des stratégies de survie 
# ----------------------------------------------------
# Sélection des variables rCSI
rcsi_vars <- base_imputee%>%
  select(
    rCSILessQlty,    # N jours : Aliments moins préférés
    rCSIBorrow,      # N jours : Emprunt nourriture
    rCSIMealSize,    # N jours : Réduction portion
    rCSIMealAdult,   # N jours : Adultes sautent repas
    rCSIMealNb,      # N jours : Réduction nombre repas
    ADMIN1Name,      # Région
    ADMIN2Name       # Département
  )

# Tableau descriptif des stratégies
tbl_rcsi_components <- rcsi_vars %>%
  select(-ADMIN1Name, -ADMIN2Name) %>%
  tbl_summary(
    statistic = all_continuous() ~ "{mean} ({sd}) [min={min}; max={max}]",
    label = list(
      rCSILessQlty ~ "Aliments moins préférés",
      rCSIBorrow ~ "Emprunt nourriture",
      rCSIMealSize ~ "Réduction portion",
      rCSIMealAdult ~ "Adultes sautent repas",
      rCSIMealNb ~ "Réduction nombre repas"
    ),
    digits = all_continuous() ~ 1
  ) %>%
  modify_header(label = "**Stratégie**") %>%
  modify_caption("**Tableau 3 : Utilisation des stratégies de survie (7 derniers jours)**")

# Visualisation des fréquences
rcsi_plot <- rcsi_vars %>%
  pivot_longer(cols = -c(ADMIN1Name, ADMIN2Name)) %>%
  ggplot(aes(x = value, fill = name)) +
  geom_histogram(bins = 8, alpha = 0.7) +
  facet_wrap(~name, scales = "free", ncol = 2) +
  scale_fill_viridis_d(option = "magma") +
  labs(title = "Distribution des stratégies de survie",
       x = "Nombre de jours", y = "Nombre de ménages") +
  theme_minimal() +
  theme(legend.position = "none")

# Pondérations standard rCSI
poids_rcsi <- c(
  rCSILessQlty = 1,
  rCSIBorrow = 2,
  rCSIMealSize = 1,
  rCSIMealAdult = 3,
  rCSIMealNb = 1
)

# Calcul de l'indice
rcsi_data <- rcsi_vars %>%
  mutate(
    rCSI = rCSILessQlty*1 + rCSIBorrow*2 + rCSIMealSize*1 + 
      rCSIMealAdult*3 + rCSIMealNb*1,
    
    # Catégorisation selon seuils FAO
    Severite = case_when(
      rCSI == 0 ~ "Aucune",
      rCSI >= 1 & rCSI <= 3 ~ "Stress léger",
      rCSI >= 4 & rCSI <= 18 ~ "Stress modéré",
      rCSI > 18 ~ "Stress sévère"
    ) %>% factor(levels = c("Aucune", "Stress léger", "Stress modéré", "Stress sévère"))
  )

#Table de pondération
tbl_poids_rcsi <- tibble(
  Stratégie = names(poids_rcsi),
  Pondération = poids_rcsi,
  Description = c(
    "Compter sur des aliments moins préférés",
    "Emprunter de la nourriture ou compter sur l'aide",
    "Réduire la taille des portions",
    "Restreindre la consommation des adultes",
    "Réduire le nombre de repas"
  )
) %>%
  gt() %>%
  tab_header(title = "Pondérations rCSI") %>%
  fmt_integer(columns = Pondération) %>%
  cols_width(Description ~ px(300))


#visualisation
# Répartition des catégories
rcsi_cat_plot <- rcsi_data %>%
  count(Severite) %>%
  mutate(pct = n/sum(n)) %>%
  ggplot(aes(x = Severite, y = pct, fill = Severite)) +
  geom_col() +
  geom_text(aes(label = scales::percent(pct)), vjust = -0.5) +
  scale_fill_brewer(palette = "Reds", direction = -1) +
  scale_y_continuous(labels = scales::percent) +
  labs(title = "Répartition des ménages par niveau de stress", 
       x = "", y = "") +
  theme_minimal()

# Carte choroplèthe par région
rcsi_map <- rcsi_data %>%
  group_by(ADMIN1Name) %>%
  summarise(rCSI_moyen = mean(rCSI, na.rm = TRUE)) %>%
  ggplot(aes(fill = rCSI_moyen)) +
  geom_sf() +  # Nécessite un fichier shapefile des régions
  scale_fill_gradientn(
    colours = c("#ffffcc", "#fd8d3c", "#800026"),
    name = "Score rCSI moyen"
  ) +
  labs(title = "Stress alimentaire par région") +
  theme_void()

# Affichage des résultats
print(tbl_rcsi_components)
print(tbl_poids_rcsi)
print(rcsi_plot)
print(rcsi_cat_plot)
