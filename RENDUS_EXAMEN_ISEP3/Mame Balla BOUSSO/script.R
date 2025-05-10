#  I : Analyse de consistence des bases de données
# Chargement des packages
library(haven)
library(tidyverse)
library(janitor)      # Pour nettoyer les noms de variables
library(gtsummary)    # Pour les tableaux
library(labelled)     # Pour gérer les variables avec labels
library(naniar)       # Pour explorer les valeurs manquantes

# Importation des bases des bases

Base_MAD <- read_dta("Data/Base_MAD.dta")
Base_Principale <- read_dta("Data/Base_Principale.dta")

# Nettoyage des noms de colonnes

Base_Principale <- Base_Principale %>% clean_names()
Base_MAD <- Base_MAD %>% clean_names()

# Dimensions
dim(Base_Principale)  # Nombre de lignes et colonnes
dim(Base_MAD)

# Un aperçu des données
glimpse(Base_Principale)
glimpse(Base_MAD)



# Vérification de doublons sur l'indentification des ménages

Base_Principale %>%
  count(id) %>%
  filter(n > 1)

"Chaque identifiant dans la base Base_Principale est unique "

Base_MAD %>%
  count(id) %>%
  filter(n > 1)

" Nous avons examiné la variable id dans chaque base afin d’identifier d’éventuels doublons :

Dans Base_Principale, chaque identifiant est unique. Aucune duplication n’a été détectée (n = 0 pour tous les id).

En revanche, Base_MAD contient plusieurs doublons d’identifiants. Par exemple, l'identifiant '1050' est présent 3 fois. De plus, 9 lignes ont un identifiant vide ('')

"





# Analyse des valeurs manquantes

Base_Principale %>% 
  summarise(across(everything(), ~ mean(is.na(.))*100)) %>% 
  pivot_longer(everything(), names_to = "variable", values_to = "pct_na") %>%
  filter(pct_na > 0) %>%
  arrange(desc(pct_na)) %>%
  head(10)  # Les 10 variables avec le plus de valeurs manquantes



# Analyse des valeurs manquantes
Base_MAD %>% 
  summarise(across(everything(), ~ mean(is.na(.))*100)) %>% 
  pivot_longer(everything(), names_to = "variable", values_to = "pct_na") %>%
  filter(pct_na > 0) %>%
  arrange(desc(pct_na)) %>%
  head(10)  # Les 10 variables avec le plus de valeurs manquantes













# Vérification de la cohérence dans la variables age

Base_Principale %>%
  mutate(total_age_sex = hh_size05m + hh_size23m + hh_size59m + hh_size5114m +
           hh_size1549m + hh_size5064m + hh_size65above_m +
           hh_size05f + hh_size23f + hh_size59f + hh_size5114f +
           hh_size1549f + hh_size5064f + hh_size65above_f) %>%
  summarise(prop_coherent = mean(total_age_sex == hh_size, na.rm = TRUE))

" La proportion prop_coherent est égale à 1. Cela signifie que dans tous les cas de la
base_principale, la somme des tailles de ménage par tranche d'âge et sexe est cohérente 
avec la taille totale du ménage. Aucun ménage ne présente d'incohérence dans ce calcul."




### Analyse socio-démographique des ménages


Base_Principale_labelled <- Base_Principale %>% 
  haven::as_factor() 

Base_Principale_labelled %>%
  select(hhh_sex, hhh_age, hh_size, hhh_edu, hh_source_income) %>%
  clean_names() %>%
  tbl_summary(
    statistic = list(
      all_continuous() ~ "{mean} ({sd})",
      all_categorical() ~ "{n} ({p}%)"
    ),
    label = list(
      hhh_sex = "Sexe du chef de ménage",
      hhh_age = "Âge du chef de ménage",
      hh_size = "Taille du ménage",
      hhh_edu = "Niveau d\u2019\u00e9ducation du chef de ménage",
      hh_source_income = "Source principale de revenu du ménage"
    ),
    missing = "ifany"
  ) 


"
Le tableau présente des caractéristiques sociodémographiques des ménages. Les chefs de ménage sont majoritairement des hommes (56 %, soit 5 012 individus), contre 44 % de femmes (3 938 individus), reflétant des normes culturelles où les hommes sont plus souvent désignés comme chefs de famille. L’âge moyen du chef de ménage est de 43 ans (avec un écart-type de 13 ans), indiquant une population en âge d’assumer des responsabilités économiques et familiales. La taille moyenne des ménages est de 7,55 personnes, avec un écart-type élevé (12,90), suggérant une grande variabilité, allant de petits noyaux familiaux à des familles étendues nombreuses, typique des sociétés rurales.

