/* 
   Trigger per controllare che il numero degli infermieri associati ad un turno non sia maggiore
   di 2 e per controllare che il tesserino memorizzato sia effettivamente di un infermiere.
   Un infermiere può fare solo un tuno di volontariato ogni 7 giorni.
*/

CREATE OR REPLACE TRIGGER trigger_assiste
	BEFORE INSERT OR UPDATE ON assiste
	FOR EACH ROW

	DECLARE 
		non_infermiere EXCEPTION;
		limite_infermieri EXCEPTION;
		infermiere_occupato EXCEPTION;
		supporto_recente EXCEPTION;

		prosan professionista_sanitario%ROWTYPE;
		num_inferm NUMBER;
		u_turno DATE;
	BEGIN

		SELECT *
		INTO prosan
		FROM professionista_sanitario
		WHERE tesserino = :NEW.tesserino_inf
		AND cuu_lab = :NEW.cuu_inf;

		SELECT COUNT(*)
		INTO num_inferm
		FROM assiste
		WHERE data_tl = :NEW.data_tl
		AND targa_tl  = :NEW.targa_tl;

		IF prosan.ruolo <> 'infermiere' THEN
			RAISE non_infermiere;
		END IF;

		IF num_inferm = 2 THEN
			RAISE limite_infermieri;
		END IF;

		-- Seleziona l'ultimo turno lavorativo dell'infermiere
		SELECT MAX(data_tl)
		INTO u_turno
		FROM assiste
		WHERE tesserino_inf=:NEW.tesserino_inf
		AND cuu_inf = :NEW.cuu_inf;

		IF (:NEW.data_tl = u_turno) THEN
			RAISE infermiere_occupato;
		END IF;

		IF ((:NEW.data_tl-u_turno)/7) < 1 THEN
			RAISE supporto_recente;
		END IF;

		EXCEPTION
			WHEN non_infermiere THEN
				RAISE_APPLICATION_ERROR(-20011,'Il professionista sanitario non risulta un infermiere');
			WHEN limite_infermieri THEN
				RAISE_APPLICATION_ERROR(-20012,'Limite infermieri associabili reggiunto');
			WHEN supporto_recente THEN
				RAISE_APPLICATION_ERROR(-20013,'L infermiere ha fatto un turno lavorativo questa settimana');
			WHEN infermiere_occupato THEN
				RAISE_APPLICATION_ERROR(-20014,'L infermiere risulta assegnato ad un altro turno');
	END;
/