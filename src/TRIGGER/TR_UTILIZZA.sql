/* Trigger per controllare che non vengano utilizzate convenzioni scadute e per limitare l'abuso della tessera */
CREATE OR REPLACE TRIGGER trigger_utilizza
	BEFORE INSERT OR UPDATE ON utilizza
	FOR EACH ROW

	DECLARE
		convenz convenzione%ROWTYPE;
		conv_scaduta EXCEPTION;
		limite_uso_mensile EXCEPTION;
		limite_uso_giornaliero EXCEPTION;
		num_utilizzi NUMBER;
	BEGIN
		-- Controllo se la convenzione che si vuole utilizzare è scaduta
		SELECT * 
		INTO convenz
		FROM convenzione  
		WHERE cod_conv = :NEW.conv;

		IF (convenz.scadenza_convenzione <= :NEW.data_utilizzo) THEN
			RAISE conv_scaduta;
		END IF;

		-- Applicazione della limitazione di utilizzo tessera
		-- Controllo limite mensile (15 utilizzi)
		SELECT COUNT(*)
		INTO num_utilizzi
		FROM utilizza
		WHERE iid_tessera = :NEW.iid_tessera
		AND data_utilizzo > ADD_MONTHS(:NEW.data_utilizzo,-1);

		IF num_utilizzi = 15 THEN
			RAISE limite_uso_mensile;
		END IF;
		-- Controllo limite giornaliero (4 utilizzi)
		SELECT COUNT(*)
		INTO num_utilizzi
		FROM utilizza
		WHERE iid_tessera = :NEW.iid_tessera
		AND data_utilizzo = :NEW.data_utilizzo;

		IF num_utilizzi = 4 THEN
			RAISE limite_uso_giornaliero;
		END IF;
		
	EXCEPTION
		WHEN conv_scaduta THEN
			RAISE_APPLICATION_ERROR(-20005,'La convenzione risulta scaduta.');
		WHEN limite_uso_mensile THEN
			RAISE_APPLICATION_ERROR(-20006,'Limite utilizzo mensile tessera.');
		WHEN limite_uso_giornaliero THEN
			RAISE_APPLICATION_ERROR(-20007,'Limite utilizzo giornaliero tessera.');
	END;
/