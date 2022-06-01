SELECT 
    *
FROM 
    mjpnatur.vereinbarung
    LEFT JOIN mjpnatur.flaechen 
    ON flaechen.vereinbarungid = vereinbarung.vereinbarungsid
    LEFT JOIN mjpnatur.flaechen_geom_t 
    ON flaechen_geom_t.polyid = flaechen.polyid
    LEFT JOIN mjpnatur.vbart 
    ON vbart.vbartid = vereinbarung.vbartid
    LEFT JOIN mjpnatur.flaechenart 
    ON flaechenart.flaechenartid = flaechen.flaechenartid
    LEFT JOIN mjpnatur.code coda 
    ON flaechen.wiesenkategorie = coda.codeid
