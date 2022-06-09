DELETE FROM 
    arp_waldreservate_v1.waldreservat_teilobjekt
;

DELETE FROM 
    arp_waldreservate_v1.waldreservat 
;
 
WITH flaechen AS 
(
    SELECT 
        t_id,
        vereinbarungid,
        vbnr,
        ST_ReducePrecision((ST_Dump(geometrie)).geom, 0.001) AS geometrie,
        --geometrie,
        flaeche,
        gis_flaeche,
        CASE 
            WHEN flurname IS NULL THEN 'FIXME-FIXME'
            WHEN trim(flurname) = '' THEN 'FIXME-FIXME'
            WHEN trim(flurname) = '-' THEN 'FIXME-FIXME'
            ELSE flurname 
        END AS flurname,
        CASE 
            WHEN rrbnr IS NULL THEN '9999-FIXME'
            ELSE rrbnr 
        END AS rrbnr,
        CASE 
            WHEN rrbdatum IS NULL THEN '2999-12-31'
            ELSE rrbdatum 
        END AS rrbdatum
    FROM 
        arp_mjpnatur_tmp.flaechen
)
,
flaechen_waldreservat AS 
(
    SELECT 
        vbnr, 
        --ST_Multi(ST_Union(geometrie)) AS geometrie, 
        sum(flaeche) AS flaeche, 
        sum(ST_Area(geometrie)) / 10000 AS gis_flaeche
    FROM 
        flaechen
    GROUP BY 
        vbnr
)
,
waldreservate AS 
(
    INSERT INTO 
        arp_waldreservate_v1.waldreservat 
    (
        objnummer,
        obj_gesflaeche,
        obj_gisflaeche,
        aname,
        rechtsstatus
    )
    SELECT 
        flaechen_waldreservat.vbnr,
        flaechen_waldreservat.flaeche,
        flaechen_waldreservat.gis_flaeche,
        flaechen.flurname,
        'inKraft'
    FROM 
        flaechen_waldreservat 
        LEFT JOIN 
        (
            SELECT 
                -- Annahme: gleicher Flurname und RRB bei gleicher vbnr
                DISTINCT ON (vbnr)
                vbnr,
                flurname,
                rrbnr,
                rrbdatum
            FROM 
                flaechen
        ) AS flaechen 
        ON flaechen.vbnr = flaechen_waldreservat.vbnr
    RETURNING *
)
INSERT INTO 
    arp_waldreservate_v1.waldreservat_teilobjekt 
    (
        teilobj_nr,
        mcpfe_code,
        obj_gisteilobjekt,
        geo_obj,
        wr
    )
SELECT 
    flaechen.t_id AS teilobj_nr, -- t_id: kann sich aendern
    'MCPFE1_1' AS mcpfe_code, -- fixme afterwards
    ST_Area(flaechen.geometrie) / 10000 AS obj_gisteilobjekt,
    flaechen.geometrie,
    waldreservate.t_id
FROM
    waldreservate
    LEFT JOIN flaechen 
    ON flaechen.vbnr = waldreservate.objnummer
;

/*
Dokumente: Es gibt nur ein Dokument für eine Vereinbarung in den heutigen
Daten. Weil das nicht zwingend so sein muss und um Rahmenmodell-konform 
zu sein, ist es wie das Rahmenmodell modelliert. Irgendwie muss man sowieso
den leicht komplizierten Datenumbau machen.
*/