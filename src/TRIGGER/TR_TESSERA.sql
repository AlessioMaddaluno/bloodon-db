/*

	Quando si tenta di aggiungere una nuova tessera nel DB, viene controllato che non sia già presente una tessera già associata
	alla stessa persona (viene effettuato un controllo tramite codice fiscale).
	Qualora non esistesse un' altra tessera associata alla persona, viene applicata una politica di assegnazione della data di 
	scadenza che tiene conto delle donazioni pregresse da parte del donatore. Questo è utile per incentivare col tempo i donatori
	più attivi nel sottoscrivere la tessere e sfruttarne i vantaggi. Poichè è teoricamente un attributo in funzione di altri dati 
	ottenibili tramite DB, dovrebbe in teoria rientrare nell'insieme di attributi derivati, tuttavia, trattandosi di operazioni 
	potenzialmente onerose e dato che è un informazioni a cui si fa spesso riferimento, si è deciso di memorizzarlo come 
	attributo statico.
	La politica di assegnazione della data di scadenza prende in considerazione la data di erogazione e imposta una validità 
	della tessera in relazione al numero di donazioni pregresse:
	- 0-2 1 anno
	- 3-5 2 anni
	- 6+  3 anni 

	Inoltre se il donatore è anche un volontario ed ha effettuato un turno di volontariato negli ultimi 12 mesi allora la 
	scadenza della tessera è posticipata di un ulteriore anno.

	Nel caso in cui la tessera è già presente nel database non può essere inserita. E' richiesta una procedura di rinnovo.

*/

CREATE OR REPLACE TRIGGER trigger_tessera
	BEFORE INSERT ON tessera
	FOR EACH ROW

	DECLARE
		offset NUMBER;
		num_donazioni NUMBER;
		tess tessera%ROWTYPE;
		risulta_volontario NUMBER := 0;
		tessera_attiva EXCEPTION;
		tessera_scaduta EXCEPTION;
	BEGIN
		-- Controllo se è presente già una tessera associata al cf. Nel caso non ci sia verrà sollevata un eccezione
		-- del tipo NOT_DATA_FOUND
		SELECT * 
		INTO tess
		FROM tessera
		WHERE cf = :NEW.cf;

		-- Controllo se è scaduta. 
		IF (tess.data_scadenza > TRUNC(SYSDATE)) THEN
			RAISE tessera_attiva;
		END IF;
		RAISE tessera_scaduta;

	EXCEPTION
		
		WHEN NO_DATA_FOUND THEN
			-- Applicazione regola di business per impostare la data di scadenza della tessera
			SELECT COUNT(*)
			INTO num_donazioni
			FROM donazione
			WHERE cf_donatore = :NEW.cf;
			-- Imposto un offset in relazione al numero di donzioni effettuate
			CASE 
   				WHEN num_donazioni <= 2 THEN
   					offset := 1;
   				WHEN num_donazioni>2 AND num_donazioni<=5 THEN
   					offset := 2;
   				WHEN num_donazioni > 5 THEN 
   					offset := 3;
			END CASE;

			-- Controllo se la persona ha fatto volontariato nell'ultimo anno
			SELECT COUNT(*)
			INTO risulta_volontario
			FROM partecipa
			WHERE cf_volontario = :new.cf
			AND data_tl > ADD_MONTHS(:NEW.data_erogazione,-12);

			IF risulta_volontario > 0 THEN
				offset:=offset+1;
			END IF;
			-- Imposto la data di scadenza customizzata
			:NEW.data_scadenza := ADD_MONTHS(:NEW.data_erogazione,12*offset);

		WHEN tessera_attiva THEN
			RAISE_APPLICATION_ERROR(-20002,'Esiste una tessera attiva associata alla persona.');
		WHEN tessera_scaduta THEN
			RAISE_APPLICATION_ERROR(-20003,'Esiste una tessera nel sistema associata alla persona ma risulta scaduta.');

	END;
/