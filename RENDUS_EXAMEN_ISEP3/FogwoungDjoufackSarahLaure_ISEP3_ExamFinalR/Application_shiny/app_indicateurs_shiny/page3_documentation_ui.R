page3_documentation_ui <- tabPanel(
  title = "Documentation & Crédits",
  icon = icon("book"),
  fluidPage(
    tags$head(
      tags$style(HTML("
        .doc-section {
          background: #f8f9fa;
          padding: 30px;
          border-radius: 12px;
          margin-bottom: 30px;
        }

        .doc-section h3 {
          color: #005f87;
          margin-bottom: 20px;
        }

        .credit-box {
          background: white;
          border-left: 4px solid #0073C2;
          padding: 20px;
          border-radius: 10px;
          box-shadow: 0 2px 6px rgba(0,0,0,0.05);
        }

        .download-button {
          margin-top: 10px;
        }

        .variable-table {
          margin-top: 20px;
        }

        .section-footer {
          margin-top: 40px;
        }
      "))
    ),
    
    tabsetPanel(
      type = "tabs",
      
      # ░░░░░ GUIDE ░░░░░
      tabPanel("Guide d’utilisation",
               div(class = "doc-section",
                   tags$h2("📘 Guide d’utilisation de l’application"),
                   tags$p("Bienvenue dans cette application dédiée à l’analyse des indicateurs de sécurité alimentaire au Tchad. Elle a été développée dans le cadre d’un examen de fin d’année de la classe d'ISEP 3 à l'ENSAE de Dakar."),
                   tags$p("Elle permet de visualiser, comparer et documenter les indicateurs clés de manière interactive et intuitive."),
                   tags$hr()
               ),
               
               div(class = "doc-section",
                   tags$h3("1. Page d’accueil – Vue d’ensemble"),
                   tags$p("La première page présente une synthèse des indicateurs nationaux à travers des encadrés visuels."),
                   tags$ul(
                     tags$li("Chaque cadre présente un indicateur clé de sécurité alimentaire."),
                     tags$li("La valeur affichée correspond à la moyenne nationale."),
                     tags$li("Une icône permet d’identifier rapidement le type d’indicateur (consommation, résilience, etc.).")
                   ),
                   tags$img(src = "capture_accueil.png", style = "width:100%;border-radius:10px;margin-top:15px;"),
                   tags$small("Figure 1 – Aperçu de la page d’accueil")
               ),
               
               div(class = "doc-section",
                   tags$h3("2. Filtres – Personnalisation de l’affichage"),
                   tags$p("La deuxième page vous permet d’explorer les données par région ou département."),
                   tags$ul(
                     tags$li(tags$b("Niveau géographique :"), " choisissez entre Région et Département."),
                     tags$li(tags$b("Indicateur :"), " sélectionnez l’indicateur à cartographier (SCA, rCSI, HDDS, etc.)."),
                     tags$li("L’interface se met automatiquement à jour en fonction des sélections.")
                   ),
                   tags$img(src = "capture_filtres.png", style = "width:100%;border-radius:10px;margin-top:15px;"),
                   tags$small("Figure 2 – Menu de filtres interactifs")
               ),
               
               div(class = "doc-section",
                   tags$h3("3. Carte interactive"),
                   tags$p("La carte représente les zones géographiques en fonction de la valeur de l’indicateur choisi."),
                   tags$ul(
                     tags$li("Les couleurs indiquent l’intensité de la valeur."),
                     tags$li("Le survol d’une zone affiche une infobulle avec son nom et sa valeur."),
                     tags$li("La légende est automatiquement adaptée à l’indicateur choisi.")
                   ),
                   tags$img(src = "capture_carte_infobulle.png", style = "width:100%;border-radius:10px;margin-top:15px;"),
                   tags$small("Figure 3 – Carte avec infobulle contextuelle")
               ),
               
               div(class = "doc-section",
                   tags$h3("4. Tableau interactif des valeurs"),
                   tags$p("Le tableau situé sous la carte permet d’afficher les valeurs de l’indicateur pour chaque unité géographique."),
                   tags$ul(
                     tags$li("Possibilité de trier et rechercher dans le tableau."),
                     tags$li("Bouton de téléchargement pour exporter les données filtrées."),
                     tags$li("Colonnes : Nom de la zone et valeur de l’indicateur.")
                   ),
                   tags$img(src = "capture_tableau_download.png", style = "width:100%;border-radius:10px;margin-top:15px;"),
                   tags$small("Figure 4 – Tableau des valeurs avec fonction d’export")
               ),
               
               div(class = "doc-section",
                   tags$h3("5. Dictionnaire des variables"),
                   tags$p("Une section dédiée vous permet de mieux comprendre les variables utilisées."),
                   tags$ul(
                     tags$li("Choisissez une base de données dans le menu déroulant (Base_Principale ou Base_MAD)."),
                     tags$li("Un tableau affiche pour chaque variable son nom et sa description."),
                     tags$li("Tableau interactif avec filtres et recherche.")
                   ),
                   tags$img(src = "capture_dictionnaire.png", style = "width:100%;border-radius:10px;margin-top:15px;"),
                   tags$small("Figure 5 – Exemple du dictionnaire interactif")
               ),
               
               div(class = "doc-section",
                   tags$h3("6. Section Crédits & Téléchargements"),
                   tags$p("La dernière section fournit les informations sur l’encadrement, l’auteur, les contributeurs ainsi que les documents clés :"),
                   tags$ul(
                     tags$li("Lien vers le code source sur GitHub."),
                     tags$li("Téléchargement de l’énoncé, des bases de données, et du questionnaire."),
                     tags$li("Remerciements aux encadrants et collègues.")
                   ),
                   tags$img(src = "capture_credits.png", style = "width:100%;border-radius:10px;margin-top:15px;"),
                   tags$small("Figure 6 – Zone Crédits et fichiers à télécharger")
               )
      ),
      
      # ░░░░░ DICTIONNAIRE ░░░░░
      tabPanel("Dictionnaire des variables",
               div(class = "doc-section",
                   tags$h3("Dictionnaire des variables"),
                   tags$p("Ce travail a été réalisé dans le cadre de l’examen final du cours de Projet Statistique avec R."),
                   tags$p("Les données utilisées proviennent de deux bases principales :"),
                   tags$ul(
                     tags$li(tags$b("Base_Principale :"), " base principale d’indicateurs ménages."),
                     tags$li(tags$b("Base_MAD :"), " base spécifique aux enfants de moins de 5 ans.")
                   ),
                   selectInput("choix_base", "Choisir une base de données", 
                               choices = c("Base_Principale", "Base_MAD"), 
                               selected = "Base_Principale"),
                   DT::dataTableOutput("table_variables")
               )
      ),
      div(class = "section-footer",
          tags$h4("Téléchargements disponibles"),
          tags$p("Cliquez sur les liens ci-dessous pour télécharger les documents utiles :"),
          tags$ul(
            tags$li(tags$a(href = "Examen de projet statistique sur R_ISEP3_2025.docx", 
                           "Énoncé de l'examen", download = NA, target = "_blank")),
            tags$li(tags$a(href = "Base_Principale.dta", 
                           "Base_Principale.dta", download = NA)),
            tags$li(tags$a(href = "Base_MAD.dta", 
                           "Base_MAD.dta", download = NA)),
            tags$li(tags$a(href = "Questionnaire_Indicateurs.docx", 
                           "Questionnaire des indicateurs", download = NA))
          )
      ),
      
      # ░░░░░ CRÉDITS ░░░░░
      tabPanel("Crédits & Contributeurs",
               div(class = "doc-section",
                   tags$h3("Crédits & Contributeurs"),
                   div(class = "credit-box",
                       tags$p("Cette application a été développée dans le cadre de l’ examen final du cours Projet Statistique avec R,  dispensé à l'ISEP 3 par 
                               M. Aboubacar HEMA."),
      
                       tags$hr(),
                       
                       tags$p("L’objectif principal était d’appliquer les compétences acquises durant le semestre en R pour développer une application interactive sur la sécurité alimentaire au Tchad. "),
                       tags$p("Le projet intègre la manipulation de bases de données réelles, la production d’indicateurs statistiques, la cartographie interactive et la documentation technique."),
                       
                       tags$hr(),
                       
                       tags$h4("Encadrement pédagogique"),
                       tags$p("Ce projet a été conçu et encadré par :"),
                       tags$ul(
                         tags$li(tags$b("Aboubacar HEMA – "), "Statisticien, Research Analyst & Data Scientist, spécialisé dans la sécurité alimentaire, l’analyse de la pauvreté et le développement économique. "),
                         tags$li(tags$a(href = "https://github.com/Abson-dev", 
                                        "Aboubacar Hema", target = "_blank"))
                       ),
                       
                       tags$hr(),
                       
                       tags$h4("Développé par"),
                       tags$p(""),
                       tags$p("", tags$b("FOGWOUNG DJOUFACK Sarah-Laure"), ", étudiante en ISEP3 (Ingénieur Statisticien Économiste)."),
                       tags$p("📎 Mon compte GitHub : ", tags$a(href = "https://github.com/Sarahlaure", "Sarahlaure", target = "_blank")),
                       
                       tags$hr(),
                       
                       # Remerciements
                       tags$h4("Remerciements"),
                       tags$p("Je tiens à exprimer ma profonde gratitude à :"),
                       tags$ul(
                         tags$li(tags$b("M. Aboubacar HEMA"), " pour son encadrement rigoureux, ses explications claires et ses ressources précieuses."),
                         tags$li("Mes camarades de classe pour leur soutien, leurs échanges constructifs et leur entraide."),
                         tags$li("Mes aînés académiques pour leurs conseils, partages d’expérience et encouragements tout au long de ce projet.")
                       ),
                       
                       tags$p("Ce travail a été pour moi une expérience enrichissante tant sur le plan technique que pédagogique. Merci à tous ceux qui y ont contribué de près ou de loin.")                   )
               )
      )
      
    ),
   footer_ui()
  )
)
