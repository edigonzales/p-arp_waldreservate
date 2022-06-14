DELETE FROM 
    arp_waldreservate_v1.waldreservat_dokument 
;

DELETE FROM 
    arp_waldreservate_v1.dokument 
;

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
            WHEN rrbdatum IS NULL THEN '2100-12-31'
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
        rechtsstatus,
        publiziertab
    )
    SELECT 
        flaechen_waldreservat.vbnr,
        flaechen_waldreservat.flaeche,
        flaechen_waldreservat.gis_flaeche,
        flaechen.flurname,
        'inKraft',
        flaechen.rrbdatum
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

WITH dokumente AS 
(   
    SELECT 
        DISTINCT ON (vbnr)
        nextval('arp_waldreservate_v1.t_ili2db_seq'::regclass) AS t_id,
        vbnr,
        'Ich bin ein Titel' AS titel,
        'RRB' AS abkuerzung,
        CASE 
            WHEN rrbnr IS NULL THEN 'FIXME-' || gen_random_uuid ()
            ELSE rrbnr 
        END AS offiziellenr,
        'https://geo.so.ch/docs/ch.so.arp.waldreservate/' || gen_random_uuid () || '.pdf' AS textimweb,
        'inKraft' AS rechtsstatus,
        CASE 
            WHEN rrbdatum IS NULL THEN '2999-12-31'
            ELSE rrbdatum 
        END AS publiziertab
    FROM 
        arp_mjpnatur_tmp.flaechen
)
,
dokumente_insert AS 
(
    INSERT INTO
        arp_waldreservate_v1.dokument 
        (
            --t_id,
            titel,
            abkuerzung,
            offiziellenr,
            textimweb,
            rechtsstatus,
            publiziertab
        )
    SELECT 
        DISTINCT ON (offiziellenr, publiziertab)
        --t_id,
        titel,
        abkuerzung,
        offiziellenr,
        textimweb,
        rechtsstatus,
        publiziertab
    FROM 
        dokumente
    RETURNING *
)
INSERT INTO 
    arp_waldreservate_v1.waldreservat_dokument 
    (
        dokumente,
        festlegung
    )
SELECT 
    dokumente_insert.t_id AS dokumente,
    waldreservat.t_id AS festlegung
FROM 
    dokumente
    LEFT JOIN dokumente_insert
    ON dokumente.offiziellenr = dokumente_insert.offiziellenr AND dokumente.publiziertab = dokumente_insert.publiziertab
    LEFT JOIN arp_waldreservate_v1.waldreservat AS waldreservat 
    ON waldreservat.objnummer = dokumente.vbnr
;