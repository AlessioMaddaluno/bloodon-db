CREATE TABLE persona(
	cf CHAR(16) NOT NULL,
	nome_p VARCHAR(30) NOT NULL,
	cognome_p VARCHAR(30) NOT NULL,
	data_nascita_p DATE NOT NULL,
	CONSTRAINT PK_PERSONA PRIMARY KEY (cf),
	CONSTRAINT CF_NOTVALID_PERSONA CHECK (REGEXP_LIKE(cf,'^[A-Za-z]{6}[0-9]{2}[A-Za-z]{1}[0-9]{2}[A-Za-z]{1}[0-9]{3}[A-Za-z]{1}$'))
);

CREATE TABLE telefono_persona(
	cf CHAR(16) NOT NULL,
	telefono VARCHAR(11),
	CONSTRAINT FK_TELEFONO_PERSONA FOREIGN KEY (cf) REFERENCES persona(cf),
	CONSTRAINT TEL_NOTVALID_PERSONA CHECK (LENGTH(telefono)>=9 AND LENGTH(telefono)<=11)
);

CREATE TABLE donatore(
	cf CHAR(16) NOT NULL,
	cie VARCHAR(9) NOT NULL,
	email VARCHAR(30),
	gruppo_sang VARCHAR(4) NOT NULL,
	rh CHAR(3) NOT NULL,
	peso NUMBER NOT NULL,
	CONSTRAINT FK_DONATORE FOREIGN KEY (cf) REFERENCES persona(cf),
	CONSTRAINT UN_DONATORE UNIQUE (cf),
	CONSTRAINT UN2_DONATORE UNIQUE (cie),
	CONSTRAINT EMAIL_NOTVALID_DONATORE CHECK (REGEXP_LIKE(email,'^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$')),
	CONSTRAINT CIE_NOTVALID_DONATORE CHECK (REGEXP_LIKE(cie,'^C[A-Z][0-9]{5}[A-Z]{2}$')),
	CONSTRAINT PESO_MINIMO_DONATORE CHECK (peso >= 50),
	CONSTRAINT GRP_DONATORE CHECK (gruppo_sang IN ('a','b','ab','z')),
	CONSTRAINT RH_DONATORE CHECK (rh IN ('pos','neg'))
);

CREATE TABLE tessera(
	iid CHAR(8) NOT NULL,
	cf CHAR(16) NOT NULL,
	data_erogazione DATE NOT NULL,
	data_scadenza DATE,
	CONSTRAINT PK_TESSERA PRIMARY KEY (iid),
	CONSTRAINT FK_TESSERA FOREIGN KEY (cf) REFERENCES donatore(cf),
	CONSTRAINT IID_NOTVALID CHECK (REGEXP_LIKE(iid,'^[A-Z]{4}[0-9]{4}$'))
);

CREATE TABLE farmacia(
	cim CHAR(11) NOT NULL,
	nome_farmacia VARCHAR(30),
	numero_civico NUMBER,
	via VARCHAR(40),
	citta VARCHAR(30),
	provincia CHAR(2) NOT NULL,
	CONSTRAINT PK_FARMACIA PRIMARY KEY (cim),
	CONSTRAINT CIM_NOTVALID_FARMACIA CHECK (REGEXP_LIKE(cim,'^[0-9]{11}$'))
);


CREATE TABLE telefono_farmacia(
	cim CHAR(11) NOT NULL,
	telefono VARCHAR(10) NOT NULL,
	CONSTRAINT FK_TELEFONO_FARMACIA FOREIGN KEY (cim) REFERENCES farmacia(cim),
	CONSTRAINT TEL_NOTVALID_FARMACIA CHECK (LENGTH(telefono)>=9 AND LENGTH(telefono)<=11)
);

CREATE TABLE prodotto(
	upc CHAR(12) NOT NULL,
	nome_prodotto VARCHAR(80),
	prezzo NUMBER,
	CONSTRAINT PK_PRODOTTO PRIMARY KEY (upc),
	CONSTRAINT UPC_NOTVALID_PROD CHECK (REGEXP_LIKE(upc,'^[0-9]{12}$'))
);

