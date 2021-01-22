CREATE MATERIALIZED VIEW classifica_volontari
BUILD IMMEDIATE
REFRESH COMPLETE
START WITH TO_DATE('21-06-2019 00:00:00', 'DD-MM-YYYY HH24:MI:SS') NEXT SYSDATE + 28 
AS
	SELECT vol.cf,vol.nome_p,vol.cognome_p,COUNT(*) as prestazioni
	FROM (SELECT p.cf,p.nome_p,p.cognome_p
	FROM volontario v JOIN persona P
	ON v.cf = p.cf) vol JOIN partecipa par
	ON vol.cf = par.cf_volontario
	GROUP BY  vol.cf,vol.nome_p,vol.cognome_p
	ORDER BY prestazioni DESC;