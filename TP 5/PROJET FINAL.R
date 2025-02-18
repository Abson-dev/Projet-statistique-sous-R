## PROJET STATISTIQUE AVEC R 
#============================================================================================#
#     ENSAE Pierre NDIAYE de Dakar ISE1-Cycle long 2024-2025                                 #
#     COURS DE Projet statistique avec R  avec M.Aboubacar HEMA                              #
#                           Travaux Pratiques N°4                                            #
#                                                                                            #
#    Groupe : Logiciel R                                                                     #
#    Pays : Burkina Faso et Niger                                                            #                 #
#    Membres : Fogwoung Djoufack Sarah-Laure, SENE Malick, Niass Ahmadou,  Celina Nguemfouo  #
#                                                                                            #
#============================================================================================#

#                   =====================  CONSIGNE  =====================
# Ce projet consiste à faire correspondre les codes ADM3_PCODE de chaque commune des pays Burkina Faso et Niger entre deux bases de données :
    # Base EHCVM : Données sur les ménages.Cette base contient des informations détaillées sur les conditions de vie, les revenus, et d'autres aspects socio-économiques des ménages.
    # Base HDX : Données avec les codes ADM3_PCODE.Données administratives avec les codes ADM3_PCODE. Cette base est souvent utilisée pour le suivi humanitaire et contient des informations géographiques et administratives sur les communes.
# Le problème principal est que les noms des communes ne sont pas toujours écrits de la même façon dans les deux bases. Pour résoudre cela, il faut regarder aux niveaux département et région afin de trouver les correspondances exactes.
# L'objectif est de fusionner les deux bases de données en s'assurant que les codes ADM3_PCODE de chaque commune soient bien alignés.


### A ENLEVER SUR LA VERSION FINALE 
setwd("E:/ISEP 2/MON DOSSIER/APPRENTISSAGE DES VACANCES/ISEP3/ME _ SEMESTRE 2/PROJET STATISTIQUE SOUS R ET PYTHON/TP4")

# STEP 1: IMPORTATION DES PACKAGES 

library(haven)    # Pour lire le fichier Stata
library(readxl)   # Pour lire le fichier Excel
library(dplyr)    # Pour la manipulation des données
library(stringr)  # Pour manipuler les chaînes de caractères
library(sf) # pour la gestion des données spatiales 
library(tidyverse) # Pour la manipulation, la visualisation et l'analyse des données
library(stringi) # Version plus complete de stringr

# =====================  STEP 2 : FOR NIGER  ===================== #
# === 2-a CHARGEMENT DES BASES DE DONNÉES === 

ehcvm_raw <- haven::read_dta("BASE DE DONNEES/s00_me_ner2021.dta")  # Chargement de la base de données EHCVM (format Stata)
hdx_raw <- readxl::read_excel("BASE DE DONNEES/ner_admgz_ignn_20230720.xlsx") # Chargement de la base de données HDX (format Excel)

# === 2-b TRAITEMENT DES COMMUNES DANS LA BASE EHCVM ===
ehcvm <- ehcvm_raw %>%
  dplyr::mutate(
    commune_label = as_factor(s00q03),  # Conversion des codes en labels de la variable commune
    commune_clean = commune_label |>
      # 1) mettre en minuscules
      stringr::str_to_lower() |>
      # 2) suppression des accents 
      (\(x) iconv(x, to = "ASCII//TRANSLIT"))() |>
      # 3) suppression des apostrophes
      stringr::str_replace_all("'", "") |>
      # 4) supprimer autres caractères non alphanumériques (on conserve les espaces)
      stringr::str_replace_all("[^[:alnum:] ]", " ") |>
      # 5) suppression des espaces en début et en fin en début / fin
      stringr::str_trim() |>
      # 6) corrections spécifiques "arrondissement" et chiffres arabes -> romains
      stringr::str_replace_all("\\barrondissement\\b", "") |>
      stringr::str_replace_all("\\b1\\b", "i") |>
      stringr::str_replace_all("\\b2\\b", "ii") |>
      stringr::str_replace_all("\\b3\\b", "iii") |>
      stringr::str_replace_all("\\b4\\b", "iv") |>
      stringr::str_replace_all("\\b5\\b", "v") |>
      # 7) supprimer espaces multiples créés par les remplacements ci-dessus
      stringr::str_squish()
  )