CREATE TABLE convenzione(
	cod_conv CHAR(4) NOT NULL,
	prod CHAR(12) NOT NULL,
	sconto NUMBER NOT NULL,
	scadenza_convenzione DATE NOT NULL,
	cim_farmacia NOT NULL,
	CONSTRAINT PK_CONVENZIONE PRIMARY KEY (cod_conv),
	CONSTRAINT FK_CONVENZIONE FOREIGN KEY (cim_farmacia) REFERENCES farmacia(cim),
	CONSTRAINT FK2_CONVENZIONE FOREIGN KEY (prod) REFERENCES prodotto(upc),
	CONSTRAINT SCONT_CONVENZIONE CHECK (sconto >= 15),
	CONSTRAINT CODCONV_NOTVALID CHECK (REGEXP_LIKE(cod_conv,'^[0-9]{2}[A-Z]{2}$'))
);


CREATE TABLE utilizza(
	iid_tessera CHAR(8) NOT NULL,
	conv CHAR(4) NOT NULL,
	data_utilizzo	DATE NOT NULL,
	CONSTRAINT FK_UTILIZZA FOREIGN KEY (iid_tessera) REFERENCES tessera(iid),
	CONSTRAINT FK2_UTILIZZA FOREIGN KEY (conv) REFERENCES convenzione(cod_conv)
);

CREATE TABLE centro_mobile(
	targa  CHAR(7) NOT NULL,
	tipologia VARCHAR(15),
	CONSTRAINT PK_CENTRO_MOBILE PRIMARY KEY (targa),
	CONSTRAINT TIPO_CENTRO_MOBILE CHECK (tipologia IN ('autoemoteca','autoambulanza')),
	CONSTRAINT TARGA_NOTVALID_CMOB CHECK (REGEXP_LIKE(targa,'^[A-Za-z]{2}[0-9]{3}[A-Za-z]{2}$'))
);

CREATE TABLE laboratorio_analisi(
	cuu CHAR(6) NOT NULL,
	nome_lab VARCHAR(40) NOT NULL,
	civico NUMBER,
	via VARCHAR(40),
	citta VARCHAR(30) NOT NULL,
	provincia CHAR(2) NOT NULL,
	nome_responsabile VARCHAR(30),
	cognome_reposnabile VARCHAR(30),
	CONSTRAINT PK_LAB_ANALISI PRIMARY KEY (cuu)
);

CREATE TABLE telefono_lab_analisi(
	cuu CHAR(6) NOT NULL,
	telefono VARCHAR(10) NOT NULL,
	CONSTRAINT FK_LAB_ANALISI FOREIGN KEY (cuu) REFERENCES laboratorio_analisi(cuu),
	CONSTRAINT TEL_NOTVALID_LAB CHECK (LENGTH(telefono)>=9 AND LENGTH(telefono)<=11)
);

CREATE TABLE professionista_sanitario(
	tesserino CHAR(10) NOT NULL,
	nome_pro CHAR(30) NOT NULL,
	cognome_pro CHAR(30) NOT NULL,
	data_nascita_pro DATE,
	ruolo VARCHAR(10) NOT NULL,
	qualifica VARCHAR(30),
	cuu_lab CHAR(6) NOT NULL,
	CONSTRAINT PK_PRO_SAN PRIMARY KEY (tesserino,cuu_lab),
	CONSTRAINT FK_PRO_SAN FOREIGN KEY (cuu_lab) REFERENCES laboratorio_analisi(cuu),
	CONSTRAINT RUOLO_PRO  CHECK (ruolo IN ('medico','infermiere')),
	CONSTRAINT UN_PRO UNIQUE (tesserino)
);

CREATE TABLE telefono_pro_san(
	tesserino CHAR(10) NOT NULL,
	cuu_lab CHAR(10) NOT NULL,
	telefono VARCHAR(10) NOT NULL,
	CONSTRAINT FK_TEL_PRO FOREIGN KEY (tesserino) REFERENCES professionista_sanitario(tesserino),
	CONSTRAINT TEL_NOTVALID_PSAN CHECK (LENGTH(telefono)>=9 AND LENGTH(telefono)<=11)
);

CREATE TABLE turno_lavorativo(
	data DATE NOT NULL,
	via VARCHAR(40) NOT NULL,
	provincia CHAR(2) ,
	citta VARCHAR(30) NOT NULL,
	tesserino_medico CHAR(10) NOT NULL,
	cuu_medico CHAR(6) NOT NULL,
	cuu_lab CHAR(6) NOT NULL,
	orario_consegna DATE,
	targa_cm CHAR(7) NOT NULL,
	CONSTRAINT PK_TURNO_L PRIMARY KEY (data,targa_cm),
	CONSTRAINT FK1_TURNO_L FOREIGN KEY (targa_cm) REFERENCES centro_mobile(targa),
	CONSTRAINT FK2_TURNO_L FOREIGN KEY (cuu_lab) REFERENCES laboratorio_analisi(cuu),
	CONSTRAINT FK3_TURNO_L FOREIGN KEY (tesserino_medico) REFERENCES professionista_sanitario(tesserino)
);

