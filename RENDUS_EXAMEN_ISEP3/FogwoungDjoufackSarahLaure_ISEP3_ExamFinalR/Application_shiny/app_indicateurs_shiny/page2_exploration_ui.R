page2_exploration_ui <- tabPanel(
  title = "Exploration interactive",
  icon = icon("map"),
  fluidPage(
    tags$head(
      tags$style(HTML("
        .filter-panel {
          background: #f0f4f8;
          border-radius: 10px;
          padding: 20px;
          margin-bottom: 20px;
          box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }

        .leaflet-container {
          border-radius: 12px;
        }

        .tab-title {
          text-align: center;
          margin-top: 20px;
          margin-bottom: 30px;
          color: #003350;
        }

        .leaflet-container {
          height: 600px !important;
        }

        .data-table-section {
          margin-top: 30px;
          background: #ffffff;
          padding: 20px;
          border-radius: 12px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }

        .section-header {
          font-size: 1.3em;
          font-weight: 600;
          color: #0073C2;
          margin-bottom: 15px;
        }
      "))
    ),
    
    # --- Titre principal
    tags$h2("Exploration interactive des indicateurs", class = "tab-title"),
    
    # --- Panneau de filtres
    div(class = "filter-panel",
        fluidRow(
          column(6,
                 selectInput("niveau", "Niveau géographique :", 
                             choices = c("Région", "Département"),
                             selected = "Région")
          ),
          column(6,
                 selectInput("indicateur", "Indicateur à visualiser :", 
                             choices = c(
                               "Indice de consommation alimentaire (SCA)" = "mean_SCA",
                               "Indice de stratégies d’adaptation (rCSI)" = "mean_rSCI",
                               "Diversité alimentaire des ménages (HDDS)" = "mean_HDDS_score",
                               "Indice LhCSI" = "mean_LhCSI_score",
                               "Score de résilience structurelle (SERS)" = "mean_SERS_score"
                             ),
                             selected = "mean_SCA")
          )
        )
    ),
    
    # --- Carte interactive
    tags$h4("Visualisation cartographique", class = "section-header"),
    leafletOutput("carte", height = "600px"),
    
    # --- Tableau des valeurs
    div(class = "data-table-section",
        tags$h4("Données tabulaires par unité géographique", class = "section-header"),
        downloadButton("telechargement", "Télécharger le tableau", class = "btn btn-success"),
        br(), br(),
        DT::dataTableOutput("tableau")
    ),
    footer_ui()
  )
)