En matière d’éducation, les chefs de ménage ont principalement un faible niveau de formation : 31 % n’ont aucune éducation (1 827 individus), tandis que 62 % (3 684) sont alphabétisés ou ont une éducation coranique. Seulement 4,5 % ont un niveau primaire, 2,1 % secondaire, et 0,4 % supérieur, soulignant des obstacles structurels à l’accès à l’éducation formelle. Cependant, 3 024 cas n’ont pas de données renseignées, ce qui limite l’interprétation.

Concernant les sources de revenu, l’agriculture vivrière ou de rente domine (50 % des ménages), suivie par le maraîchage (11 %), le travail journalier (9 %) et les aides ou transferts d’argent (6,1 %). Les autres activités, comme l’élevage, la pêche ou l’artisanat, sont marginales (moins de 5 % chacune). Les données manquantes sont importantes (7 238 cas non renseignés, soit environ 80 % du total), ce qui invite à la prudence dans l’analyse.

"

#  2)	Score de consommation alimentaire (SCA)


"
L'analyse des variables composant le Score de Consommation Alimentaire (SCA) repose sur la fréquence de consommation de différents groupes alimentaires au sein des ménages, mesurée sur une période de 7 jours. Cinq principaux groupes alimentaires ont été identifiés, chacun ayant un poids attribué en fonction de son importance nutritionnelle dans le calcul du SCA.

Le premier groupe, les céréales, racines et tubercules (représenté par la variable fcs_stap), inclut des aliments essentiels à l'alimentation de base dans de nombreuses régions. Ce groupe se voit attribuer un poids de 2, reflétant son rôle fondamental dans l'alimentation, mais avec une valeur nutritionnelle moins élevée que d'autres groupes plus riches en protéines et en micronutriments.

Le deuxième groupe est constitué des légumineuses (variable fcs_pulse), qui comprennent des aliments comme les haricots, les pois et les lentilles. Les légumineuses, riches en protéines végétales et en fibres, ont un poids plus élevé de 3, soulignant leur importance pour l'apport nutritionnel.

Les produits laitiers, représentés par la variable fcs_dairy, comprennent des produits tels que le lait, le fromage et le yaourt, qui sont des sources importantes de calcium et de protéines. Ce groupe est attribué un poids de 4, ce qui reflète sa haute valeur nutritionnelle, surtout en termes de santé osseuse et de développement musculaire.

Le groupe suivant regroupe les viandes, poissons et œufs (combinant les variables fcs_pr_meat_f, fcs_pr_meat_o, fcs_pr_fish et fcs_pr_egg), qui représentent des sources majeures de protéines animales et d'acides gras essentiels. L'agrégation de ces variables dans un seul groupe est attribuée un poids total de 4, soulignant l'importance de ces aliments dans l'alimentation équilibrée, notamment pour les enfants et les personnes âgées.

Enfin, les légumes (variable fcs_veg), qui incluent aussi bien les légumes frais que cuits, sont essentiels pour leur teneur en vitamines et minéraux, ainsi que pour leur rôle dans la régulation de l'alimentation. Ce groupe se voit attribuer un poids de 1, ce qui reflète son importance nutritionnelle bien qu'il soit souvent consommé en plus petites quantités que les autres groupes alimentaires.

Le calcul du Score de Consommation Alimentaire (SCA) consiste à multiplier la fréquence de consommation de chaque groupe alimentaire par son poids respectif. La somme de ces valeurs pondérées donne un score global, qui reflète la diversité alimentaire et l'équilibre nutritionnel du ménage au cours des sept derniers jours. Ce score permet de mieux comprendre les habitudes alimentaires des ménages et de les évaluer par rapport à des standards de sécurité alimentaire et de nutrition.


"

# Attribution de poids 

"
Les poids attribués à chaque groupe alimentaire dans le calcul du Score de Consommation Alimentaire (SCA) sont basés sur leur importance nutritionnelle et leur contribution à un régime alimentaire équilibré. En accord avec les recommandations de l'OMS :

Les céréales sont la base énergétique de l'alimentation (Poids = 3).

Les légumineuses apportent une alternative de qualité pour les protéines végétales (Poids = 2).

Les produits laitiers jouent un rôle clé dans la santé osseuse et la fourniture de nutriments essentiels (Poids = 4).

Les viandes, poissons et œufs sont essentiels pour des protéines de haute qualité et des micronutriments cruciaux (Poids = 5).

Les légumes fournissent des micronutriments et des fibres importantes pour la prévention des maladies (Poids = 2).

