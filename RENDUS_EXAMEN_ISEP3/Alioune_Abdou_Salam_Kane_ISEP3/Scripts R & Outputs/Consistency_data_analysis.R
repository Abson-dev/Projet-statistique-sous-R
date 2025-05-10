# Script.R constitue le fichier dans lequel nous allons faire tous les traitements
# qui concernent la base principale. Lorsqu’on arrivera à une autre base, 
# on changera de fichier .R pour organiser le travail proprement.

# I. Faisons une analyse de consistance de la base de données

# -------------------- Chargement des packages --------------------
library(tidyverse)   # Pour manipulation et visualisation des données
library(haven)       # Pour importer les fichiers STATA (.dta)
library(labelled)    # Pour gérer les labels associés aux variables STATA
library(janitor)     # Pour faire un nettoyage de la base de données 

# I.	Faisons une analyse de consistence des bases de données: 

# -------------------- Explication de l'analyse de consistance --------------------
# Une analyse de consistance consiste à vérifier que les données sont cohérentes,
# complètes et logiques. Autrement dit, on cherche à détecter :
# - les valeurs manquantes
# - les doublons
# - les erreurs ou incohérences (ex: un homme déclaré "enceinte")
# - les valeurs aberrantes (ex: un âge de 150 ans)
# - et à s'assurer que chaque variable est bien du bon type (numérique, texte, etc.)
#
# Dans cette question, nous allons donc visualiser la base pour repérer ce genre de problèmes,
# et faire les premières vérifications de cohérence avant toute analyse statistique.

# -------------------- Importation de la base --------------------
# Lecture de la base principale à partir du dossier 'data'
base <- read_dta("data/Base_Principale.dta")

# -------------------- Nettoyage des noms de variables --------------------
# On utilise clean_names() pour rendre tous les noms de variables plus simples :
# minuscules, séparées par des underscores, sans accents ni caractères spéciaux

base <- base %>%
  clean_names()

# -------------------- Vérification des doublons --------------------
# On cherche maintenant à identifier s'il existe des lignes dupliquées dans la base.
# Une ligne dupliquée signifie que toutes les valeurs de toutes les colonnes sont identiques
# à une autre ligne, ce qui peut fausser les analyses statistiques.

# Identifier les lignes dupliquées (TRUE si la ligne est un doublon)
doublons_logiques <- duplicated(base)

# Afficher le nombre total de doublons
sum(doublons_logiques)

# Afficher les lignes concernées par les doublons
base[doublons_logiques, ]


# -------------------- Afficher la liste des variables avec leurs labels --------------------
# Ce tableau nous permet de voir la signification de chaque variable (label),
# ce qui est essentiel pour comprendre les dépendances entre variables
# et détecter d’éventuelles incohérences ou non-réponses justifiées (ex: filtre conditionnel).

# Utilise look_for() du package {labelled}
look_for(base) %>%
  select(variable, label)  # Affiche uniquement le nom de la variable et son libellé


# -------------------- Création d'un tableau des variables avec leurs labels --------------------
# Pour mieux comprendre la signification de chaque variable de la base,
# nous allons créer un tableau qui liste, pour chaque variable :
# - son nom technique (ex : HHHAge, HHHSex)
# - sa description (label), telle que définie dans le fichier STATA

# Cela nous permettra ensuite d’identifier des relations logiques possibles entre variables
# (ex : une question qui dépend du sexe ou de l’âge), afin de mieux détecter
# les incohérences, les valeurs manquantes justifiées, ou les erreurs potentielles.

df_labels <- look_for(base) %>%        # Extrait les métadonnées (nom + label)
  select(variable, label) %>%          # Ne garde que le nom et le libellé
  distinct()                           # Évite les doublons s’il y en a

# Visualisation rapide dans la console
head(df_labels)                        # Affiche les premières lignes

# Pour voir le tableau complet dans une interface RStudio
View(df_labels)                        # Ouvre une fenêtre de visualisation



# -------------------- Bloc 1 : Identifier les NA attendus (sauts logiques) --------------------
# Dans ce bloc, nous allons indiquer explicitement à R que certaines variables dépendent d'autres.
# Autrement dit, si la réponse à une variable conditionnelle est "non concerné", alors le NA dans
# la variable dépendante n’est pas une erreur de saisie mais un **saut logique normal**.

