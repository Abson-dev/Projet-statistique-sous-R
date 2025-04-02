#------------------------------Traitement TP9-------------------------------------------------------------------------


# -----------------------------------------------------
#  Étape 1 : Chargement des packages nécessaires
# -----------------------------------------------------
library(haven)    # Pour lire les fichiers .dta
library(dplyr)    # Pour manipuler les données
library(tibble)   # Pour créer des tableaux
library(purrr)    # Pour appliquer des fonctions aux listes

# -----------------------------------------------------
# Étape 2 : Chargement des bases
# -----------------------------------------------------
base2018 <- read_dta("../data/ehcvm_welfare_sen2018.dta")
base2021 <- read_dta("../data/ehcvm_welfare_sen2021.dta")

# -----------------------------------------------------
#  Étape 3 : Définir manuellement les listes de variables et leurs labels
# -----------------------------------------------------
# Liste pour la base 2018
vars_2018 <- tribble(
  ~variable, ~label,
  "country", "Pays",
  "year", "Annee enquete",
  "hhid", "Idenfiant menage",
  "grappe", "Numero grappe",
  "menage", "Numero menage",
  "vague", "Vague",
  "zae", "Zone agroecologique",
  "region", "Region residence",
  "milieu", "Milieu residence",
  "hhweight", "Ponderation menage",
  "hhsize", "Taille menage",
  "eqadu1", "Nbr adultes-equiv. FAO",
  "eqadu2", "Nbr adultes-equiv. alt.",
  "hgender", "Genre du CM",
  "hage", "Age du CM",
  "hmstat", "Situation famille du CM",
  "hreligion", "Religion du CM",
  "hnation", "Nationalite du CM",
  "halfab", "Alphabetisation du CM",
  "heduc", "Education du CM",
  "hdiploma", "Diplome du CM",
  "hhandig", "Handicap majeur CM",
  "hactiv7j", "Activite 7 jours du CM",
  "hactiv12m", "Activite 12 mois du CM",
  "hbranch", "Branche activite du CM",
  "hsectins", "Secteur instit. du CM",
  "hcsp", "CSP du CM",
  "dali", "Conso annuelle alim. menage",
  "dnal", "Conso annuelle non alim. menage",
  "dtot", "Conso annuelle totale menage",
  "pcexp", "Indicateur de bien-etre",
  "zzae", "",
  "zref", "Seuil pauvrete national",
  "def_spa", "Deflateur spatial",
  "def_temp", "Deflateur temporel"
)

# Liste pour la base 2021
vars_2021 <- tribble(
  ~variable, ~label,
  "grappe", "grappe",
  "menage", "Identifiant du ménage",
  "country", "Pays",
  "year", "Annee enquete",
  "hhid", "Idenfiant menage",
  "vague", "Vague",
  "month", "month of interview",
  "zae", "Zone agroecologique",
  "region", "Region residence",
  "milieu", "Milieu residence",
  "hhweight", "Ponderation menage",
  "hhsize", "Taille menage",
  "eqadu1", "Nbr adultes-equiv. FAO",
  "eqadu2", "Nbr adultes-equiv. alt.",
  "hgender", "Genre du CM",
  "hage", "Age du CM",
  "hmstat", "Situation famille du CM",
  "hreligion", "Religion du CM",
  "hnation", "Nationalite du CM",
  "hethnie", "Ethnie du CM",
  "halfa", "Alpha. lire/ecr. CM",
  "halfa2", "Alpha. lire/ecr./comp. CM",
  "heduc", "Education du CM",
  "hdiploma", "Diplome du CM",
  "hhandig", "Handicap majeur CM",
  "hactiv7j", "Activite 7 jours du CM",
  "hactiv12m", "Activite 12 mois du CM",
  "hbranch", "Branche activite du CM",
  "hsectins", "Secteur instit. du CM",
  "hcsp", "CSP du CM",
  "dali", "Conso annuelle alim. menage",
  "dnal", "Conso annuelle non alim. menage",
  "dtot", "Conso annuelle totale menage",
  "pcexp", "Indicateur de bien-etre",
  "zzae", "",
  "zref", "Seuil pauvrete national",
  "def_spa", "Deflateur spatial",
  "def_temp", "Deflateur temporel",
  "def_temp_prix2021m11", "temporal deflator for international poverty",
  "def_temp_cpi", "alternative temporal deflator based on official CPI, 2018/19 style",
  "def_temp_adj", "temporal deflator adjusted for difference between hh and market survey periods",
  "zali0", "(sum) conso_pc_val_up",
  "dtet", "",
  "monthly_cpi", "Monthly CPI value",
  "cpi2017", "",
  "icp2017", "",
  "dollars", "welfare in 2017 PPP USD per capita per day (not spatially deflated)"
)

# -----------------------------------------------------
#  Étape 4 : Identifier les variables catégorielles communes
# -----------------------------------------------------
# Ici, on considère qu'une variable est catégorielle si, dans le .dta, elle possède l'attribut "labels".
# On va utiliser uniquement les variables de nos listes de référence (entrée manuelle)
is_categorical <- function(df, var) {
  !is.null(attr(df[[var]], "labels"))
}