# === 2-c CORRECTION ET TRAITEMENT DES COMMUNES DANS LA BASE HDX ===
hdx <- hdx_raw %>%
  dplyr::mutate(
    # On modifie ADM3_FR selon ADM1_FR et les cas particuliers identifiés.
    ADM3_FR = dplyr::case_when(
      # Cas 1 : "Tibiri" dans ADM3_FR et "Dosso" dans ADM1_FR => "Tibiri Doutchi"
      ADM3_FR == "Tibiri" & ADM1_FR == "Dosso" ~ "Tibiri Doutchi",
      
      # Cas 2 : "Tibiri" dans ADM3_FR et "Maradi" dans ADM1_FR => "Tibiri Maradi"
      ADM3_FR == "Tibiri" & ADM1_FR == "Maradi" ~ "Tibiri Maradi",
      
      # Cas 3 : "Gangara" dans ADM3_FR et "Maradi" dans ADM1_FR => "Gangara Gazaoua"
      ADM3_FR == "Gangara" & ADM1_FR == "Maradi" ~ "Gangara Gazaoua",
      
      # Cas 4 : "Gangara" dans ADM3_FR et "Zinder" dans ADM1_FR => "Gangara Tanout"
      ADM3_FR == "Gangara" & ADM1_FR == "Zinder" ~ "Gangara Tanout",
      
      # Laisser inchangé si aucune correspondance n'est faite
      TRUE ~ ADM3_FR
    ),
    
    # Création de la colonne corrigée commune_clean
    commune_clean = ADM3_FR |>
      # 1) Mettre en minuscules
      stringr::str_to_lower() |>
      # 2) Suppression des accents 
      (\(x) iconv(x, to = "ASCII//TRANSLIT"))() |>
      # 3) Suppression des apostrophes
      stringr::str_replace_all("'", "") |>
      # 4) Suppression des caractères non alphanumériques (on conserve les espaces)
      stringr::str_replace_all("[^[:alnum:] ]", " ") |>
      # 5) Suppression des espaces en début et en fin
      stringr::str_trim() |>
      # 6) Suppression des espaces multiples
      stringr::str_squish()
  )

# === 2-d Jointure des bases : on conserve toutes les communes de l'EHCVM
# Jointure des bases avec left_join (package dplyr)
ehcvm_hdx_merged <- dplyr::left_join(ehcvm, hdx, by = "commune_clean")

# === 2-e Vérification des communes non appariées ===
# Filtrage et affichage des non appariées avec dplyr
non_matchees <- dplyr::filter(ehcvm_hdx_merged, is.na(ADM3_FR)) %>% # Filtrer les lignes sans correspondance
  dplyr::distinct(s00q03, commune_clean) # Affiche les codes et noms non appariés

non_matchees # Affiche les communes non matchées et on verra que toutes les communes sont matchées

# =====================  STEP 3 : FOR BURKINA FASO  ===================== #

# === 3-a CHARGEMENT DES BASES DE DONNÉES === 

ehcvm_raw <- haven::read_dta("BASE DE DONNEES/s00_me_bfa2021.dta") # Chargement de la base de données EHCVM (format Stata)
shape_raw <- readxl::read_excel("BASE DE DONNEES/bfa_adminboundaries_tabulardata.xlsx", sheet = "ADM3") # Chargement de la base de données HDX (format Excel)