# Cela permet :
# ✅ D’éviter de faussement considérer ces NA comme des valeurs manquantes à corriger
# ✅ D’expliquer logiquement pourquoi certaines valeurs sont absentes
# ✅ De concentrer les vérifications de qualité uniquement là où c’est pertinent

# Exemple concret : 
# Si un ménage déclare "n’avoir rencontré aucune difficulté" (SERSDifficultes == "Non"),
# alors il est normal que toutes les stratégies de crise (LhCSI*) soient non remplies (NA),
# car ces questions ne lui étaient pas posées.



# -------------------- Objectif de la procédure --------------------
# Nous voulons détecter automatiquement les valeurs manquantes (NA) qui sont :
#  - soit logiquement justifiées (car la question n'était pas posée selon la réponse précédente),
#  - soit injustifiées (et donc à imputer ou analyser comme anomalie).
#
# Pour cela, nous utilisons les "variables maîtresses", c’est-à-dire des variables dont la valeur
# conditionne la présence ou non d’autres questions dans le questionnaire.
#
# ✅ Les modalités de ces variables maîtresses ont été obtenues via STATA :
# 
# SERSDifficultes:
#   1 = tout à fait d'accord
#   2 = d'accord
#   3 = ni d'accord ni pas d'accord
#   4 = pas d'accord
#   5 = pas du tout d'accord
#
# HHHSex:
#   1 = Femme
#   2 = Homme
#
# HHHMainActivity:
#   13 = Don/Aide/Mendicité
#   14 = Autre
#
# Nous utilisons ces modalités pour créer des règles de saut conditionnel.

library(dplyr)
library(rlang)



# -------------------- Définition des règles logiques --------------------
logique_na <- list(
  sers_difficultes = list(
    na_justifie_si = c(1, 2),  # → Si pas de difficulté, pas besoin de poser les questions suivantes
    dependantes = c(
      "lh_csi_stress1", "lh_csi_stress2", "lh_csi_stress3", "lh_csi_stress4",
      "lh_csi_crisis1", "lh_csi_crisis2", "lh_csi_crisis3",
      "lh_csi_emergency1", "lh_csi_emergency2", "lh_csi_emergency3",
      "r_csi_less_qlty", "r_csi_borrow", "r_csi_meal_size", "r_csi_meal_adult", "r_csi_meal_nb"
    )
  ),
  
  hhh_sex = list(
    na_justifie_si = c(2),  # 2 = Homme → certaines questions féminines peuvent être sautées
    dependantes = c()       # À compléter plus tard si des questions spécifiques femmes existent
  ),
  
  hhh_main_activity = list(
    na_justifie_si = c(12, 13, 14),  # Don/Aide/Mendicité ou Autre → pas d'activité structurée
    dependantes = c("hh_source_income")
  )
)

# -------------------- Application automatique des règles --------------------
# Cette boucle crée une colonne de vérification "verif_<nom_variable>" pour chaque variable dépendante,
# indiquant si un NA est "justifié", "suspect" ou si une réponse est présente.

base_verifiee <- base  # Créer une copie de la base pour annotation

for (maitresse in names(logique_na)) {
  config <- logique_na[[maitresse]]
  skip_values <- config$na_justifie_si
  dependantes <- config$dependantes
  
  if (length(dependantes) == 0) next  # on passe si pas de variable dépendante
  
  for (var_dep in dependantes) {
    col_verif <- paste0("verif_", var_dep)
    
    base_verifiee <- base_verifiee %>%
      mutate(!!col_verif := case_when(
        !!sym(maitresse) %in% skip_values & is.na(!!sym(var_dep)) ~ "NA justifié",
        !(!!sym(maitresse) %in% skip_values) & is.na(!!sym(var_dep)) ~ "NA suspect",
        TRUE ~ "Réponse présente"
      ))
  }
}


# -------------------- Objectif --------------------
# Extraire toutes les lignes de la base où au moins une variable dépendante contient un NA suspect.

library(dplyr)

# 1. Identifier toutes les colonnes de vérification générées précédemment
colonnes_verif <- names(base_verifiee)[grepl("^verif_", names(base_verifiee))]

# 2. Extraire les lignes où au moins un NA est suspect
na_injustifies <- base_verifiee %>%
  filter(if_any(all_of(colonnes_verif), ~ .x == "NA suspect"))

# 3. Afficher ces lignes
na_injustifies

