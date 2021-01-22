/* 
   Trigger per controllare che il tesserino del professionista sanitario associoato
   al turno lavorativo sia quello di un medico e che il medico inserito non abbia
   fatto turni di volontariato negli ultimi 7 giorni.
*/
CREATE OR REPLACE TRIGGER trigger_turno_lavorativo
	BEFORE INSERT ON turno_lavorativo
	FOR EACH ROW

	DECLARE 
		non_medico EXCEPTION;
		medico_occupato EXCEPTION;
		turno_recente EXCEPTION;

		prosan professionista_sanitario%ROWTYPE;
		u_turno DATE;
	BEGIN
		-- Controllo che il professionista sanitario sia medico
		SELECT *
		INTO prosan
		FROM professionista_sanitario
		WHERE tesserino=:NEW.tesserino_medico
		AND cuu_lab=:NEW.cuu_medico;

		IF prosan.ruolo <> 'medico' THEN
			RAISE non_medico;
		END IF;

		-- Seleziona l'ultimo turno lavorativo del medico
		SELECT MAX(data)
		INTO u_turno
		FROM turno_lavorativo
		WHERE tesserino_medico=:NEW.tesserino_medico
		AND cuu_medico = :NEW.cuu_medico;

		IF (:NEW.data = u_turno) THEN
			RAISE medico_occupato;
		END IF;

		IF ((:NEW.data-u_turno)/7) < 1 THEN
			RAISE turno_recente;
		END IF;

		EXCEPTION
			WHEN non_medico THEN
				RAISE_APPLICATION_ERROR(-20008,'Il professionista sanitario non risulta un medico');
			WHEN medico_occupato THEN
				RAISE_APPLICATION_ERROR(-20009,'Il medico risulta assegnato ad un altro turno');
			WHEN turno_recente THEN
				RAISE_APPLICATION_ERROR(-20010,'Il medico ha fatto un turno lavorativo questa settimana');
			WHEN NO_DATA_FOUND THEN
				NULL;
	END;
/