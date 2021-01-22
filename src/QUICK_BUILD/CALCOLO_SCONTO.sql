CREATE OR REPLACE PROCEDURE calcolo_sconto(c_conv VARCHAR,upc_prodotto VARCHAR, f_cim VARCHAR,data_scadenza DATE,sconto NUMBER) IS
	sconto_riferimento NUMBER;
	prov_farma CHAR(2);
BEGIN
	
	-- Seleziono la provincia della farmacia interessata
	SELECT provincia
	INTO prov_farma
	FROM farmacia 
	WHERE cim = f_cim;

	-- Seleziono lo sconto più consono
	SELECT MAX(sconto_max) as SCONTO
	INTO sconto_riferimento
	FROM utilizza 
	JOIN (SELECT convenzione.cod_conv,MAX(convenzione.sconto) as sconto_max
	FROM convenzione JOIN (SELECT * FROM farmacia WHERE provincia = prov_farma) f
	ON convenzione.cim_farmacia = f.cim
	WHERE prod = upc_prodotto AND convenzione.cim_farmacia <> f_cim
	GROUP BY convenzione.sconto,convenzione.cod_conv) used_conv
	ON utilizza.conv = used_conv.cod_conv
	GROUP BY utilizza.conv;
	
	-- Applico una maggiorazione del 5% allo sconto 	
	sconto_riferimento := sconto_riferimento + 5;

	INSERT INTO convenzione VALUES (c_conv,upc_prodotto,sconto_riferimento,data_scadenza,f_cim);
	DBMS_OUTPUT.PUT_LINE('Sconto applicato in seguito ad un indagine di mercato');

	COMMIT;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			DBMS_OUTPUT.PUT_LINE('Competitor insufficienti. Viene applicato lo sconto inserito.');
			INSERT INTO convenzione VALUES (c_conv,upc_prodotto,sconto,data_scadenza,f_cim);
			COMMIT;
END;

/