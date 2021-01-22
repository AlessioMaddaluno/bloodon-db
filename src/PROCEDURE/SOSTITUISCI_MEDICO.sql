CREATE OR REPLACE PROCEDURE sostituisci_medico(in_data_tl DATE,in_targa_tl VARCHAR) IS
	turno turno_lavorativo%ROWTYPE;
BEGIN

	SELECT *
	INTO turno
	FROM turno_lavorativo
	WHERE data = in_data_tl
	AND targa_cm = in_targa_tl;

	UPDATE turno_lavorativo
	SET (tesserino_medico,cuu_medico) = 
	(SELECT tesserino,cuu_lab FROM (
	SELECT med_disp.tesserino,med_disp.cuu_lab,COUNT(*) as prestazioni
	FROM (SELECT tesserino,cuu_lab
	FROM professionista_sanitario
	WHERE ruolo = 'medico'
	AND tesserino <> turno.tesserino_medico
	AND cuu_lab <> turno.cuu_medico
	AND cuu_lab IN (SELECT cuu
	FROM laboratorio_analisi
	WHERE provincia = turno.provincia)
	AND NOT EXISTS (SELECT * FROM turno_lavorativo WHERE tesserino = tesserino_medico AND data = in_data_tl)) med_disp
	JOIN turno_lavorativo tl
	ON tl.tesserino_medico = med_disp.tesserino AND tl.cuu_medico = med_disp.cuu_lab
	GROUP BY med_disp.tesserino,med_disp.cuu_lab
	ORDER BY prestazioni)
	WHERE ROWNUM = 1)
	WHERE data = in_data_tl AND targa_cm = in_targa_tl;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Non sono soddisfatti i requisiti per sostituire il medico.');
			ROLLBACK;
END;

/