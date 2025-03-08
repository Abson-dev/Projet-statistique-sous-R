library(dplyr)

# Récupérer les données
data_BEN <- sf::st_read("data/Benin/shapefiles/geoBoundaries-BEN-ADM2.shp")
data_BEN_Pcode <- readxl::read_excel("data/Benin/shapefiles/ben_adminboundaries_tabulardata.xlsx", 
                                     sheet = "ADM2")
data <- haven::read_dta("data/Benin/ehcvm/ehcvm_individu_ben2021.dta")

# Afficher les labels : Les communes du bénin sont codés
data <- labelled::to_factor(data)

# Remplacer les les termes ÉÈéè par e
data$commune <- gsub("[ÉÈéè]", "e", data$commune)

# Mettre en lower pour le merge après
data <- data %>%
  mutate(commune = tolower(commune))

# Mettre en lower pour le merge
data_BEN <- data_BEN %>%
  mutate(shapeName = tolower(shapeName))

# Mettre en lower pour le merge
data_BEN_Pcode <- data_BEN_Pcode %>%
  mutate(ADM2_FR = tolower(ADM2_FR))

# Faire le merge pour le shp final
data_BEN_fin <- merge(data_BEN,data_BEN_Pcode, by.x="shapeName", by.y="ADM2_FR")

# Faire le merge final pour la récupération du code final
data_merge_BEN <- right_join(data_BEN_fin, data , by = c("shapeName" = "commune"))

# Pour avoir la base finale en STATA, il nous faut supprimer la variable geometry
data_merge_BEN <- sf::st_drop_geometry(data_merge_BEN)

haven::write_dta(data_merge_BEN, "Outputs/data_final_BEN.dta")