##############################################################################
#  IMPUTATION  DES NA SUSPECTS                              #
#  (On laisse tranquilles les NA justifiés – ils marquent des questions       #
#   qui n’ont jamais été posées.)                                            #
##############################################################################

# Idée générale  :
#   1. Pour CHAQUE colonne dépendante où il reste des “NA suspect”,
#      on remplace ces NA selon un principe évident et facile à expliquer.
#   2. On utilise : 
#        • la MÉDIANE pour les nombres,
#        • la CATÉGORIE LA PLUS FRÉQUENTE (le “mode”) pour les variables
#          qualitatives / ordinales.
#
#   → Pas de machine à gaz ; on choisit la valeur « la plus typique ».
#
# Avantage : compréhensible pour n’importe qui (“on met la valeur la plus
#            répandue / la valeur du milieu”).
# Limite   : moins sophistiqué qu’une vraie imputation multiple,
#             pas idéal mais suffisant 

library(dplyr)

# 1. On crée un data-frame uniquement avec les NA suspects
colonnes_verif <- names(base_verifiee)[grepl("^verif_", names(base_verifiee))]
na_suspects_df <- base_verifiee %>% 
  filter(if_any(all_of(colonnes_verif), ~ .x == "NA suspect"))

# 2. Fonction utilitaire : mode (catégorie la plus fréquente)
mode_simple <- function(x) {
  x <- x[!is.na(x)]
  if (length(x) == 0) return(NA)
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}

# 3. Boucle sur chaque variable dépendante
vars_dependantes <- c(
  "lh_csi_stress1", "lh_csi_stress2", "lh_csi_stress3", "lh_csi_stress4",
  "lh_csi_crisis1", "lh_csi_crisis2", "lh_csi_crisis3",
  "lh_csi_emergency1", "lh_csi_emergency2", "lh_csi_emergency3",
  "r_csi_less_qlty", "r_csi_borrow", "r_csi_meal_size", 
  "r_csi_meal_adult", "r_csi_meal_nb",
  "hh_source_income"
)

# 4. Imputation « basique » colonne par colonne
base_impute_simple <- base_verifiee

for (v in vars_dependantes) {
  
  # repérer seulement les NA suspects
  masque_suspect <- base_verifiee[[paste0("verif_", v)]] == "NA suspect"
  
  if (is.numeric(base_verifiee[[v]])) {
    # ► Cas numérique : on met la médiane (valeur du milieu)
    med <- median(base_verifiee[[v]], na.rm = TRUE)
    base_impute_simple[[v]][masque_suspect] <- med
    
  } else {
    # ► Cas qualitatif / ordinal : on met la catégorie la plus fréquente
    md  <- mode_simple(base_verifiee[[v]])
    base_impute_simple[[v]][masque_suspect] <- md
  }
  
  # On peut conserver un petit drapeau si besoin
  base_impute_simple[[paste0("flag_", v)]] <- dplyr::case_when(
    masque_suspect                    ~ "imputé (simple)",
    TRUE                              ~ "observé / NA justifié"
  )
}

##############################################################################
#  QUE S’EST-IL PASSÉ ? (explication ultra simple)                           #
##############################################################################
# • Pour chaque NA suspect :
#     – Si la colonne est un NOMBRE (par ex. “nombre de repas réduit”),
#       on a mis la MÉDIANE, c’est-à-dire la valeur du milieu quand on trie.
#     – Si la colonne est une CATÉGORIE (par ex. “source principale de revenu”),
#       on a mis la CATÉGORIE LA PLUS COURANTE dans l’ensemble des données.
#
# • Les NA justifiés (liés aux sauts de question) n’ont PAS bougé.
# • On a gardé un petit indicateur flag_<var> pour savoir ce qui a été imputé.
#
#  « on remplace le trou par la valeur la plus représentative. »
##############################################################################




################################################################################
# 🧩 GESTION DES INCOHÉRENCES DANS LA BASE
################################################################################
# 🎯 OBJECTIF GLOBAL :
# Repérer les incohérences logiques dans les données qui ne relèvent pas
# d’un problème de valeur manquante (NA), mais d’une **valeur remplie fausse**,
# c’est-à-dire une réponse **présente mais absurde ou contradictoire**.

