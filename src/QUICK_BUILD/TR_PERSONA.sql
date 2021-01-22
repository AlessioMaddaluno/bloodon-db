/* Trigger per verificare che vengano inserite solo persone maggiorenni */
CREATE OR REPLACE TRIGGER trigger_eta
	BEFORE INSERT OR UPDATE ON persona
	FOR EACH ROW
	
	DECLARE
		non_maggiorenne EXCEPTION;

	BEGIN
		IF ((trunc(SYSDATE)-:NEW.data_nascita_p)/365<18) THEN 
			RAISE non_maggiorenne;
		END IF;

		EXCEPTION
			WHEN non_maggiorenne THEN
				RAISE_APPLICATION_ERROR(-20001,'La persona deve essere necessariamente maggiorenne');
	END;
/