Les poids attribués à chaque groupe alimentaire dans le SCA sont donc un reflet de leur rôle dans une alimentation saine et équilibrée, en mettant l'accent sur la diversité des apports nutritionnels.



"

Base_Principale <- Base_Principale %>%
  mutate(
    SCA = (fcs_stap * 3) +  # Poids  pour les céréales
      (fcs_pulse * 2) +  # Poids pour les légumineuses
      (fcs_dairy * 4) +  # Poids pour les produits laitiers
      ((fcs_pr_meat_f + fcs_pr_meat_o + fcs_pr_fish + fcs_pr_egg) * 5) +  # Poids modifié pour la viande, poisson et œufs
      (fcs_veg * 2)  # Poids pour les légumes
  )

# Affichage du score
View(Base_Principale$SCA)

# 2) tableau donnant ce scor


library(tibble)

tribble(
  ~"Groupe alimentaire",         ~"Variables",                                         ~"Poids",
  "Céréales, racines, tubercules", "fcs_stap",                                           3,
  "Légumineuses",                 "fcs_pulse",                                          2,
  "Produits laitiers",           "fcs_dairy",                                          4,
  "Viandes, poisson, œufs",      "fcs_pr_meat_f + fcs_pr_meat_o + fcs_pr_fish + fcs_pr_egg", 5,
  "Légumes",                     "fcs_veg",                                            2
)

# d)	Categoriser le SCA selon les seuil 21/35 et 28/42
Base_Principale <- Base_Principale %>%
  mutate(
    SCA_cat_21_35 = case_when(
      SCA < 3 ~ "Faible",
      SCA >= 3 & SCA < 5 ~ "Limite",
      SCA >= 5 ~ "Acceptable"
    ),
    SCA_cat_28_42 = case_when(
      SCA < 4 ~ "Faible",
      SCA >= 4 & SCA < 6 ~ "Limite",
      SCA >= 6 ~ "Acceptable"
    )
  )

View(Base_Principale)
# Charger les librairies
library(sf)
library(rgdal)
library(tmap)
library(leaflet)

# Charger le shapefile (exemple : "map_senegal.shp")
shapefile_path <- "Data/shapefile"  # Ton répertoire contenant les shapefiles

# Charger un shapefile de niveau 1 (régions) par exemple
shapefile_adm1 <- st_read("Data/shapefile/tcd_admbnda_adm1_20250212_AB.shp")

library(dplyr)

# Fusionner les données de consommation alimentaire avec le shapefile en utilisant la bonne clé
shapefile_adm1_data <- shapefile_adm1 %>%
  left_join(Base_Principale, by = c("ADM1_FR" = "admin1name"))  # Remplace "region" par le nom de ta colonne dans data_region

shapefile_adm2 <- st_read("Data/shapefile/tcd_admbnda_adm2_20250212_AB.shp")



# Fusionner les données de consommation alimentaire avec le shapefile en utilisant la bonne clé
shapefile_adm2_data <- shapefile_adm2 %>%
  left_join(Base_Principale, by = c("ADM2_FR" = "admin2name"))  # Remplace "region" par le nom de ta colonne dans data_region






# Créer la carte en utilisant ggplot2
ggplot(shapefile_adm1_data) +
  geom_sf(aes(fill = SCA)) +  # Remplace "SCA" par la variable que tu veux afficher
  scale_fill_viridis_c(option = "C", na.value = "gray") +  # Choisir une palette de couleurs
  labs(title = "Score de Consommation Alimentaire (SCA) par région",
       fill = "SCA") +
  theme_minimal() +
  theme(legend.position = "right")



library(ggplot2)
library(sf)

# Créer la carte en utilisant ggplot2
ggplot(shapefile_adm2_data) +
  geom_sf(aes(fill = SCA)) +  # Remplace "SCA" par la variable que tu veux afficher
  scale_fill_viridis_c(option = "C", na.value = "gray") +  # Choisir une palette de couleurs
  labs(title = "Score de Consommation Alimentaire (SCA) par région",
       fill = "SCA") +
  theme_minimal() +
  theme(legend.position = "right")




library(dplyr)
library(gtsummary)

# Liste des variables du rCSI
vars_rcsi <- paste0("lh_csi_", c("stress1", "stress2", "stress3", "stress4",
                                 "crisis1", "crisis2", "crisis3",
                                 "emergency1", "emergency2", "emergency3"))

library(dplyr)
library(gtsummary)

# Sélection automatique des variables qui commencent par "lh_csi_"
vars_rcsi <- Base_Principale %>% 
  select(starts_with("lh_csi_")) %>% 
  names()

Base_Principale_labelled1 <- Base_Principale %>% 
  haven::as_factor()
