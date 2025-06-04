library(dplyr)
library(readr)
library(sf)
library(leaflet)
library(DT)
library(shinyWidgets)
library(slickR)


server <- function(input, output, session) {
  
  data_geo <- reactive({
    if (input$niveau == "Région") {
      shp <- st_read("data/tcd_admbnda_adm1_20250212_AB.shp", quiet = TRUE) %>%
        rename(code_region = ADM1_PCODE)
      indicateurs <- read_csv("data/indicateurs_region.csv", show_col_types = FALSE)
      shp <- left_join(shp, indicateurs, by = "code_region")
    } else {
      shp <- st_read("data/tcd_admbnda_adm2_20250212_AB.shp", quiet = TRUE) %>%
        rename(code_departement = ADM2_PCODE)
      indicateurs <- read_csv("data/indicateurs_departement.csv", show_col_types = FALSE)
      shp <- left_join(shp, indicateurs, by = "code_departement")
    }
    shp <- st_make_valid(shp)
    st_transform(shp, crs = 4326)
  })
  
  pal <- reactive({
    colorNumeric("YlGnBu", domain = data_geo()[[input$indicateur]], na.color = "transparent")
  })
  
  # 📄 Télécharger l’énoncé
  output$download_enonce <- downloadHandler(
    filename = function() {
      "Enonce_Projet_Statistique_R.pdf"
    },
    content = function(file) {
      file.copy("data/Questionnaire_Indicateurs.docx", file)
    }
  )
  
  # 📑 Dictionnaire des variables (extraits pertinents)
  dict_base_principale <- data.frame(
    Variable = c(        "ID", "SvyDate", "YEAR", "SvyMonth", "SURVEY", "ADMIN0Name", "adm0_ocha", "ADMIN1Name", "adm1_ocha",
                         "ADMIN2Name", "adm2_ocha", "HHSize", "HHSize05M", "HHSize23M", "HHSize59M", "HHSize5114M",
                         "HHSize1549M", "HHSize5064M", "HHSize65AboveM", "HHSize05F", "HHSize23F", "HHSize59F", "HHSize5114F",
                         "HHSize1549F", "HHSize5064F", "HHSize65AboveF", "HHHSex", "HHHAge", "HHHEdu", "HHHMainActivity",
                         "HHHMatrimonial", "HHSourceIncome", "HDDS_CH", "HDDSStapCer", "HDDSStapRoot", "HDDSPulse",
                         "HDDSVegOrg", "HDDSVegGre", "HDDSVegOth", "HDDSFruitOrg", "HDDSFruitOth", "HDDSPrMeatF",
                         "HDDSPrMeatO", "HDDSPrFish", "HDDSPrEgg", "HDDSDairy", "HDDSSugar", "HDDSFat", "HDDSCond", "HDDSPrMeat",
                         "FCSStap", "FCSStapSRf", "FCSPulse", "FCSPulseSRf", "FCSDairy", "FCSDairySRf", "FCSPr", "FCSPrSRf",
                         "FCSPrMeatF", "FCSPrMeatO", "FCSPrFish", "FCSPrEgg", "FCSVeg", "FCSVegSRf", "FCSVegOrg", "FCSVegGre",
                         "FCSFruit", "FCSFruitSRf", "FCSFruitOrg", "FCSFat", "FCSFatSRf", "FCSSugar", "FCSSugarSRf", "FCSCond",
                         "FCSCondSRf", "LhCSIStress1", "LhCSIStress2", "LhCSIStress3", "LhCSIStress4", "LhCSICrisis1",
                         "LhCSICrisis2", "LhCSICrisis3", "LhCSIEmergency1", "LhCSIEmergency2", "LhCSIEmergency3", "rCSILessQlty",
                         "rCSIBorrow", "rCSIMealSize", "rCSIMealAdult", "rCSIMealNb", "SERSRebondir", "SERSRevenue",
                         "SERSMoyen", "SERSDifficultes", "SERSSurvivre", "SERSFamAmis", "SERSPoliticiens", "SERSLecons",
                         "SERSPreparerFuture", "SERSAvertissementEven"),
    Description = c(
      "Identifiant unique du ménage",
      "Date d'enquête du ménage",
      "Année de réalisation de l'enquête",
      "Mois de réalisation de l'enquête",
      "Code d'identification de l'enquête",
      "Nom du pays",
      "Code OCHA du pays",
      "Nom de la région administrative",
      "Code OCHA de la région",
      "Nom du département administratif",
      "Code OCHA du département",
      "Taille totale du ménage",
      "Nombre d'enfants de 0 à 5 mois (garçons)",
      "Nombre d'enfants de 6 à 23 mois (garçons)",
      "Nombre d'enfants de 24 à 59 mois (garçons)",
      "Nombre de garçons de 5 à 14 ans",
      "Nombre d'hommes de 15 à 49 ans",
      "Nombre d'hommes de 50 à 64 ans",
      "Nombre d'hommes de 65 ans et plus",
      "Nombre de filles de 0 à 5 mois",
      "Nombre de filles de 6 à 23 mois",
      "Nombre de filles de 24 à 59 mois",
      "Nombre de filles de 5 à 14 ans",
      "Nombre de femmes de 15 à 49 ans",
      "Nombre de femmes de 50 à 64 ans",
      "Nombre de femmes de 65 ans et plus",
      "Sexe du chef de ménage",
      "Âge du chef de ménage",
      "Niveau d'éducation du chef de ménage",
      "Activité principale du chef de ménage",
      "Statut matrimonial du chef de ménage",
      "Sources principales de revenu du ménage",
      "Score de diversité alimentaire des enfants",
      "Consommation de céréales de base",
      "Consommation de racines et tubercules",
      "Consommation de légumineuses",
      "Consommation de légumes à feuilles foncées",
      "Consommation de légumes verts",
      "Consommation d'autres légumes",
      "Consommation de fruits riches en vitamine A",
      "Consommation d'autres fruits",
      "Consommation de viande rouge",
      "Consommation d'autres viandes",
      "Consommation de poisson",
      "Consommation d'œufs",
      "Consommation de produits laitiers",
      "Consommation de sucre",
      "Consommation de graisses et huiles",
      "Consommation de condiments",
      "Consommation totale de viande",
      "Score alimentaire pour les céréales",
      "Score pondéré des céréales",
      "Score alimentaire pour les légumineuses",
      "Score pondéré des légumineuses",
      "Score alimentaire pour les produits laitiers",
      "Score pondéré des produits laitiers",
      "Score alimentaire pour les protéines animales",
      "Score pondéré des protéines animales",
      "Score alimentaire pour la viande rouge",
      "Score alimentaire pour autres viandes",
      "Score alimentaire pour poisson",
      "Score alimentaire pour œufs",
      "Score alimentaire pour légumes",
      "Score pondéré des légumes",
      "Score légumes riches en vitamine A",
      "Score légumes verts",
      "Score alimentaire pour fruits",
      "Score pondéré des fruits",
      "Score fruits riches en vitamine A",
      "Score alimentaire pour graisses",
      "Score pondéré des graisses",
      "Score alimentaire pour sucre",
      "Score pondéré du sucre",
      "Score alimentaire pour condiments",
      "Score pondéré des condiments",
      "Stratégie de stress 1 (LhCSI)",
      "Stratégie de stress 2 (LhCSI)",
      "Stratégie de stress 3 (LhCSI)",
      "Stratégie de stress 4 (LhCSI)",
      "Stratégie de crise 1 (LhCSI)",
      "Stratégie de crise 2 (LhCSI)",
      "Stratégie de crise 3 (LhCSI)",
      "Stratégie d'urgence 1 (LhCSI)",
      "Stratégie d'urgence 2 (LhCSI)",
      "Stratégie d'urgence 3 (LhCSI)",
      "Réduction de la qualité des repas (rCSI)",
      "Emprunt de nourriture ou d’argent (rCSI)",
      "Réduction de la taille des repas (rCSI)",
      "Adultes mangeant moins que les enfants (rCSI)",
      "Réduction du nombre total de repas (rCSI)",
      "Capacité à rebondir après un choc (SERS)",
      "Capacité à générer des revenus (SERS)",
      "Accès aux moyens de subsistance (SERS)",
      "Difficulté à faire face aux problèmes (SERS)",
      "Capacité de survie face aux chocs (SERS)",
      "Soutien familial ou communautaire (SERS)",
      "Aide des décideurs politiques (SERS)",
      "Leçons tirées de situations passées (SERS)",
      "Préparation pour le futur (SERS)",
      "Réception d'avertissements précoces (SERS)"
    )
  )
  
  dict_base_mad <- data.frame(
    Variable = c("MAD_sex", "MAD_resp_age", "EverBreastF", "PCIYCBreastF", "PCIYCInfFormNb",
                 "PCIYCDairyMiNb", "PCIYCDairyYoNb", "PCIYCStapPoNb", "PCMADStapCer",
                 "PCMADVegOrg", "PCMADStapRoo", "PCMADVegGre", "PCMADFruitOrg", "PCMADVegFruitOth",
                 "PCMADPrMeatO", "PCMADPrMeatF", "PCMADPrEgg", "PCMADPrFish", "PCMADPulse",
                 "PCMADDairy", "PCMADFatRpalm", "PCMADSnfChild", "PCMADSnfPowd", "PCMADSnfLns",
                 "PCIYCMeals", "ID"),
    Description = c(
      "Sexe de l’enfant concerné par la section MAD.",
      "Âge du répondant principal pour la section MAD.",
      "Indique si l’enfant a déjà été allaité au sein à un moment quelconque.",
      "Indique si l’enfant a été allaité au sein la veille de l’enquête.",
      "Nombre de fois que l’enfant a consommé du lait maternisé ou en poudre la veille.",
      "Nombre de fois que l’enfant a consommé du lait liquide animal la veille.",
      "Nombre de fois que l’enfant a consommé du yaourt la veille.",
      "Nombre de fois que l’enfant a consommé des pommes de terre ou autres féculents similaires la veille.",
      "Indique si l’enfant a consommé des céréales (ex : riz, mil, sorgho, maïs) la veille.",
      "Indique si l’enfant a consommé des légumes orange (ex : carottes, patate douce) la veille.",
      "Indique si l’enfant a consommé des racines et tubercules la veille.",
      "Indique si l’enfant a consommé des légumes verts foncés (ex : feuilles de manioc) la veille.",
      "Indique si l’enfant a consommé des fruits orange (ex : mangue, papaye) la veille.",
      "Indique si l’enfant a consommé d’autres légumes ou fruits non cités précédemment la veille.",
      "Indique si l’enfant a consommé de la viande d’animaux sauvages ou de brousse la veille.",
      "Indique si l’enfant a consommé de la viande d’animaux domestiques la veille.",
      "Indique si l’enfant a consommé des œufs la veille.",
      "Indique si l’enfant a consommé du poisson la veille.",
      "Indique si l’enfant a consommé des légumineuses (ex : haricots, lentilles) la veille.",
      "Indique si l’enfant a consommé des produits laitiers (lait, yaourt) la veille.",
      "Indique si l’enfant a consommé des matières grasses, notamment l’huile de palme rouge, la veille.",
      "Indique si l’enfant a consommé des aliments thérapeutiques prêts à l'emploi (RUTF) la veille.",
      "Indique si l’enfant a consommé du lait thérapeutique en poudre (F75, F100) la veille.",
      "Indique si l’enfant a consommé des suppléments liquides nutritifs (LNS) la veille.",
      "Nombre total de repas que l’enfant a consommés la veille.",
      "Identifiant unique du ménage pour relier à d'autres sections."
    )
  )
  
  output$table_variables <- DT::renderDT({
    if (input$choix_base == "Base_Principale") {
      datatable(dict_base_principale,
                options = list(pageLength = 10, autoWidth = TRUE),
                rownames = FALSE)
    } else {
      datatable(dict_base_mad,
                options = list(pageLength = 10, autoWidth = TRUE),
                rownames = FALSE)
    }
  })
  
  
  
  output$carte <- renderLeaflet({
    df <- data_geo()
    ind <- input$indicateur
    nom_zone <- if (input$niveau == "Région") "region" else "departement"
    
    leaflet(df) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = 18.7322, lat = 15.4542, zoom = 6) %>%  # Tchad
      addPolygons(
        fillColor = ~pal()(get(ind)),
        fillOpacity = 0.8,
        color = "white",
        weight = 1,
        smoothFactor = 0.3,
        label = ~ifelse(
          !is.na(get(ind)),
          paste0(get(nom_zone), " : ", round(get(ind), 2)),
          NA
        ),
        highlightOptions = highlightOptions(
          weight = 2,
          color = "#666",
          fillOpacity = 0.9,
          bringToFront = TRUE
        )
      ) %>%
      addLegend("bottomright", pal = pal(), values = df[[ind]], title = input$indicateur)
  })
  
  output$tableau <- renderDT({
    df <- data_geo() %>% st_drop_geometry()
    nom_col <- if (input$niveau == "Région") "region" else "departement"
    indicateur <- input$indicateur
    
    df %>%
      select(nom = all_of(nom_col), valeur = all_of(indicateur)) %>%
      arrange(desc(valeur)) %>%
      datatable(
        rownames = FALSE,
        colnames = c("Nom", "Valeur"),
        options = list(pageLength = 10)
      )
  })
  
  
  output$telechargement <- downloadHandler(
    filename = function() {
      paste0("tableau_", tolower(input$niveau), "_", input$indicateur, ".csv")
    },
    content = function(file) {
      df <- data_geo() %>% sf::st_drop_geometry()
      nom_col <- if (input$niveau == "Région") "region" else "departement"
      indicateur <- input$indicateur
      df %>%
        select(nom = all_of(nom_col), valeur = all_of(indicateur)) %>%
        arrange(desc(valeur)) %>%
        readr::write_csv(file)
    }
  )
}