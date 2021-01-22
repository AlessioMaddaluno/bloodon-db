/* Trigger per evitare di assegnare lo stesso volontario a più turni lavorativi */

CREATE OR REPLACE TRIGGER trigger_partecipa
	BEFORE INSERT OR UPDATE ON partecipa
	FOR EACH ROW

	DECLARE
		volontario_occupato EXCEPTION;
		occupato NUMBER;
	BEGIN

		SELECT COUNT(*)
		INTO occupato
		FROM partecipa
		WHERE cf_volontario = :NEW.cf_volontario
		AND data_tl = :NEW.data_tl
		AND targa_tl = :NEW.targa_tl;

		IF occupato > 0 THEN
			RAISE volontario_occupato;
		END IF;

	EXCEPTION

		WHEN volontario_occupato THEN
			RAISE_APPLICATION_ERROR(-20010,'Il volontario risulta occupato per quel turno.');

	END;

/
