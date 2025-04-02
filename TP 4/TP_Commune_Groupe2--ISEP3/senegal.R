# Chargement des librairies nécessaires
library(dplyr)
library(stringi)
library(stringr)
library(sf)
library(haven)
library(labelled)

# ---------------------------------------------------
# 1. Fonction de nettoyage des noms de communes
# ---------------------------------------------------
nettoyage_commune <- function(x) {
  x %>%
    tolower() %>%
    str_replace_all("^(com\\.?\\s*|com\\s+|commune\\s*(de)?\\s*)", "") %>%
    stri_trans_general("Latin-ASCII") %>%
    str_replace_all("['’‘´`]", "") %>%
    str_replace_all("[^[:alnum:] ]+", " ") %>%
    str_squish() %>%
    str_replace_all(" ", "")
}

# Exemple d'utilisation du nettoyage :
exemple_commune <- "COM. SénéGalKèmo"
cat("Avant nettoyage : ", exemple_commune, "\n")
cat("Après nettoyage : ", nettoyage_commune(exemple_commune), "\n")

# ---------------------------------------------------
# 2. Fonction de calcul de la distance de Levenshtein
# ---------------------------------------------------
levenshtein_distance <- function(s, t) {
  s_chars <- unlist(strsplit(s, split = ""))
  t_chars <- unlist(strsplit(t, split = ""))
  m <- length(s_chars)
  n <- length(t_chars)
  d <- matrix(0, nrow = m + 1, ncol = n + 1)
  for(i in 1:(m + 1)) { d[i, 1] <- i - 1 }
  for(j in 1:(n + 1)) { d[1, j] <- j - 1 }
  for(i in 1:m) {
    for(j in 1:n) {
      cost <- ifelse(s_chars[i] == t_chars[j], 0, 1)
      d[i + 1, j + 1] <- min(d[i, j + 1] + 1,
                             d[i + 1, j] + 1,
                             d[i, j] + cost)
    }
  }
  return(d[m + 1, n + 1])
}

# Exemple d'utilisation :
s1 <- "chat"
s2 <- "chats"
cat("Distance de Levenshtein entre '", s1, "' et '", s2, "' : ", 
     levenshtein_distance(s1, s2), "\n", sep = "")

# ---------------------------------------------------
# 3. Fonction de calcul de la similarité normalisée
# ---------------------------------------------------
similarity <- function(s, t) {
  d <- levenshtein_distance(s, t)
  max_len <- max(nchar(s), nchar(t))
  if(max_len == 0) return(1)
  return(1 - d / max_len)
}

# Exemple d'utilisation :
cat("Similarité entre '", s1, "' et '", s2, "' : ", 
    similarity(s1, s2), "\n", sep = "")

# ---------------------------------------------------
# 4. Fonction pour calculer la matrice de similarité
# ---------------------------------------------------
compute_similarity_matrix <- function(shape_communes, ehcvm_communes, sim_func = similarity) {
  sim_matrix <- matrix(0, nrow = length(shape_communes), ncol = length(ehcvm_communes))
  rownames(sim_matrix) <- shape_communes
  colnames(sim_matrix) <- ehcvm_communes
  
  for (i in seq_along(shape_communes)) {
    for (j in seq_along(ehcvm_communes)) {
      sim_matrix[i, j] <- sim_func(shape_communes[i], ehcvm_communes[j])
    }
  }
  return(sim_matrix)
}

# Exemple d'utilisation :
exemple_shape <- c("ruffisque", "pikine")
exemple_ehcvm <- c("ruffisque", "pikine", "dakar")
exemple_matrix <- compute_similarity_matrix(exemple_shape, exemple_ehcvm)
print(exemple_matrix)

