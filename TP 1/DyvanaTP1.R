# Installer et charger le package pdftools
install.packages("pdftools")  # À exécuter une seule fois si le package n'est pas installé
library(pdftools)

# Définir le répertoire de travail (corrigé avec des guillemets)
setwd("C:/Users/DYVANA/Documents")

# Définir le fichier PDF (assurez-vous que le fichier existe à cet emplacement)
pdf_file <- "Rapport_Final_EHCVM_2021-2022_VF.pdf"

# Lire le texte du PDF
text <- pdf_text(pdf_file)

# Afficher le texte extrait
print(text)