# Exemples : 
#   - Un ménage déclare 5 personnes au total, mais en liste 8 dans les tranches d’âge.
#   - Un ménage dit "ne pas avoir connu de difficulté", mais a adopté des stratégies d’urgence.
#   - Un ménage consomme un aliment, mais dit n’avoir aucune source d’approvisionnement.
#
# Ces erreurs ne peuvent pas être imputées ; il faut soit les corriger, soit les exclure.
# --------------------------------------------------------------------------------
# 🔍 Chaque incohérence sera vérifiée via une règle claire + une colonne "check_..."

library(dplyr)

################################################################################
# 📌 INCOHÉRENCE 1 : Taille du ménage ≠ somme des tranches d’âge
################################################################################
# 🧠 Logique : la somme des membres listés dans les tranches doit être égale à `hh_size`

colonnes_tranches <- c(
  "hh_size05m", "hh_size23m", "hh_size59m", "hh_size5114m", "hh_size1549m", 
  "hh_size5064m", "hh_size65above_m", "hh_size05f", "hh_size23f", "hh_size59f", 
  "hh_size5114f", "hh_size1549f", "hh_size5064f", "hh_size65above_f"
)

base_verifiee <- base_verifiee %>%
  mutate(hh_size_calculee = rowSums(across(all_of(colonnes_tranches)), na.rm = TRUE)) %>%
  mutate(check_hh_size = case_when(
    is.na(hh_size) ~ "taille manquante",
    hh_size == hh_size_calculee ~ "ok",
    TRUE ~ "incohérence"
  ))

################################################################################
# 📌 INCOHÉRENCE 2 : Déclare "pas de difficulté", mais applique des stratégies d'urgence
################################################################################
# 🧠 Logique : si le ménage dit n’avoir eu **aucune difficulté** (valeurs 1 ou 2),
# alors il ne devrait PAS avoir activé de stratégies d’urgence.

strategies_urgence <- c(
  "lh_csi_stress1", "lh_csi_stress2", "lh_csi_stress3", "lh_csi_stress4",
  "lh_csi_crisis1", "lh_csi_crisis2", "lh_csi_crisis3",
  "lh_csi_emergency1", "lh_csi_emergency2", "lh_csi_emergency3",
  "r_csi_less_qlty", "r_csi_borrow", "r_csi_meal_size", 
  "r_csi_meal_adult", "r_csi_meal_nb"
)

base_verifiee <- base_verifiee %>%
  mutate(check_strategies_vs_difficultes = case_when(
    sers_difficultes %in% c(1, 2) &
      rowSums(across(all_of(strategies_urgence)), na.rm = TRUE) > 0 ~ "incohérence",
    TRUE ~ "ok"
  ))

################################################################################
# 📌 INCOHÉRENCE 3 : Consommation alimentaire ≠ Source déclarée
################################################################################
# 🧠 Logique : on ne peut pas consommer un aliment plusieurs jours sans aucune source déclarée.
# Ex : mange des œufs, mais `fcs_pr_s_rf == 0` → incohérent

base_verifiee <- base_verifiee %>%
  mutate(check_fcs_egg = case_when(
    !is.na(fcs_pr_egg) & fcs_pr_egg > 0 & (is.na(fcs_pr_s_rf) | fcs_pr_s_rf == 0) ~ "incohérence",
    TRUE ~ "ok"
  ),
  check_fcs_dairy = case_when(
    !is.na(fcs_dairy) & fcs_dairy > 0 & (is.na(fcs_dairy_s_rf) | fcs_dairy_s_rf == 0) ~ "incohérence",
    TRUE ~ "ok"
  ),
  check_fcs_fruit = case_when(
    !is.na(fcs_fruit) & fcs_fruit > 0 & (is.na(fcs_fruit_s_rf) | fcs_fruit_s_rf == 0) ~ "incohérence",
    TRUE ~ "ok"
  ))

################################################################################
# 📌 INCOHÉRENCE 4 : Sexe du chef de ménage = Homme, mais activité incompatible
################################################################################
# (À adapter si on identifie des activités exclusivement féminines, ex. : allaitement)

# Ici on ne teste rien pour l’instant mais on peut ajouter des règles spécifiques plus tard.

################################################################################
# 📊 AFFICHAGE GLOBAL DES INCOHÉRENCES
################################################################################

# Voir combien d’incohérences par type
table(base_verifiee$check_hh_size)
table(base_verifiee$check_strategies_vs_difficultes)
table(base_verifiee$check_fcs_egg)
table(base_verifiee$check_fcs_dairy)
table(base_verifiee$check_fcs_fruit)

