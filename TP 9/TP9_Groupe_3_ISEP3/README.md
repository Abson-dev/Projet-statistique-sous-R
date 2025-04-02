# TP9 - Harmonisation des bases Welfare 2018 et 2021

Ce projet a pour objectif de fusionner deux bases de données d'enquêtes de bien-être (Welfare) pour les années **2018** et **2021**, en assurant une **harmonisation des variables catégorielles**.

# TP9 - Harmonisation des bases Welfare 2018 et 2021

Ce projet a pour objectif de fusionner deux bases de données d'enquêtes de bien-être (Welfare) pour les années **2018** et **2021**, en assurant une **harmonisation des variables catégorielles**.

## 📁 Structure du projet

```txt
TP9_Groupe_3_ISEP3/
├── data/                          # Contient les fichiers .dta originaux de 2018 et 2021
│   ├── ehcvm_welfare_sen2018.dta
│   └── ehcvm_welfare_sen2021.dta
├── Scripts/                       # Contient le script R principal de traitement
│   └── Traitement.R
├── Outputs/                       # Contiendra le fichier fusionné final au format .dta
│   └── welfare_2018_2021_output.dta
├── TP9_Groupe_3_ISEP3.Rproj
└── README.md                      # Ce fichier
```


## ⚙️ Fonctionnement du script `Traitement.R`

Le script suit les étapes suivantes :

1. **Chargement des bases** : les fichiers `.dta` sont lus depuis le dossier `data/`.
2. **Définition des variables** : les variables et leurs labels sont définis manuellement (depuis Stata).
3. **Identification des variables catégorielles** : les variables avec labels sont isolées.
4. **Extraction des modalités** : les modalités de chaque variable sont affichées dans un tableau comparatif.
5. **Corrections** : les différences d'encodage sont corrigées (ex : `hactiv7j`, `hbranch`, `hcsp`, `hdiploma`, `hnation`).
6. **Fusion** : un simple `append` est effectué pour fusionner les deux années.
7. **Export** : le fichier final est exporté au format `.dta` dans `Outputs/`.

## 📦 Fichier final

Le fichier final s'appelle :

Outputs/welfare_2018_2021_output.dta


Il contient :
- Toutes les observations de 2018 et 2021
- Les encodages catégoriels harmonisés
- Des valeurs `NA` là où une variable est absente d'une des années

## 👨‍💻 Auteurs

Projet réalisé dans le cadre du TP9 par le **Groupe 3** en **ISEP3**, composé de :

- Khadidiatou Diakhaté  
- Raherinasolo Ange Emilson Rayan  
- Awa Diaw  
- Alioune Abdou Salam Kane



