library(shiny)
library(leaflet)
library(DT)
library(fontawesome)

ui <- navbarPage(
  title = "Sécurité alimentaire - Tchad",
  theme = bslib::bs_theme(bootswatch = "flatly"),
  
  # === Onglet 1 : Page d'accueil ===
  tabPanel("Accueil",
           source("page1_accueil_ui.R")$value  
  ),
  
  # === Onglet 2 : Exploration interactive ===
  tabPanel("Exploration interactive",
           source("page2_exploration_ui.R")$value  
  ), 

  # === Onglet 3 : Documentation ===
  tabPanel("Documentation & Crédits",
           source("page3_documentation_ui.R")$value  
  ), 
)
