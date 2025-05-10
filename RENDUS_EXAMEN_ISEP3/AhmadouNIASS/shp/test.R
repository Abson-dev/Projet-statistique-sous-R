library(sf)
library(tmap)

# Charger les régions (niveau administratif 1)
regions <- st_read("tcd_admbnda_adm1_20250212_AB.shp")
departements <- st_read("tcd_admbnda_adm2_20250212_AB.shp")
print(st_geometry_type(regions))
print(st_crs(regions))
print(head(regions))