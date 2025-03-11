library(dplyr)
library(fuzzyjoin)
library(sf)
library(readxl)
library(haven)
library(labelled)

# 1. Charger les données
data_BEN <- sf::st_read("data/Benin/shapefiles/geoBoundaries-BEN-ADM2.shp")
data_BEN_Pcode <- readxl::read_excel("data/Benin/shapefiles/ben_adminboundaries_tabulardata.xlsx", 
                                     sheet = "ADM2")
data <- haven::read_dta("data/Benin/ehcvm/ehcvm_individu_ben2021.dta")
# Afficher les labels : Les communes du bénin sont codés
data <- labelled::to_factor(data)

# 2. Préparer les données en mettant les chaînes de caractères en minuscules et en remplaçant certains caractères
data <- data %>%
  mutate(commune = tolower(gsub("[ÉÈéè]", "e", commune)))

data_BEN <- data_BEN %>%
  mutate(shapeName = tolower(shapeName))

data_BEN_Pcode <- data_BEN_Pcode %>%
  mutate(ADM2_FR = tolower(ADM2_FR))

# 3. Merge de la base spatiale avec le code administratif
data_BEN_fin <- merge(data_BEN, data_BEN_Pcode, by.x = "shapeName", by.y = "ADM2_FR")

# 4. Jointure floue entre data_BEN_fin et data via la distance de Levenshtein
# On utilise stringdist_left_join pour calculer la distance entre 'shapeName' et 'commune'.
# Le paramètre max_dist peut être ajusté en fonction de votre tolérance
data_merge_BEN <- fuzzyjoin::stringdist_left_join(
  data_BEN_fin, data, 
  by = c("shapeName" = "commune"), 
  method = "lv", 
  max_dist = 3,
  distance_col = "distance"
)

# 5. Pour chaque commune de 'data', ne conserver que la correspondance ayant la plus petite distance
data_merge_BEN <- data_merge_BEN %>%
  group_by(commune) %>%
  filter(distance == min(distance)) %>%
  ungroup()

# 6. Supprimer la variable 'geometry' pour préparer la base finale au format Stata
data_merge_BEN <- sf::st_drop_geometry(data_merge_BEN)
data_merge_BEN <- data_merge_BEN %>% select_if(~ !is.list(.))

# 7. Sauvegarder le résultat au format Stata
haven::write_dta(data_merge_BEN, "Outputs/data_final_BEN.dta")