CREATE TABLE assiste(
	tesserino_inf CHAR(10) NOT NULL,
	cuu_inf CHAR(6) NOT NULL,
	data_tl DATE NOT NULL,
	targa_tl CHAR(7) NOT NULL,
	CONSTRAINT FK1_ASSISTE FOREIGN KEY (tesserino_inf,cuu_inf) REFERENCES professionista_sanitario(tesserino,cuu_lab),
	CONSTRAINT FK2_ASSISTE FOREIGN KEY (data_tl,targa_tl) REFERENCES turno_lavorativo(data,targa_cm)
);

CREATE TABLE volontario(
	cf CHAR(16) NOT NULL,
	titolo_studio VARCHAR(17),
	professione VARCHAR(30),
	CONSTRAINT PK_VOLONT PRIMARY KEY (cf),
	CONSTRAINT FK_VOLONT FOREIGN KEY (cf) REFERENCES persona(cf),
	CONSTRAINT CK_TSTUDIO CHECK (titolo_studio IN ('licenza media','diploma','laurea triennale','laurea magistrale'))
);

CREATE TABLE partecipa(
	cf_volontario CHAR(16) NOT NULL,
	data_tl DATE NOT NULL,
	targa_tl CHAR(7) NOT NULL,
	CONSTRAINT FK1_PARTECIPA FOREIGN KEY (cf_volontario) REFERENCES volontario(cf),
	CONSTRAINT FK2_PARTECIPA FOREIGN KEY (data_tl,targa_tl) REFERENCES turno_lavorativo(data,targa_cm)
);

CREATE TABLE donazione(
	cid CHAR(12) NOT NULL,
	qt NUMBER NOT NULL,
	cf_donatore CHAR(16) NOT NULL,
	data_tl DATE NOT NULL,
	targa_tl CHAR(7) NOT NULL,
	CONSTRAINT PK_DONAZIONE PRIMARY KEY (cid),
	CONSTRAINT FK1_DONAZIONE FOREIGN KEY (cf_donatore) REFERENCES donatore(cf),
	CONSTRAINT FK2_DONAZIONE FOREIGN KEY (data_tl,targa_tl) REFERENCES turno_lavorativo(data,targa_cm),
	CONSTRAINT QT_DONAZIONE CHECK (qt <= 450 AND qt >= 100),
	CONSTRAINT CID_NOTVALID_DON CHECK (REGEXP_LIKE(cid,'^[0-9]{12}'))
);

CREATE TABLE esame(
	codice_memonico VARCHAR(5) NOT NULL,
	nome_esame VARCHAR(25) NOT NULL,
	CONSTRAINT PK_ESAME PRIMARY KEY (codice_memonico)
);

CREATE TABLE referto(
	cod_verbale CHAR(8) NOT NULL,
	cid_donazione CHAR(12) NOT NULL,
	cuu_lab CHAR(6),
	nome_tecnico VARCHAR(30),
	cognome_tecnico VARCHAR(30),
	nome_medico VARCHAR(30),
	cognome_medico VARCHAR(30),
	CONSTRAINT PK_REFERTO PRIMARY KEY (cod_verbale),
	CONSTRAINT FK1_REFERTO FOREIGN KEY (cuu_lab) REFERENCES laboratorio_analisi(cuu),
	CONSTRAINT FK2_REFERTO FOREIGN KEY (cid_donazione) REFERENCES donazione(cid)
);

CREATE TABLE composto_da (
	cod_verbale CHAR(8) NOT NULL,
	cod_esame VARCHAR(5) NOT NULL,
	esito NUMBER NOT NULL,
	giudizio CHAR(3) NOT NULL,
	CONSTRAINT FK1_COMP FOREIGN KEY (cod_verbale) REFERENCES referto(cod_verbale),
	CONSTRAINT FK2_COMP FOREIGN KEY (cod_esame) REFERENCES esame(codice_memonico),
	CONSTRAINT ESIT_NOTVALID CHECK (giudizio IN ('pos','neg'))
);




















