# === 3-b CORRECTION DES ERREURS D'ORTHOGRAPHE ===
# Fonction pour le nettoyage
correction_map <- data.frame(
  commune_label = c("Zeguedeguin","Bondigui","Absouya",
                    "Bondokuy", "Bomborokuy", "Bittou", "Bokin", "Boudry", "Bobo Dioulasso-Konsa", 
                    "Bobo Dioulasso-Dô", "Arbole", "Dapelogo", "Dissin", "Fada N'gourma", "Gounghin", 
                    "Kokoloko", "Gourcy", "La-Todin", "Karankasso-Vigue", "Sanga", "Meguet", 
                    "Soaw", "Samorogouan", "Sabce", "Tanghin Dassouri", "Oury", "Cassou",
                    "Arrondissement 1", "Arrondissement 2", "Arrondissement 3", "Arrondissement 4",
                    "Arrondissement 5", "Arrondissement 6", "Arrondissement 7", "Arrondissement 8",
                    "Arrondissement 9", "Arrondissement 10", "Arrondissement 11", "Arrondissement 12",
                    "Arrondissement N 1", "Arrondissement N 2", "Arrondissement N 3", "Arrondissement N 4",
                    "Arrondissement N 5", "Arrondissement N 6", "Arrondissement N 7"),
  corrected_name = c("Senguènèga","Bondokui","Ambsouya",
                     "Bondokui", "Bomborokui", "Bitou", "Boken", "Boudri", "Bobo-Dioulasso", 
                     "Bobo-Dioulasso", "Arbollé", "Dapeolgo", "Dissihn", "Fada Ngourma", "Gounguen", 
                     "Kokologo", "Goursi", "La-Toden", "Karangasso-Vigué", "Sangha", "Mégué",
                     "Soa", "Samôgôgouan", "Sabsé", "Tanguen-Dassouri", "Ouri", "Kassou",
                     "Ouagadougou", "Ouagadougou", "Ouagadougou", "Ouagadougou",
                     "Ouagadougou", "Ouagadougou", "Ouagadougou", "Ouagadougou",
                     "Ouagadougou", "Ouagadougou", "Ouagadougou", "Ouagadougou",
                     "Ouagadougou", "Ouagadougou", "Ouagadougou", "Ouagadougou",
                     "Ouagadougou", "Ouagadougou", "Ouagadougou")
)

# Application de la fonction
ehcvm_corrected <- ehcvm_raw %>%
  dplyr::left_join(correction_map, by = c("s00q03" = "commune_label")) %>%
  dplyr::mutate(s00q03 = ifelse(is.na(corrected_name), s00q03, corrected_name)) %>%
  dplyr::select(-corrected_name)

# === 3-c NETTOYAGE DES DONNES ===
# Fonction de nettoyage des noms
clean_names <- function(name) {
  name %>%
    stringr::str_to_lower() %>% # Met en miniscules
    iconv(to = "ASCII//TRANSLIT") %>% # Supprime les accents
    stringr::str_replace_all("'", "") %>% # Supprime les apostrophes
    stringr::str_replace_all("[-]", " ") %>%  # Supprimer les tirets
    stringr::str_replace_all("[^[:alnum:] ]", " ") %>% # Supprime les caractères spéciaux
    stringr::str_trim() %>% # Supprime les espaces de début et de fin de chaîne
    stringr::str_squish() # Remplace les espaces multiples par un seul espace
}

# EHCVM : convertion les codes en labels et nettoyage des communes et départements
ehcvm <- ehcvm_corrected %>%
  dplyr::mutate(
    commune_label = forcats::as_factor(s00q03),  # Récupère les labels Stata
    departement_label = forcats::as_factor(s00q02),  # Récupère les labels des départements
    commune_clean = clean_names(commune_label), # Nettoie les communes
    departement_clean = clean_names(departement_label) # Nettoie les départements
  )

# Shape Data : nettoyage des communes et départements
shape <- shape_raw %>%
  dplyr::mutate(
    commune_clean = clean_names(ADM3_FR),
    departement_clean = clean_names(ADM2_FR)
  )


# === 3-d FUSION ===
# Liste des communes nécessitant une vérification par département
communes_ambigues <- c("boussouma", "namissiguima", "thiou")

# Premier merge sur commune_clean UNIQUEMENT pour les communes qui ne sont PAS dans communes_ambigues
ehcvm_shape_merged <- ehcvm %>%
  dplyr::filter(!commune_clean %in% communes_ambigues) %>%
  dplyr::left_join(shape, by = "commune_clean")

# Fusion pour les communes ambigües en tenant compte des départements
ehcvm_shape_merged_ambigues <- ehcvm %>%
  dplyr::filter(commune_clean %in% communes_ambigues) %>%
  dplyr::left_join(shape, by = c("commune_clean", "departement_clean"))

# Combiner les deux bases après fusion
ehcvm_shape_final <- dplyr::bind_rows(ehcvm_shape_merged, ehcvm_shape_merged_ambigues)

# === 3-f VERFICATION ===

non_matchees <- ehcvm_shape_final %>%
  dplyr::filter(is.na(ADM3_PCODE)) %>%
  dplyr::distinct(s00q03, departement_label, commune_clean)

head(non_matchees) # Aucune commune non mactchée

# === 3-g SUPPRESSION DES COLONNES TEMPORAIRES ===

ehcvm_final <- ehcvm_shape_final %>%
  dplyr::select(-commune_clean, -departement_clean, -commune_label, -departement_label)

print(head(ehcvm_final))
