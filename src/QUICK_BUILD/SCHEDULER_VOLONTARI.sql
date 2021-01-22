/*
	Questo job, ogni anno cancella dalla tabella volontari, tutti i "volontari"
	che non hanno fatto un turno lavorativo.
*/

BEGIN
DBMS_SCHEDULER . CREATE_JOB (
	job_name => 'volunteers_cleanup',
	job_type => 'PLSQL_BLOCK',
	job_action => 
	'BEGIN
	 DELETE FROM volontario 
	 WHERE cf IN (SELECT cf 
				 FROM (SELECT cf FROM volontario WHERE cf NOT IN (SELECT cf FROM donatore)) 
				 WHERE cf NOT IN (SELECT V.cf 
				 				  FROM volontario V 
				 				  JOIN partecipa P ON V.cf = P.cf_volontario)

	);
	END;',
	start_date => TO_DATE('27-LUG-2019','DD-MON-YYYY') ,
	repeat_interval => 'FREQ=YEARLY',
	enabled => TRUE ,
	comments => 'Cancellazione dei *NON* volontari') ;
END;
/
