# app.R

# 0. Chargement des librairies --------------------------------------
library(shiny)
library(shinydashboard)
library(shinythemes)
library(dplyr)
library(plotly)
library(leaflet)
library(DT)
library(sf)
library(haven)       # pour read_dta()
library(stringr)
library(viridis)

# 1. Import et préparation des données ------------------------------

# 1.1 Bases finales (Stata)
Base_Principale <- read_dta("data/Base_Principale_finale.dta") %>%
  # s’assurer que adm1_ocha et adm2_ocha sont bien des caractères
  mutate(
    adm1_ocha = as.character(adm1_ocha),
    adm2_ocha = as.character(adm2_ocha),
    YEAR      = factor(YEAR),
    HHHSex    = as_factor(HHHSex)
  )

Base_MAD <- read_dta("data/Base_MAD_finale.dta")

# 1.2 Shapefiles nettoyés (avec clé adm?_ocha) et reprojection
adm1_shp_clean <- st_read("data/TD_adm1_clean.shp") %>%
  st_transform(crs = 4326) %>%
  mutate(adm1_ocha = as.character(adm1_ocha))

adm2_shp_clean <- st_read("data/TD_adm2_clean.shp") %>%
  st_transform(crs = 4326) %>%
  mutate(adm2_ocha = as.character(adm2_ocha))

# 1.3 Préparation de Base_MAD enrichie
mad_data <- Base_MAD %>%
  left_join(
    Base_Principale %>% select(ID, YEAR, ADMIN1Name, HHHSex, adm1_ocha),
    by = "ID"
  ) %>%
  filter(MAD_resp_age >= 6, MAD_resp_age <= 23) %>%
  mutate(
    across(starts_with("PCMAD"), as.numeric),
    n_groupes = rowSums(across(starts_with("PCMAD")), na.rm = TRUE),
    DDM        = factor(if_else(n_groupes >= 5, "Oui", "Non"),
                        levels = c("Non","Oui"))
  )

# 2. Interface utilisateur ------------------------------------------
ui <- dashboardPage(
  skin = "blue",
  dashboardHeader(title = "Dashboard Sécurité Alimentaire"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Filtres", icon = icon("filter"), startExpanded = TRUE,
               checkboxGroupInput("year", "Année",
                                  choices  = levels(Base_Principale$YEAR),
                                  selected = levels(Base_Principale$YEAR)
               ),
               selectInput("region", "Région",
                           choices  = sort(unique(Base_Principale$ADMIN1Name)),
                           selected = unique(Base_Principale$ADMIN1Name),
                           multiple = TRUE
               ),
               radioButtons("sex", "Genre du chef",
                            choices  = c("Tous", levels(Base_Principale$HHHSex)),
                            selected = "Tous"
               )
      ),
      menuItem("Indicateurs", icon = icon("chart-bar"),
               menuSubItem("SCA",    tabName = "tab_sca"),
               menuSubItem("rCSI",   tabName = "tab_rcsi"),
               menuSubItem("HDDS",   tabName = "tab_hdds"),
               menuSubItem("SERS",   tabName = "tab_sers"),
               menuSubItem("MAD",    tabName = "tab_mad"),
               menuSubItem("LhCSI",  tabName = "tab_lhcsi")
      ),
      menuItem("Comparaison", icon = icon("balance-scale"), tabName = "tab_compare"),
      menuItem("Cartes",      icon = icon("globe"),          tabName = "tab_map")
    )
  ),
  dashboardBody(
    shinytheme("flatly"),
    tabItems(
      tabItem("tab_sca",
              fluidRow(
                valueBoxOutput("sca_mean", width=4),
                valueBoxOutput("sca_sd",   width=4),
                valueBoxOutput("sca_high", width=4)
              ),
              fluidRow(
                box(plotlyOutput("sca_hist"), width=6, title="Distribution du SCA"),
                box(DTOutput("sca_cat"),      width=6, title="Répartition SCA (21/35)")
              )
      ),
      tabItem("tab_rcsi",
              fluidRow(
                box(plotlyOutput("rcsi_hist"), width=6, title="Distribution du rCSI"),
                box(DTOutput("rcsi_desc"),     width=6, title="Descriptif rCSI")
              )
      ),
      tabItem("tab_hdds",
              fluidRow(
                box(plotlyOutput("hdds_hist"), width=6, title="Distribution HDDS"),
                box(DTOutput("hdds_desc"),     width=6, title="Descriptif HDDS")
              )
      ),
      tabItem("tab_sers",
              fluidRow(
                box(plotlyOutput("sers_hist"), width=6, title="Distribution du SERS"),
                box(DTOutput("sers_cat"),      width=6, title="Catégories SERS")
              )
      ),
      tabItem("tab_mad",
              fluidRow(
                box(plotlyOutput("mad_prop"), width=6, title="Proportion MAD"),
                box(DTOutput("mad_by"),       width=6, title="MAD par année et genre")
              )
      ),
      tabItem("tab_lhcsi",
              fluidRow(
                box(DTOutput("lhcsi_desc"), width=12, title="Descriptif LhCSI")
              )
      ),
      tabItem("tab_compare",
              fluidRow(
                box(DTOutput("cont_compare"), width=12, title="Comparaison Continus")
              ),
              fluidRow(
                box(DTOutput("cat_compare"), width=12, title="Comparaison Catégoriels")
              )
      ),
      tabItem("tab_map",
              fluidRow(
                box(leafletOutput("map_sca"),  width=6, title="Carte SCA moyen"),
                box(leafletOutput("map_rcsi"), width=6, title="Carte rCSI moyen")
              ),
              fluidRow(
                box(leafletOutput("map_sers"), width=6, title="Carte SERS moyen"),
                box(leafletOutput("map_mad"),  width=6, title="Carte MAD (%)")
              )
      )
    )
  )
)

