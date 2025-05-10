
#' -------------------------------------------------------------------
#' Script II 7 Régime alimentaire minimum acceptable (MAD)
#' Ce script permet de :
#'   a) Créer une variable nombre de groupes alimentaires consommés
#'   b) Créer une variable DDM = 1 si ≥5 groupes consommés
#'   c) Calculer la proportion d’enfants 6–23 mois avec MAD
#'   d) Statistiques descriptives de DDM par sexe du chef et par année
#' 
#' -------------------------------------------------------------------

# 1. Assemblage des données et filtrage des 6–23 mois --------------
# On joint Base_MAD et Base_Principale (ID commun) pour récupérer YEAR et HHHSex
mad <- Base_MAD %>%
  left_join(
    Base_Principale %>% select(ID, YEAR, HHHSex),
    by = "ID"
  ) %>%
  # Filtrer les enfants de 6 à 23 mois inclus
  filter(MAD_resp_age >= 6, MAD_resp_age <= 23)

# 2. Création du nombre de groupes consommés (a) --------------------
# Variables PCMAD… indiquant consommation (1=oui, 0=non)
group_vars <- c(
  "PCMADStapCer",   # céréales & dérivés
  "PCMADStapRoo",   # tubercules & racines
  "PCMADPulse",     # légumineuses/pulses
  "PCMADVegOrg",    # légumes organiques
  "PCMADVegGre",    # légumes verts
  "PCMADFruitOrg",  # fruits organiques
  "PCMADVegFruitOth", # autres fruits & légumes
  "PCMADPrMeatF",   # viande fraîche
  "PCMADPrMeatO",   # viande transformée
  "PCMADPrFish",    # poisson
  "PCMADPrEgg",     # œufs
  "PCMADDairy",     # produits laitiers
  "PCMADFatRpalm",  # graisses / huile de palme
  "PCMADSnfChild",  # substituts de lait maternel
  "PCMADSnfPowd",   # lait en poudre enfants
  "PCMADSnfLns"     # suppléments lipidiques
)

mad <- mad %>%
  # convertir les variables labellisées en numérique binaire
  mutate(across(all_of(group_vars), ~ as.numeric(.x))) %>%
  # calculer le nombre de groupes consommés (somme de 0/1)
  mutate(
    n_groupes = rowSums(across(all_of(group_vars)), na.rm = TRUE)
  )

# 3. Création de la variable DDM (b) --------------------------------
# DDM = 1 si l’enfant a consommé au moins 5 groupes alimentaires
mad <- mad %>%
  mutate(
    DDM = if_else(n_groupes >= 5, 1, 0)
  )

# 4. Proportion d’enfants 6–23 mois bénéficiant du MAD (c) ---------
prop_mad <- mad %>%
  summarise(
    n_enfants = n(),
    n_mad     = sum(DDM, na.rm = TRUE),
    pct_mad   = n_mad / n_enfants * 100
  )
print(prop_mad)

# 5. Statistiques descriptives de DDM par sexe chef et par année (d)
# On convertit HHHSex en facteur et YEAR en facteur pour gtsummary
mad <- mad %>%
  mutate(
    HHHSex = as_factor(HHHSex),
    YEAR   = factor(YEAR)
  )

# on crée donc deux tableaux séparés : un par YEAR, un par HHHSex

# a) Par année
tbl_mad_by_year <- mad %>%
  mutate(
    DDM = factor(DDM, levels = c(0,1), labels = c("Non","Oui"))
  ) %>%
  tbl_summary(
    by        = YEAR,
    include   = DDM,
    statistic = all_categorical() ~ "{n} ({p}%)",
    label     = DDM ~ "MAD (≥5 groupes)",
    missing   = "no"
  ) %>%
  add_overall() %>%
  bold_labels()

tbl_mad_by_year


# b) Par sexe du chef de ménage
tbl_mad_by_sex <- mad %>%
  mutate(
    DDM = factor(DDM, levels = c(0,1), labels = c("Non","Oui"))
  ) %>%
  tbl_summary(
    by        = HHHSex,
    include   = DDM,
    statistic = all_categorical() ~ "{n} ({p}%)",
    label     = DDM ~ "MAD (≥5 groupes)",
    missing   = "no"
  ) %>%
  add_overall() %>%
  bold_labels()

tbl_mad_by_sex

#' -------------------------------------------------------------------
#' Fin du script
#' -------------------------------------------------------------------
