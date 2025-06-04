# Page d'accueil : Indicateurs de sécurité alimentaire au Tchad
library(slickR)

page1_accueil_ui <- fluidPage(
  tags$head(
    tags$style(HTML("
 :root {
      --primary: #0073C2;
      --accent: #dc3545;
      --light: #f8f9fa;
      --background: #fdfdfd;
      --text-dark: #2c3e50;
      --text-muted: #6c757d;
    }

    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: var(--background);
    }

    .header-container {
      display: grid;
      grid-template-columns: auto 1fr auto;
      align-items: center;
      gap: 20px;
      padding: 30px 0;
      background: linear-gradient(to right, var(--primary), #003350);
      color: white;
    }

    .title-box {
      text-align: center;
      padding: 20px;
      background: rgba(255,255,255,0.1);
      border-radius: 15px;
      backdrop-filter: blur(5px);
    }

    .stat-row {
      display: flex;
      justify-content: center;
      flex-wrap: wrap;
      gap: 20px;
      margin-top: 30px;
    }

    .stat-card {
      flex: 1 1 200px;
      max-width: 220px;
      background: white;
      border-radius: 15px;
      padding: 20px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.08);
      border-left: 4px solid var(--primary);
      transition: 0.3s ease;
      text-align: center;
    }

    .stat-card:hover {
      transform: translateY(-5px);
    }

    .stat-icon {
      font-size: 2.3em;
      color: var(--primary);
      margin-bottom: 13px;
    }

    .emphasis-number {
      font-size: 2.8em;
      font-weight: 800;
      color: #003350;
      margin: 8px 0;
    }

    .stat-label {
      font-size: 1em;
      font-weight: 600;
      color: var(--text-dark);
    }

    .section-title {
      margin-top: 40px;
      color: #005f87;
      text-align: center;
      font-weight: 700;
      letter-spacing: 0.5px;
    }

    .description-section {
      background: var(--light);
      border-radius: 15px;
      padding: 30px;
      margin-top: 30px;
      font-size: 1em;
    }

    .description-section p {
      line-height: 1.7;
      color: var(--text-dark);
      font-size: 1.05em;
      margin-bottom: 15px;
    }

    .description-section a {
      font-weight: bold;
      color: var(--primary);
      text-decoration: none;
    }
    
    .page-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}
    
    .content-wrap {
  flex: 1;
}

.footer {
  background-color: #003350;
  color: white;
  padding: 25px 15px;
  text-align: center;
  font-size: 0.95em;
  border-top: 3px solid #0073C2;
}

.footer a {
  color: #a8e6ff;
  text-decoration: underline;
}

.footer a:hover {
  color: #ffffff;
  text-decoration: none;
}

    .description-section a:hover {
      text-decoration: underline;
    }

    /* Onglets tabsetPanel */
    .nav-tabs {
      border-bottom: 2px solid #dee2e6;
    }

    .nav-tabs > li > a {
      background-color: white;
      border: 1px solid transparent;
      border-radius: 5px 5px 0 0;
      padding: 10px 20px;
      color: #555;
      transition: 0.3s ease;
    }

    .nav-tabs > li.active > a,
    .nav-tabs > li.active > a:focus,
    .nav-tabs > li.active > a:hover {
      color: var(--primary);
      background-color: var(--light);
      border-color: #dee2e6 #dee2e6 transparent;
      border-bottom: 2px solid white;
      font-weight: bold;
    }

    .tab-content {
      background-color: white;
      padding: 30px;
      border: 1px solid #dee2e6;
      border-top: none;
      border-radius: 0 0 8px 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.04);
      margin-bottom: 20px;
    }
    
    

    @media (max-width: 768px) {
      .header-container {
        grid-template-columns: 1fr;
        text-align: center;
      }

      .stat-row {
        flex-direction: column;
        align-items: center;
      }

      .stat-card {
        width: 90%;
        max-width: 400px;
      }

      .nav-tabs > li > a {
        padding: 8px 12px;
        font-size: 0.9em;
      }
    }
  "))
  ),
  
  div(class = "container-fluid",
      
      # --- En-tête ---
      div(class = "header-container",
          tags$img(src = "flag_tchad.png", style = "height: 70px; margin-left: 30px;"),
          div(class = "title-box",
              tags$h1("Indicateurs de sécurité alimentaire au Tchad", style = "margin: 0; letter-spacing: 1px;"),
              tags$h3("Application de visualisation statistique", style = "margin: 10px 0; font-weight: 300;")
          ),
          tags$img(src = "flag_tchad.png", style = "height: 70px; margin-right: 30px; opacity: 0.9;")
      ),
      
      # --- Statistiques nationales ---
      div(class = "stat-row",
          div(class = "stat-card",
              icon("heartbeat", class = "stat-icon"),
              div(class = "emphasis-number", "47.3"),
              div(class = "stat-label", "Indice de consommation alimentaire (SCA) national")
          ),
          div(class = "stat-card",
              icon("burn", class = "stat-icon"),
              div(class = "emphasis-number", "5.8"),
              div(class = "stat-label", "Indice de stratégies d’adaptation (rCSI) national")
          ),
          div(class = "stat-card",
              icon("utensils", class = "stat-icon"),
              div(class = "emphasis-number", "5.9"),
              div(class = "stat-label", "Diversité alimentaire des ménages (HDDS) nationale")
          ),
          div(class = "stat-card",
              icon("chart-bar", class = "stat-icon"),
              div(class = "emphasis-number", "0.6"),
              div(class = "stat-label", "Indice LhCSI national")
          ),
          div(class = "stat-card",
              icon("shield-alt", class = "stat-icon"),
              div(class = "emphasis-number", "35.5"),
              div(class = "stat-label", "Score de résilience structurelle (SERS) national")
          )
      ),
      
      # --- Deux colonnes côte à côte ---
      fluidRow(
        column(
          width = 7,
          div(class = "description-section",
              tags$h3("🎯 Indicateurs clés", class = "section-title"),
              tabsetPanel(
                id = "onglets_indicateurs",
                type = "tabs",
                
                tabPanel("️ SCA",
                         tags$div(style = "padding: 20px;",
                                  tags$p("Le score de consommation alimentaire (SCA) est un score composite basé sur la diversité alimentaire des ménages, la fréquence des repas et l'importance nutritionnelle relative des aliments consommés.Le module SCA demande aux répondants combien de jours, au cours des 7 derniers jours, la plupart des membres de leur ménage (+50%) ont consommé chacun des produits/groupes alimentaires, à l'intérieur ou à l'extérieur de leur domicile."),
                                  tags$p(tags$b("Méthode de calcul : "),
                                         "Les aliments sont regroupés en 8 groupes. Chaque groupe est pondéré selon son importance nutritionnelle. Le score est obtenu en multipliant la fréquence par le poids de chaque groupe, puis en faisant la somme."),
                                  tags$p(tags$b("Interprétation : "),
                                         "Pour le seuil 21/35, un score inférieur à 21 indique une consommation pauvre, entre 21 et 35 une consommation limite, et au-dessus de 35 une consommation acceptable. Ces seuils peuvent être adaptés selon le contexte local.")
                         )
                ),
                
                tabPanel("️ rCSI",
                         tags$div(style = "padding: 20px;",
                                  tags$p("L'indice réduit des stratégies de survie, basé sur la consommation, est utilisé pour évaluer le niveau de stress d'un ménage dû à une pénurie alimentaire. Il mesure les stratégies comportementales que les gens appliquent lorsqu'ils n'ont pas accès à suffisamment de nourriture ou lorsqu'ils prévoient une diminution de la sécurité alimentaire."),
                                  tags$p(tags$b("Méthode de calcul : "),
                                         "5 stratégies sont évaluées, chacune avec une pondération. Le score est la somme des fréquences multipliées par ces pondérations."),
                                  tags$p(tags$b("Interprétation : "),
                                         "Un score élevé traduit une insécurité alimentaire accrue.")
                         )
                ),
                
                tabPanel(" HDDS",
                         tags$div(style = "padding: 20px;",
                                  tags$p("Le Score de Diversité Alimentaire des Ménages (HDDS) mesure combien de groupes alimentaires différents ont été consommés au cours des dernières 24 heures."),
                                  tags$p(tags$b("Méthode de calcul : "),
                                         "Chaque groupe consommé vaut 1 point (sur 12 possibles)."),
                                  tags$p(tags$b("Interprétation : "),
                                         "Un score élevé reflète une meilleure diversité alimentaire, souvent liée à une meilleure situation économique.")
                         )
                ),
                
                tabPanel(" LhCSI / LCS-FS",
                         tags$div(style = "padding: 20px; line-height: 1.6; font-size: 16px;",
                                  
                                  tags$p("L’indicateur des stratégies d’adaptation des moyens de subsistance (LCS) – version sécurité alimentaire (LCS-FS) – mesure la capacité des ménages à faire face à un manque de nourriture en adoptant des comportements susceptibles d’affecter leur stabilité future. Il s’agit d’un outil simple et corrélé à d’autres mesures de vulnérabilité."),
                                  
                                  tags$br(),
                                  tags$h5(" Méthode de calcul :"),
                                  tags$p("Le LCS-FS repose sur une liste de stratégies adoptées par les ménages au cours des 30 derniers jours pour maintenir l'accès à l'alimentation malgré les chocs subis. Chaque stratégie est classée selon trois niveaux de sévérité :"),
                                  tags$ul(
                                    tags$li(tags$b("Stress : "), "épuisement des économies, vente de petits biens, emprunts non urgents."),
                                    tags$li(tags$b("Crise : "), "vente d’actifs productifs, réduction des dépenses de santé ou d’éducation."),
                                    tags$li(tags$b("Urgence : "), "vente de l’unique maison ou animal reproducteur, mendicité, pillage.")
                                  ),
                                  tags$p("Chaque stratégie est associée à une pondération selon sa gravité. Le score total correspond à la somme pondérée des stratégies activées par le ménage."),
                                  
                                  tags$br(),
                                  tags$h5("Interprétation :"),
                                  tags$p("Plus le score est élevé, plus le ménage est en situation d’insécurité alimentaire grave. L’adoption successive de stratégies de stress, de crise, puis d’urgence traduit une incapacité croissante à faire face à la crise sans compromettre son avenir."),
                                  tags$p("Le LCS-FS permet également une classification des ménages selon les stratégies activées au cours des 30 derniers jours ou épuisées dans les 12 derniers mois. Ainsi :"),
                                  tags$ul(
                                    tags$li("Un ménage ayant utilisé uniquement des stratégies de ", tags$b("stress"), " est considéré en situation modérée."),
                                    tags$li("L’usage de stratégies de ", tags$b("crise"), " indique une détérioration notable."),
                                    tags$li("L’usage de stratégies d’", tags$b("urgence"), " reflète une insécurité alimentaire extrême.")
                                  ),
                                  
                                  tags$br()
                         )
                ),
                
                tabPanel("SERS",
                         tags$div(style = "padding: 20px; line-height: 1.6; font-size: 16px;",
                                  
                                  tags$p("Le Score de Résilience Structurelle (SERS) évalue la capacité perçue des ménages à faire face aux chocs alimentaires et à préserver leur stabilité à long terme. Il s’appuie sur une auto-évaluation de leurs ressources, de leur capital social, et de leur aptitude à anticiper les crises."),
                                  
                                  tags$br(),
                                  tags$h5("Méthode de calcul :"),
                                  tags$p("Le SERS est dérivé de 10 affirmations auxquelles les répondants réagissent sur une échelle de Likert à 5 points (de « pas du tout d’accord » à « tout à fait d’accord »)."),
                                  tags$p("Chaque réponse est convertie en score numérique. Les 10 scores sont agrégés puis normalisés entre 0 et 100 à l’aide d’une méthode min-max."),
                                  
                                  tags$br(),
                                  tags$h5("Interprétation des résultats :"),
                                  tags$p("Le score obtenu reflète la perception du niveau de résilience d’un ménage. Il est ensuite classé en trois catégories :"),
                                  tags$ul(
                                    tags$li(tags$b("SERS < 33 :"), " résilience faible"),
                                    tags$li(tags$b("33 ≤ SERS < 66 :"), " résilience moyenne"),
                                    tags$li(tags$b("SERS ≥ 66 :"), " résilience élevée")
                                  ),
                                  tags$p("Cette catégorisation permet d’identifier les ménages les plus vulnérables et d’orienter les interventions de manière ciblée.")
                         )
                )
                
              )
          )
        ),
        
        column(
          width = 5,
          div(class = "description-section",
              tags$h3("🧭 Exploration interactive des données", class = "section-title"),
              tags$p("La section interactive permet de visualiser dynamiquement les indicateurs au niveau régional ou départemental. Elle inclut :"),
              tags$ul(
                tags$li("Une carte interactive avec filtres géographiques"),
                tags$li("Un choix d’indicateur à afficher"),
                tags$li("Un tableau de données triable et exportable"),
                tags$li("Une expérience utilisateur fluide et intuitive")
              )
          )
        )
      ),
  footer_ui()
)
)