
# Définir le fichier PDF (assurez-vous que le fichier existe à cet emplacement)
fichier1 <- "ehcvm_conso_bfa2021.csv"
fichier2 <- "calorie_conversion_wa_2021.csv"
# Lire le texte du PDF
fich1 <- read.csv(fichier1)
fich2 <- read.csv(fichier2)
# Afficher le texte extrait
str(fich1)
str(fich2)