# 3. Serveur ---------------------------------------------------------
server <- function(input, output, session) {
  
  # 3.1 Filtrage de Base_Principale
  data_filt <- reactive({
    df <- Base_Principale
    if (input$sex != "Tous")
      df <- df %>% filter(HHHSex == input$sex)
    df %>%
      filter(YEAR %in% input$year,
             ADMIN1Name %in% input$region)
  })
  
  # 3.2 Filtrage de mad_data
  mad_filt <- reactive({
    mad_data %>%
      filter(YEAR %in% input$year,
             ADMIN1Name %in% input$region)
  })
  
  # Helper pour palettes sûres
  safe_pal <- function(x) {
    vals <- na.omit(x)
    dom  <- if(length(vals)) range(vals) else c(0,1)
    colorNumeric("viridis", domain = dom)
  }
  
  # --- SCA Outputs ---
  output$sca_mean <- renderValueBox({
    val <- round(mean(data_filt()$SCA, na.rm=TRUE),1)
    valueBox(val, "SCA moyen", icon=icon("utensils"), color="blue")
  })
  output$sca_sd <- renderValueBox({
    val <- round(sd(data_filt()$SCA, na.rm=TRUE),1)
    valueBox(val, "Écart-type", icon=icon("chart-line"), color="blue")
  })
  output$sca_high <- renderValueBox({
    df <- data_filt() %>%
      mutate(SCA_cat_21_35 = factor(SCA_cat_21_35, levels=c("Faible","Moyen","Élevé")))
    pct <- round(mean(df$SCA_cat_21_35=="Élevé", na.rm=TRUE)*100,1)
    valueBox(paste0(pct,"%"), "SCA élevé", icon=icon("star"), color="blue")
  })
  output$sca_hist <- renderPlotly({
    plot_ly(data_filt(), x=~SCA, type="histogram") %>%
      layout(xaxis=list(title="SCA"), yaxis=list(title="Effectif"))
  })
  output$sca_cat <- renderDT({
    data_filt() %>%
      mutate(SCA_cat_21_35 = factor(SCA_cat_21_35, levels=c("Faible","Moyen","Élevé"))) %>%
      count(SCA_cat_21_35) %>%
      mutate(pct = round(n/sum(n)*100,1)) %>%
      datatable(options=list(pageLength=5))
  })
  
  # --- Cartes SCA, rCSI, SERS, MAD ---
  output$map_sca <- renderLeaflet({
    reg <- data_filt() %>%
      group_by(adm1_ocha) %>%
      summarise(mean_SCA = mean(SCA, na.rm=TRUE), .groups="drop")
    map1 <- adm1_shp_clean %>% left_join(reg, by="adm1_ocha")
    pal  <- safe_pal(map1$mean_SCA)
    leaflet(map1) %>%
      addTiles() %>%
      addPolygons(fillColor=~pal(mean_SCA), weight=1, color="grey") %>%
      addLegend(pal=pal, values=map1$mean_SCA, title="SCA moyen")
  })
  
  output$map_rcsi <- renderLeaflet({
    reg <- data_filt() %>%
      group_by(adm1_ocha) %>%
      summarise(mean_rCSI = mean(rCSI, na.rm=TRUE), .groups="drop")
    map1 <- adm1_shp_clean %>% left_join(reg, by="adm1_ocha")
    pal  <- safe_pal(map1$mean_rCSI)
    leaflet(map1) %>%
      addTiles() %>%
      addPolygons(fillColor=~pal(mean_rCSI), weight=1, color="grey") %>%
      addLegend(pal=pal, values=map1$mean_rCSI, title="rCSI moyen")
  })
  
  output$map_sers <- renderLeaflet({
    reg <- data_filt() %>%
      group_by(adm1_ocha) %>%
      summarise(mean_SERS = mean(SERS, na.rm=TRUE), .groups="drop")
    map1 <- adm1_shp_clean %>% left_join(reg, by="adm1_ocha")
    pal  <- safe_pal(map1$mean_SERS)
    leaflet(map1) %>%
      addTiles() %>%
      addPolygons(fillColor=~pal(mean_SERS), weight=1, color="grey") %>%
      addLegend(pal=pal, values=map1$mean_SERS, title="SERS moyen")
  })
  
  output$map_mad <- renderLeaflet({
    reg <- mad_filt() %>%
      group_by(adm1_ocha) %>%
      summarise(pct_mad = mean(DDM == "Oui")*100, .groups="drop")
    map1 <- adm1_shp_clean %>% left_join(reg, by="adm1_ocha")
    pal  <- safe_pal(map1$pct_mad)
    leaflet(map1) %>%
      addTiles() %>%
      addPolygons(fillColor=~pal(pct_mad), weight=1, color="grey") %>%
      addLegend(pal=pal, values=map1$pct_mad, title="% MAD")
  })
  
  # ... (autres outputs inchangés : rCSI_desc, hdds, sers, mad tables, lhcsi, comparisons)
  
}

# 4. Lancement de l’application -------------------------------------
shinyApp(ui, server)