# Analyse descriptive
Base_Principale_labelled1 %>%
  select(all_of(vars_rcsi)) %>%
  tbl_summary(statistic = list(all_continuous() ~ "{mean} ({sd})"),
              digits = all_continuous() ~ 1,
              missing = "no") %>%
  bold_labels()



poids_rcsi <- tibble(
  Variable = vars_rcsi,
  Poids = c(rep(1, 4), rep(2, 3), rep(3, 3))  # ajusté selon l'ordre attendu
)
# Fusion et calcul
data_rcsi <- Base_Principale %>%
  rowwise() %>%
  mutate(rCSI = sum(c_across(all_of(poids_rcsi$Variable)) * poids_rcsi$Poids, na.rm = TRUE)) %>%
  ungroup()





library(flextable)

# Ajout des noms stratégiques (si tu veux)
rcsi_weights <- poids_rcsi %>%
  mutate(Stratégie = c("Stress1", "Stress2", "Stress3", "Stress4",
                       "Crisis1", "Crisis2", "Crisis3",
                       "Emergency1", "Emergency2", "Emergency3")) %>%
  select(Stratégie, Variable, Poids)

flextable(rcsi_weights) %>%
  set_caption("Poids attribués aux variables pour le calcul du rCSI (somme = 21)") %>%
  theme_zebra() %>%
  align(align = "center", part = "all") %>%
  bold(part = "header") %>%
  fontsize(size = 10) %>%
  autofit()

glimpse(Base_Principale)













# Liste des variables par catégorie
stress_vars <- c("lh_csi_stress1", "lh_csi_stress2", "lh_csi_stress3", "lh_csi_stress4")
crisis_vars <- c("lh_csi_crisis1", "lh_csi_crisis2", "lh_csi_crisis3")
emergency_vars <- c("lh_csi_emergency1", "lh_csi_emergency2", "lh_csi_emergency3")

# Nettoyage des labels éventuels
Base_Principale <- Base_Principale %>%
  mutate(across(c(stress_vars, crisis_vars, emergency_vars), haven::zap_labels))

# Création d’une variable pour chaque niveau de stratégie
# Création des indicateurs logiques pour chaque ménage
Base_Principale <- Base_Principale %>%
  mutate(
    stress = if_any(all_of(stress_vars), ~ .x == 3),
    crisis = if_any(all_of(crisis_vars), ~ .x == 3),
    emergency = if_any(all_of(emergency_vars), ~ .x == 3)
  )

# Résumé des proportions par année
prop_severite <- Base_Principale %>%
  group_by(year) %>%
  summarise(
    stress = mean(stress, na.rm = TRUE),
    crisis = mean(crisis, na.rm = TRUE),
    emergency = mean(emergency, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  pivot_longer(cols = -year, names_to = "niveau", values_to = "proportion") %>%
  mutate(proportion = round(proportion * 100, 1)) # en pourcentage

# Affichage du tableau
print(prop_severite)



library(ggplot2)

# Graphique en barres des proportions par année et par niveau de sévérité
ggplot(prop_severite, aes(x = niveau, y = proportion, fill = niveau)) +
  geom_col(position = "dodge") +
  facet_wrap(~ year) +
  labs(
    title = "Proportion de ménages selon le type de stratégie d’adaptation (2022-2023)",
    x = "Niveau de sévérité",
    y = "Proportion (%)",
    fill = "Niveau"
  ) +
  scale_fill_manual(
    values = c("stress" = "#FBC02D", "crisis" = "#E64A19", "emergency" = "#C62828"),
    labels = c("Stress", "Crise", "Urgence")
  ) +
  theme_minimal(base_size = 13)
















# Calcul de la stratégie dominante par région
region_dominante <- Base_principale %>%
  group_by(region) %>%
  filter(!is.na(strategie_dominante)) %>%
  count(strategie_dominante) %>%
  slice_max(order_by = n, n = 1, with_ties = FALSE) %>%
  ungroup()

# Importer shapefile des régions
# shapefile avec une colonne ADM1_FR (noms des régions)
shp <- st_read("chemin/vers/le/shapefile/regions.shp")

# Fusion des données
shp_joined <- shapefile_adm1 %>%
  left_join(region_dominante, by = c("ADM1_FR" = "region"))

# Carte
ggplot(shp_joined) +
  geom_sf(aes(fill = strategie_dominante)) +
  scale_fill_manual(values = c("Aucune" = "grey80", "Stress" = "#a1d99b", "Crise" = "#fdae6b", "Urgence" = "#de2d26")) +
  labs(
    title = "Stratégie dominante par région",
    fill = "Catégorie"
  ) +
  theme_minimal()