# Extraire les lignes ayant au moins une incohérence
colonnes_check <- names(base_verifiee)[grepl("^check_", names(base_verifiee))]

incoherences_globales <- base_verifiee %>%
  filter(if_any(all_of(colonnes_check), ~ .x == "incohérence"))



###############################################################################
# GESTION DES INCOHÉRENCES DANS LA BASE : CORRECTIONS SIMPLES ET JUSTIFIÉES
###############################################################################
# Ce bloc fait suite aux vérifications faites précédemment.
# Pour chaque incohérence détectée, on :
#   - explique pourquoi c’est incohérent
#   - décide quoi faire
#   - corrige ou marque l’erreur
###############################################################################

# Copie de travail
base_corrigee <- base_verifiee

# 1 - INCOHÉRENCE hh_size ≠ somme des tranches d’âge
# ------------------------------------------------------------
# Pourquoi c’est incohérent :
# Si on dit qu’il y a 6 personnes dans le ménage (hh_size), 
# mais qu’on en a listé 8 dans les tranches d’âges, c’est incohérent.

# Que faire :
# On fait confiance aux tranches détaillées (plus précises),
# donc on corrige hh_size avec la somme calculée.

base_corrigee <- base_corrigee %>%
  mutate(hh_size = ifelse(check_hh_size == "incohérence", hh_size_calculee, hh_size))


# 2 - INCOHÉRENCE : stratégies utilisées alors que ménage dit "pas de difficulté"
# ------------------------------------------------------------
# Pourquoi c’est incohérent :
# Si une personne dit qu’elle n’a pas eu de difficulté (valeurs 1 ou 2),
# mais qu’elle a réduit ses repas ou vendu ses biens, il y a contradiction.

# Que faire :
# On ne peut pas deviner les vraies intentions du ménage.
# Donc on supprime les réponses aux stratégies si la personne dit ne pas avoir eu de difficulté.

base_corrigee <- base_corrigee %>%
  mutate(across(
    all_of(strategies_urgence),
    ~ ifelse(
      check_strategies_vs_difficultes == "incohérence", 
      NA, 
      .
    )
  ))


# 3 - INCOHÉRENCE : consommation d’œufs sans source déclarée
# ------------------------------------------------------------
# Pourquoi c’est incohérent :
# Si quelqu’un dit avoir mangé des œufs, il doit bien les avoir obtenus quelque part.
# fcs_pr_egg > 0 et fcs_pr_s_rf == 0 ne peuvent pas coexister.

# Que faire :
# On ajoute une source par défaut (valeur minimale = 1) dans fcs_pr_s_rf.

base_corrigee <- base_corrigee %>%
  mutate(fcs_pr_s_rf = ifelse(
    check_fcs_egg == "incohérence", 
    1, 
    fcs_pr_s_rf
  ))


# 4 - INCOHÉRENCE : consommation de produits laitiers sans source
# ------------------------------------------------------------
base_corrigee <- base_corrigee %>%
  mutate(fcs_dairy_s_rf = ifelse(
    check_fcs_dairy == "incohérence", 
    1, 
    fcs_dairy_s_rf
  ))


# 5 - INCOHÉRENCE : consommation de fruits sans source
# ------------------------------------------------------------
base_corrigee <- base_corrigee %>%
  mutate(fcs_fruit_s_rf = ifelse(
    check_fcs_fruit == "incohérence", 
    1, 
    fcs_fruit_s_rf
  ))


###############################################################################
# RÉSUMÉ DES CORRECTIONS
###############################################################################
# Pour chaque incohérence, on a appliqué une solution simple :
# - hh_size : remplacé par la vraie somme des membres
# - stratégies : supprimées si personne déclare n’avoir eu aucun problème
# - aliments : ajout d’une source minimale si la personne déclare avoir consommé

# Ces corrections sont raisonnables :
# - elles respectent la logique du questionnaire
# - elles évitent de conserver des valeurs absurdes
# - elles n’inventent pas de réponses aléatoires
###############################################################################



# -------------------- Exportation de la base corrigée --------------------
# Objectif : Sauvegarder la base propre avec toutes les corrections appliquées
# Format : .dta pour compatibilité avec les autres outils (STATA, R, etc.)
# Emplacement : dans le dossier 'data', sous le nom "Base_Principale_corrigee.dta"

write_dta(base_corrigee, path = "data/Base_Principale_corrigee.dta")