# On filtre la liste de 2018 en gardant celles présentes dans base2018 et catégorielles
cat_vars_2018 <- vars_2018$variable[
  vars_2018$variable %in% names(base2018) & 
    map_lgl(vars_2018$variable, ~ is_categorical(base2018, .x))
]

# Idem pour 2021
cat_vars_2021 <- vars_2021$variable[
  vars_2021$variable %in% names(base2021) & 
    map_lgl(vars_2021$variable, ~ is_categorical(base2021, .x))
]

# On identifie ensuite les variables catégorielles communes aux deux bases
cat_vars_communes <- intersect(cat_vars_2018, cat_vars_2021)
cat("✅ Variables catégorielles communes aux deux bases :\n")
print(cat_vars_communes)

# -----------------------------------------------------
#  Étape 5 : Extraire les modalités (code + nom de modalité) pour les variables communes
# -----------------------------------------------------
# Fonction pour extraire les modalités d'une variable d'une base donnée
get_modalites <- function(df, var, base_label) {
  labels <- attr(df[[var]], "labels")
  if (is.null(labels)) return(NULL)
  tibble(
    variable = var,
    modalite = names(labels),   # Nom de la modalité
    encodage = unname(labels),  # Valeur codée
    annee = base_label          # Année de la base
  )
}

# Extraire les modalités pour chaque variable commune pour la base 2018
modalites_2018 <- map_dfr(cat_vars_communes, ~ get_modalites(base2018, .x, "2018"))

# Extraire les modalités pour chaque variable commune pour la base 2021
modalites_2021 <- map_dfr(cat_vars_communes, ~ get_modalites(base2021, .x, "2021"))

# -----------------------------------------------------
#  Étape 6 : Concaténer et afficher le dataframe final
# -----------------------------------------------------
# Le dataframe final aura 4 colonnes :
#   - annee : l'année de l'enquête (source)
#   - variable : le nom de la variable
#   - modalite : le nom de la modalité
#   - encodage : la valeur codée associée

modalites_final <- bind_rows(modalites_2018, modalites_2021) %>%
  arrange(variable, annee, encodage)


# -----------------------------------------------------
# ️ Étape 7 : Correction des erreurs d'encodage
# -----------------------------------------------------

# -----------------------------------------------------
# 🔁 Correction 1 : Harmoniser hactiv7j dans la base 2021 (basé sur encodage de 2018)
# -----------------------------------------------------
# Encodage cible (2018) :
# 1 = Occupe
# 2 = Chômeur
# 3 = TF cherchant emploi
# 4 = TF cherchant pas
# 5 = Inactif
# 6 = Moins de 5 ans

# Étapes : convertir -> recoder -> relabel

# a. Conversion
hactiv7j_clean <- as.numeric(base2021$hactiv7j)

# b. Recodage
hactiv7j_corrected <- dplyr::recode(hactiv7j_clean,
                                    `1` = 1,
                                    `2` = 3,
                                    `3` = 4,
                                    `4` = 2,
                                    `5` = 5,
                                    `6` = 6)

# c. Labels cohérents avec 2018
labels_2018_hactiv7j <- c(
  "Occupe" = 1,
  "Chomeur" = 2,
  "TF cherchant emploi" = 3,
  "TF cherchant pas" = 4,
  "Inactif" = 5,
  "Moins de 5 ans" = 6
)

# d. Réintégration dans la base 2021
base2021$hactiv7j <- haven::labelled(hactiv7j_corrected, labels = labels_2018_hactiv7j)

# -----------------------------------------------------
# 🔁 Correction 2 : Harmoniser hbranch dans la base 2018 (basé sur labels de 2021)
# -----------------------------------------------------
# Seul le libellé du code 2 est plus englobant en 2021

# a. Conversion
hbranch_clean <- as.numeric(base2018$hbranch)

# b. Labels harmonisés (version 2021)
labels_2021_hbranch <- c(
  "Agriculture" = 1,
  "Elevage/syl./peche" = 2,
  "Indust. extr." = 3,
  "Autr. indust." = 4,
  "btp" = 5,
  "Commerce" = 6,
  "Restaurant/Hotel" = 7,
  "Trans./Comm." = 8,
  "Education/Sante" = 9,
  "Services perso." = 10,
  "Aut. services" = 11
)

# c. Réintégration dans la base 2018
base2018$hbranch <- haven::labelled(hbranch_clean, labels = labels_2021_hbranch)

# -----------------------------------------------------
# 🔁 Correction 3 : Harmoniser hcsp dans la base 2018 (aligné sur libellés 2021)
# -----------------------------------------------------

# a. Conversion en vecteur simple
hcsp_clean <- as.numeric(base2018$hcsp)

