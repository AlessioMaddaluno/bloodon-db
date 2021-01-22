CREATE OR REPLACE PROCEDURE genera_turno_lavorativo (in_data DATE,in_via VARCHAR,in_citta VARCHAR,in_targa_cm VARCHAR,in_provincia VARCHAR,in_cuu_lab VARCHAR) IS
	
	CURSOR get_medico (in_data DATE, in_provincia VARCHAR) IS 
	SELECT tesserino,cuu_lab FROM (
	SELECT med_disp.tesserino,med_disp.cuu_lab,COUNT(*) as prestazioni
	FROM (SELECT tesserino,cuu_lab
	FROM professionista_sanitario
	WHERE ruolo = 'medico'
	AND cuu_lab IN (SELECT cuu
	FROM laboratorio_analisi
	WHERE provincia = 'NA')
	AND NOT EXISTS (SELECT * FROM turno_lavorativo WHERE tesserino = tesserino_medico AND data = in_data)) med_disp
	JOIN turno_lavorativo tl
	ON tl.tesserino_medico = med_disp.tesserino AND tl.cuu_medico = med_disp.cuu_lab
	GROUP BY med_disp.tesserino,med_disp.cuu_lab
	ORDER BY prestazioni)
	WHERE ROWNUM = 1;

	CURSOR get_volontari (in_data DATE) IS SELECT cf
	FROM(SELECT vol_disp.cf, COUNT(*) as prestazioni
	FROM (SELECT * FROM volontario
	WHERE NOT EXISTS ( SELECT * FROM partecipa WHERE volontario.cf = partecipa.cf_volontario AND data_tl = in_data)) vol_disp
	LEFT OUTER JOIN partecipa
	ON partecipa.cf_volontario = vol_disp.cf
	GROUP BY vol_disp.cf
	ORDER BY prestazioni)
	WHERE ROWNUM <= 2;

	CURSOR get_infermieri (in_data DATE, in_provincia VARCHAR) IS 
	SELECT * FROM (
	SELECT tesserino,cuu_lab,COUNT(*) as prestazioni
	FROM (SELECT tesserino,cuu_lab
	FROM professionista_sanitario
	WHERE ruolo = 'infermiere'
	AND cuu_lab IN (SELECT cuu
	FROM laboratorio_analisi
	WHERE provincia = in_provincia)
	AND NOT EXISTS (SELECT * FROM assiste WHERE tesserino_inf = tesserino AND data_tl = in_data)) inf_disp
	LEFT OUTER JOIN assiste 
	ON assiste.tesserino_inf = tesserino
	GROUP BY tesserino,cuu_lab
	ORDER BY prestazioni)
	WHERE ROWNUM <= 2;

	vol_disp get_volontari%ROWTYPE;
	inf_disp get_infermieri%ROWTYPE;
	med_disp get_medico%ROWTYPE;

	volontari_insufficienti EXCEPTION;
	infermieri_insufficienti EXCEPTION;
	
BEGIN	
	/* Creo il turno lavorativo e inserisco il medico */
	OPEN get_medico(in_data,in_provincia);
	FETCH get_medico INTO med_disp;
	INSERT INTO turno_lavorativo VALUES
	(in_data,in_via,in_provincia,in_citta,med_disp.tesserino,med_disp.cuu_lab,in_cuu_lab,NULL,in_targa_cm);
	CLOSE get_medico;

	/* Cerco e inserisco gli infermieri */
	OPEN get_infermieri(in_data,in_provincia);
	LOOP
    FETCH get_infermieri INTO inf_disp; 
    EXIT WHEN get_infermieri%notfound;
   	INSERT INTO assiste VALUES (inf_disp.tesserino,inf_disp.cuu_lab,in_data,in_targa_cm);
  	END LOOP;

  	IF get_infermieri%ROWCOUNT < 2 THEN
  		RAISE infermieri_insufficienti;
  	END IF;

	CLOSE get_infermieri;

	/* Cerco e inserisco i volontari */
	OPEN get_volontari(in_data);
	LOOP
    FETCH get_volontari INTO vol_disp; 
    EXIT WHEN get_volontari%notfound;
   	INSERT INTO partecipa VALUES(vol_disp.cf,in_data,in_targa_cm);
  	END LOOP;

  	IF get_volontari%ROWCOUNT < 2 THEN
  		RAISE volontari_insufficienti;
  	END IF;
	CLOSE get_volontari;

	COMMIT;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Non sono soddisfatti i requisiti per creare un nuovo turno.');
			ROLLBACK;
		WHEN volontari_insufficienti THEN
			DBMS_OUTPUT.PUT_LINE('Non ci sono volontari sufficienti.');
			ROLLBACK;
		WHEN infermieri_insufficienti THEN
			DBMS_OUTPUT.PUT_LINE('Non ci sono volontari sufficienti.');
			ROLLBACK;
END;

/