# ---------------------------------------------------
# 5. Fonction interactive de fusion des bases sur les communes
# ---------------------------------------------------
merge_bases_commune_interactive <- function(data_SEN, data, threshold = 0.8, top_n = 5) {
  
  # Extraction et nettoyage des noms de communes
  shape_communes <- data_SEN$ADM3_FR_clean
  ehcvm_communes <- unique(data$commune_clean)
  
  # Calcul de la matrice de similarité
  cat("Calcul des scores de similarité...\n")
  sim_matrix <- compute_similarity_matrix(shape_communes, ehcvm_communes)
  
  # Séparation en deux groupes :
  # Groupe A : score maximum >= threshold (correspondances automatiques)
  # Groupe B : score maximum < threshold (à valider une par une)
  groupA_indices <- which(apply(sim_matrix, 1, max) >= threshold)
  groupB_indices <- setdiff(seq_along(shape_communes), groupA_indices)
  
  # --- Groupe A : correspondances automatiques ---
  cat("\n=== Groupe A : Correspondances automatiques (score >= ", threshold*100, "%) ===\n", sep = "")
  auto_mapping <- data.frame(
    shape_commune = shape_communes[groupA_indices],
    ehcvm_commune = sapply(groupA_indices, function(i) {
      candidates <- ehcvm_communes[order(sim_matrix[i, ], decreasing = TRUE)]
      return(candidates[1])
    }),
    score = sapply(groupA_indices, function(i) max(sim_matrix[i, ])),
    stringsAsFactors = FALSE
  )
  
  print(auto_mapping)
  
  rep_auto <- readline(prompt = "\nValidez-vous toutes ces correspondances automatiques ? (o/n) : ")
  if(tolower(rep_auto) == "o") {
    mapping_A <- auto_mapping
  } else {
    cat("\nEntrez les indices (dans la liste ci-dessus) des communes à modifier, séparés par une virgule\n(ou appuyez sur Entrée pour conserver celles non modifiées) : ")
    modif <- readline()
    mapping_A <- auto_mapping  # on part de la proposition automatique
    if(nchar(trimws(modif)) > 0) {
      modif_indices <- as.numeric(unlist(strsplit(modif, ",")))
      if(any(is.na(modif_indices)) || any(modif_indices < 1) || any(modif_indices > nrow(auto_mapping))) {
        cat("Indices invalides. Aucune modification ne sera effectuée pour le Groupe A.\n")
      } else {
        for(mi in modif_indices) {
          current_shape <- auto_mapping$shape_commune[mi]
          i <- which(shape_communes == current_shape)[1]
          candidate_order <- order(sim_matrix[i, ], decreasing = TRUE)
          candidates <- ehcvm_communes[candidate_order]
          candidate_scores <- sim_matrix[i, candidate_order]
          n_candidates <- min(top_n, length(candidates))
          cat(sprintf("\nPour la commune '%s', voici les %d meilleures correspondances :\n", 
                      current_shape, n_candidates))
          for (k in 1:n_candidates) {
            cat(sprintf("  %d: '%s' (score = %.2f)\n", k, candidates[k], candidate_scores[k]))
          }
          rep_choice <- as.numeric(readline(prompt = "Choisissez le numéro correspondant (ou 0 pour aucune correspondance) : "))
          if(!is.na(rep_choice) && rep_choice >= 1 && rep_choice <= n_candidates) {
            mapping_A$ehcvm_commune[mi] <- candidates[rep_choice]
            mapping_A$score[mi] <- candidate_scores[rep_choice]
          } else {
            mapping_A$ehcvm_commune[mi] <- NA
            mapping_A$score[mi] <- NA
            cat("Aucune correspondance validée pour cette commune.\n")
          }
        }
      }
    }
  }
  
  # --- Groupe B : correspondances à valider manuellement ---
  cat("\n=== Groupe B : Correspondances à valider manuellement (score < ", threshold*100, "%) ===\n", sep = "")
  manual_mapping <- data.frame(
    shape_commune = character(0),
    ehcvm_commune = character(0),
    score = numeric(0),
    stringsAsFactors = FALSE
  )
  
  if(length(groupB_indices) > 0) {
    for (i in groupB_indices) {
      current_shape <- shape_communes[i]
      candidate_order <- order(sim_matrix[i, ], decreasing = TRUE)
      candidates <- ehcvm_communes[candidate_order]
      candidate_scores <- sim_matrix[i, candidate_order]
      n_candidates <- min(top_n, length(candidates))
      cat(sprintf("\nPour la commune '%s' (meilleur score = %.2f), voici les %d meilleures correspondances :\n", 
                  current_shape, candidate_scores[1], n_candidates))
      for (k in 1:n_candidates) {
        cat(sprintf("  %d: '%s' (score = %.2f)\n", k, candidates[k], candidate_scores[k]))
      }
      rep_choice <- as.numeric(readline(prompt = "Choisissez le numéro correspondant (ou 0 pour aucune correspondance) : "))
      if(!is.na(rep_choice) && rep_choice >= 1 && rep_choice <= n_candidates) {
        manual_mapping <- rbind(manual_mapping, data.frame(
          shape_commune = current_shape,
          ehcvm_commune = candidates[rep_choice],
          score = candidate_scores[rep_choice],
          stringsAsFactors = FALSE
        ))
      } else {
        manual_mapping <- rbind(manual_mapping, data.frame(
          shape_commune = current_shape,
          ehcvm_commune = NA,
          score = NA,
          stringsAsFactors = FALSE
        ))
        cat("Aucune correspondance validée pour cette commune.\n")
      }
    }
  }
  
  # Combiner les mappings issus des deux groupes
  full_mapping <- rbind(mapping_A, manual_mapping)
  
  cat("\nMapping final validé :\n")
  print(full_mapping)
  
  if(nrow(full_mapping) == 0 || all(is.na(full_mapping$ehcvm_commune))) {
    cat("Aucune correspondance validée.\n")
    return(NA)
  }
  
  # Création de la clé de jointure dans data_SEN
  data_SEN$join_key <- sapply(data_SEN$ADM3_FR_clean, function(x) {
    idx <- which(full_mapping$shape_commune == x)
    if(length(idx) > 0) {
      return(full_mapping$ehcvm_commune[idx[1]])
    } else {
      return(NA)
    }
  })
  
  data_SEN_valid <- data_SEN[!is.na(data_SEN$join_key), ]
  valid_ehcvm <- full_mapping$ehcvm_commune[!is.na(full_mapping$ehcvm_commune)]
  data_to_merge <- data[data$commune_clean %in% valid_ehcvm, ]
  
  if(nrow(data_to_merge) == 0) {
    cat("Aucun enregistrement de la base ehcvm ne correspond aux communes validées.\n")
    return(NA)
  }
  
  # Réalisation de la fusion
  merged_data <- merge(
    data_to_merge, data_SEN_valid,
    by.x = "commune_clean", by.y = "join_key",
    all.x = TRUE, suffixes = c("_ehcvm", "_shp")
  )
  
  cat("\nFusion réalisée avec succès.\n")
  return(merged_data)
}

# ---------------------------------------------------
# Script principal : chargement, nettoyage et fusion
# ---------------------------------------------------
cat("Chargement des données...\n")
# Veuillez adapter les chemins en fonction de l'emplacement de vos fichiers
data_SEN <- sf::st_read("data/Senegal/shapefiles/sen_admbnda_adm3_anat_20240520.shp", quiet = TRUE)
data <- haven::read_dta("data/Senegal/ehcvm/ehcvm_individu_sen2021.dta")
data <- labelled::to_factor(data)

# Appliquer le nettoyage sur les colonnes de noms de communes
data <- data %>% mutate(commune_clean = nettoyage_commune(commune))
data_SEN <- data_SEN %>% mutate(ADM3_FR_clean = nettoyage_commune(ADM3_FR))

# Lancer la fusion interactive des bases
resultat_merge <- merge_bases_commune_interactive(data_SEN, data, threshold = 0.8, top_n = 5)

# Afficher le résultat final de la fusion
cat("\nRésultat de la fusion :\n")
print(resultat_merge)

# Pour avoir la base finale en STATA, il nous faut supprimer la variable geometry
resultat_merge <- resultat_merge %>%
  select(-geometry)

haven::write_dta(resultat_merge, "Outputs/data_final_SEN.dta")