# b. Labels harmonisés (version 2021)
labels_2021_hcsp <- c(
  "Cadre supérieur" = 1,
  "Cadre moyen/agent de maîtrise" = 2,
  "Ouvrier ou employé qualifié" = 3,
  "Ouvrier ou employé non qualifié" = 4,
  "Manœuvre, aide ménagère" = 5,
  "Stagiaire ou Apprenti rénuméré" = 6,
  "Stagiaire ou Apprenti non rénuméré" = 7,
  "Travailleur Familial contribuant pour une entreprise familial" = 8,
  "Travailleur pour compte propre" = 9,
  "Patron" = 10
)

# c. Réintégration dans la base 2018
base2018$hcsp <- haven::labelled(hcsp_clean, labels = labels_2021_hcsp)


# -----------------------------------------------------
# 🔁 Correction 4 : Harmoniser hdiploma dans la base 2021 (basé sur libellés de 2018)
# -----------------------------------------------------

# a. Conversion en vecteur simple
hdiploma_clean <- as.numeric(base2021$hdiploma)

# b. Labels harmonisés (version 2018)
labels_2018_hdiploma <- c(
  "Aucun" = 0,
  "CEP/CFEE" = 1,
  "BEPC/BFEM" = 2,
  "cap" = 3,
  "bt" = 4,
  "bac" = 5,
  "DEUG, DUT, BTS" = 6,
  "Licence" = 7,
  "Maitrise" = 8,
  "Master/DEA/DESS" = 9,
  "Doctorat/Phd" = 10
)

# c. Réintégration dans la base 2021
base2021$hdiploma <- haven::labelled(hdiploma_clean, labels = labels_2018_hdiploma)


# -----------------------------------------------------
# 🔁 Correction 5 : Harmoniser hnation dans la base 2021 (selon structure agrégée de 2018)
# -----------------------------------------------------

# a. Conversion en vecteur simple
hnation_clean <- as.numeric(base2021$hnation)

# b. Recodage des valeurs selon regroupement 2018
hnation_corrected <- dplyr::recode(hnation_clean,
                                   `1` = 1,    # Bénin
                                   `2` = 2,    # Burkina Faso
                                   `3` = 10,   # Cape-vert → Autre CEDEAO
                                   `4` = 3,    # Côte d'Ivoire
                                   `5` = 10,   # Gambie → Autre CEDEAO
                                   `6` = 10,   # Ghana → Autre CEDEAO
                                   `7` = 10,   # Guinee → Autre CEDEAO
                                   `8` = 4,    # Guinée Bissau
                                   `9` = 10,   # Liberia → Autre CEDEAO
                                   `10` = 5,   # Mali
                                   `11` = 6,   # Niger
                                   `12` = 9,   # Nigeria
                                   `13` = 7,   # Sénégal
                                   `14` = 10,  # Sierra Leone → Autre CEDEAO
                                   `15` = 8,   # Togo
                                   `17` = 11,  # Autre Afrique
                                   `18` = 12   # Autre pays hors Afrique
)

# c. Labels de 2018 à appliquer
labels_2018_hnation <- c(
  "Benin" = 1,
  "Burkina Faso" = 2,
  "Côte d'Ivoire" = 3,
  "Guinée Bissau" = 4,
  "Mali" = 5,
  "Niger" = 6,
  "Sénégal" = 7,
  "Togo" = 8,
  "Nigéria" = 9,
  "Autre CEDEAO" = 10,
  "Autre Afrique" = 11,
  "Autre pays hors Afrique" = 12
)

# d. Réintégration dans la base 2021
base2021$hnation <- haven::labelled(hnation_corrected, labels = labels_2018_hnation)


# -----------------------------------------------------
# Étape 8 : Création de la base de sortie (Output)
# -----------------------------------------------------
# Objectif : Faire un simple append en ajoutant les observations de 2021 à celles de 2018.
#           Les variables présentes dans 2018 et non dans 2021 (ou inversement) recevront des NA pour les observations manquantes.

# On utilise bind_rows() pour combiner les deux bases corrigées.
output_data <- bind_rows(base2018, base2021)

# Affichage d'un résumé de la base résultante
cat("✅ La base de sortie contient", nrow(output_data), "observations.\n")



# -----------------------------------------------------
# Étape 9 : Exporter la base fusionnée + afficher un résumé
# -----------------------------------------------------

# ✅ S’assurer que le script travaille depuis le dossier "Scripts"
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# 📤 Export de la base fusionnée vers le dossier Outputs (au même niveau que Scripts)
write_dta(output_data, path = "../Outputs/welfare_2018_2021_output.dta")

# ✅ Confirmation
cat("✅ Export terminé : fichier disponible dans Outputs/welfare_2018_2021_output.dta\n\n")

# Résumé rapide de la base fusionnée
cat("Résumé de la base fusionnée :\n")
cat("- Nombre d’observations :", nrow(output_data), "\n")
cat("- Nombre de variables   :", ncol(output_data), "\n\n")

cat("Premières variables :\n")
print(names(output_data)[1:10])

cat("\n🔍 Aperçu des 6 premières lignes :\n")
print(head(output_data))
