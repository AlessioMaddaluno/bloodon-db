/* Trigger per gestire un possibile sovrannumero di donazioni o di quantità di sangue donato */
CREATE OR REPLACE TRIGGER trigger_possibilita_donazione
	BEFORE INSERT OR UPDATE ON donazione 
	FOR EACH ROW

	DECLARE
		donazioni_annue NUMBER;
		qt_sangue NUMBER;
		ultima_don DATE;

		limite_donazioni EXCEPTION;
		limite_quantita EXCEPTION;
		donazione_recente EXCEPTION;

	BEGIN
		-- Verifica se sono state fatte 3 donazione negli scorsi 12 mesi.
		SELECT COUNT(*)
		INTO donazioni_annue
		FROM donazione
		WHERE cf_donatore = :NEW.cf_donatore AND data_tl > ADD_MONTHS(:NEW.data_tl,-12);

		IF	donazioni_annue = 3 THEN
			RAISE limite_donazioni;
		END IF;

		-- Verifica che non sia stato superato il limite annuo di quantità donata
		SELECT SUM(qt)
		INTO qt_sangue
		FROM donazione
		WHERE cf_donatore = :NEW.cf_donatore AND data_tl > ADD_MONTHS(:NEW.data_tl,-12);

		IF qt_sangue+:NEW.qt > 1000 THEN
			RAISE limite_quantita;
		END IF;

		-- Controlla che il donatore non abbia effettuato una donazione negli ultimi 28*3 giorni (3 mesi)
		SELECT MAX(data_tl)
		INTO ultima_don
		FROM donazione
		WHERE cf_donatore = :NEW.cf_donatore;

		IF (:NEW.data_tl - ultima_don) < 84 THEN
			RAISE donazione_recente;
		END IF;

	EXCEPTION 
		WHEN limite_donazioni THEN
			RAISE_APPLICATION_ERROR(-20008,'Limite donazioni annue raggiunto.');
		WHEN limite_quantita THEN
			RAISE_APPLICATION_ERROR(-20009,'Limite qt sangue annuo raggiunto.');
		WHEN donazione_recente THEN
			RAISE_APPLICATION_ERROR(-20010,'Donazione effettutata di recente.');
	END;

/