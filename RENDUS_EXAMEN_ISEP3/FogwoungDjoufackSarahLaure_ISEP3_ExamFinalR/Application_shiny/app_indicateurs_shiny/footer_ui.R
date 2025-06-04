footer_ui <- function() {
  tags$footer(class = "footer",
              tags$p(
                "Réalisé par ",
                tags$strong("FOGWOUNG DJOUFACK Sarah-Laure"),
                " — Étudiante en ",
                tags$strong("ISEP3 à l'ENSAE de Dakar")
              ),
              tags$p(
                "Examen de projet statistique avec R: ",
                tags$em("Analyse de quelques indicateurs de sécurité alimentaire au Tchad")
              ),
              tags$p(
                "🔗 ",
                tags$a(href = "https://github.com/Sarahlaure", target = "_blank",
                       "Profil GitHub : github.com/Sarahlaure")
              )
  )
}
