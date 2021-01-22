/* Trigger per verificare che non vengano inserite convenzioni scadute */
CREATE OR REPLACE TRIGGER trigger_convenzione
BEFORE INSERT OR UPDATE ON convenzione 
FOR EACH ROW

	DECLARE
		convenzione_scaduta EXCEPTION;

	BEGIN
		IF (:NEW.scadenza_convenzione <= trunc(SYSDATE)) THEN
			RAISE convenzione_scaduta;
		END IF;

	EXCEPTION
		WHEN convenzione_scaduta THEN
			RAISE_APPLICATION_ERROR(-20004,'La convenzione risulta scaduta.');
	END;

/