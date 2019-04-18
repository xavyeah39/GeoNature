IMPORT FOREIGN SCHEMA layers FROM SERVER geonature1server INTO v1_compat;

-- unité geo en premier
INSERT INTO ref_geo.l_areas(
            id_type, area_name, area_code, geom, centroid)
SELECT 
(SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code = 'UG') AS id_type, id_unite_geo::text, id_unite_geo, the_geom, ST_Centroid(the_geom)
FROM v1_compat.l_unites_geo;

-- communes
INSERT INTO ref_geo.l_areas(
            id_type, area_name, area_code, geom, centroid)
SELECT 
(SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code = 'COM') AS id_type, commune_min, insee, the_geom, ST_Centroid(the_geom)
FROM v1_compat.l_communes;


-- aire d'adhesion
INSERT INTO ref_geo.l_areas(
            id_type, area_name, area_code, geom, centroid)
SELECT 
(SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code = 'AA') AS id_type, 'Aire adhesion PNE', 'AA_PNE',  ST_Multi(ST_MakePolygon(the_geom)), ST_Centroid(ST_MakePolygon(the_geom))
FROM v1_compat.l_aireadhesion;

-- secteurs
INSERT INTO ref_geo.l_areas(
            id_type, area_name, area_code, geom, centroid)
SELECT 
(SELECT id_type FROM ref_geo.bib_areas_types WHERE type_code = 'SEC') AS id_type, nom_secteur, id_secteur, the_geom, ST_Centroid(the_geom)
FROM v1_compat.l_secteurs;


-- autre aires dont le type est déja dans GN1 et dont l'id_type correspond
INSERT INTO ref_geo.l_areas(
            id_type, area_name, area_code, geom, centroid)
SELECT 
id_type, nomzone, id_zone, ST_Multi(the_geom), ST_Centroid(the_geom)
FROM v1_compat.l_zonesstatut l
WHERE id_type <= 20;
;


-- recalcul des couleurs après intégration des nouvelles aires


-- TODO Les autres aires sont noté en ON DELETE CASCADE ... est-ce qu'on les importent

-- création des type d'aires non présents par défaut dans GN2
-- INSERT INTO ref_geo.bib_areas_types(
--             type_name, type_code, type_desc)
--     VALUES ('Site classés', 'SITE_CLASSES', 'Sites classés');

-- INSERT INTO ref_geo.bib_areas_types(
--             type_name, type_code, type_desc)
--     VALUES ('Site inscrits', 'SITE_INSC', 'Sites inscrits');

-- INSERT INTO ref_geo.bib_areas_types(
--             type_name, type_code, type_desc)
--     VALUES ('Site inscrits', 'SITE_INSC', 'Sites inscrits');