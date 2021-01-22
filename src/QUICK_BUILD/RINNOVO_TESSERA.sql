CREATE OR REPLACE PROCEDURE rinnovo_tessera(iid_t VARCHAR) IS
	ds DATE;
	tessera_non_scaduta EXCEPTION;
	offset NUMBER := 1;
	donazioni_eff NUMBER;
	cf_don CHAR(16);
BEGIN
	
	SELECT data_scadenza
	INTO ds
	FROM tessera
	WHERE iid=iid_t;

	IF ds > TRUNC(SYSDATE) THEN
		RAISE tessera_non_scaduta;
	END IF;

	SELECT cf
	INTO cf_don
	FROM tessera
	WHERE iid = iid_t;

	SELECT COUNT(*)
	INTO donazioni_eff
	FROM donazione
	WHERE cf_donatore = cf_don
	AND data_tl > ds;

	IF donazioni_eff >= 5 THEN
		offset := offset+1; 
	END IF;

	UPDATE tessera
	SET data_scadenza = ADD_MONTHS(TRUNC(SYSDATE),12*offset)
	WHERE iid = iid_t;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Tessera non trovata');
			ROLLBACK;
		WHEN tessera_non_scaduta THEN
			DBMS_OUTPUT.PUT_LINE('La tessera risulta attiva.');
			ROLLBACK;

END;

/

-- execute rinnovo_tessera('SODL9486');