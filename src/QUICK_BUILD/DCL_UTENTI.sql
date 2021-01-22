-- BLOODON
GRANT ALL PRIVILEGES TO bloodon;
-- DONATORE
GRANT SELECT ON persona TO donatore;
GRANT ALL PRIVILEGES ON telefono_persona TO donatore;
GRANT UPDATE,SELECT ON donatore TO donatore;
GRANT SELECT ON tessera TO donatore;
GRANT SELECT ON utilizza TO donatore;
GRANT SELECT ON convenzione TO donatore;
GRANT SELECT ON farmacia TO donatore;
GRANT SELECT ON telefono_persona TO donatore;
GRANT SELECT ON donazione TO donatore;
GRANT SELECT ON referto TO donatore;
GRANT SELECT ON composto_da TO donatore;
GRANT SELECT ON esame  TO donatore;
GRANT SELECT ON laboratorio_analisi  TO donatore;
GRANT SELECT ON telefono_lab_analisi TO donatore;
-- VOLONTARIO
GRANT SELECT ON persona TO volontario;
GRANT ALL PRIVILEGES ON telefono_persona TO volontario;
GRANT SELECT,UPDATE ON volontario TO volontario;
GRANT SELECT ON partecipa TO volontario;
GRANT SELECT ON turno_lavorativo TO volontario;
GRANT SELECT ON centro_mobile TO volontario;
GRANT SELECT ON laboratorio_analisi TO volontario;
GRANT SELECT ON telefono_lab_analisi TO volontario;
-- PROFESSIONISTA SANITARIO
GRANT ALL PRIVILEGES ON persona TO pro_sanitario;
GRANT SELECT ON telefono_persona TO pro_sanitario;
GRANT ALL PRIVILEGES ON donatore TO pro_sanitario;
GRANT SELECT ON volontario TO pro_sanitario;
GRANT ALL PRIVILEGES ON donazione TO pro_sanitario;
GRANT SELECT ON turno_lavorativo TO pro_sanitario;
GRANT SELECT ON laboratorio_analisi TO pro_sanitario;
GRANT SELECT ON telefono_lab_analisi TO pro_sanitario;
GRANT SELECT ON professionista_sanitario TO pro_sanitario;
GRANT ALL PRIVILEGES ON telefono_pro_san TO pro_sanitario;
GRANT SELECT ON assiste TO pro_sanitario;
-- TECNICO SANITARIO
GRANT SELECT ON persona TO tec_sanitario;
GRANT SELECT ON telefono_persona TO tec_sanitario;
GRANT SELECT ON donatore TO tec_sanitario;
GRANT SELECT ON donazione TO tec_sanitario;
GRANT ALL PRIVILEGES ON composto_da TO tec_sanitario;
GRANT SELECT ON esame TO tec_sanitario;
GRANT SELECT ON laboratorio_analisi TO tec_sanitario;
GRANT ALL PRIVILEGES ON referto TO tec_sanitario;
GRANT SELECT ON telefono_lab_analisi TO tec_sanitario;
-- FARMACISTA
GRANT SELECT ON tessera TO farmacista;
GRANT ALL PRIVILEGES ON utilizza TO farmacista;
GRANT ALL PRIVILEGES ON convenzione TO farmacista;
GRANT SELECT ON farmacia TO farmacista;
GRANT ALL PRIVILEGES ON telefono_farmacia TO farmacista;
-- COORDINATORE
GRANT SELECT ON volontario TO coordinatore;
GRANT ALL PRIVILEGES ON partecipa TO coordinatore;
GRANT ALL PRIVILEGES ON turno_lavorativo TO coordinatore;
GRANT SELECT ON centro_mobile TO coordinatore;
GRANT SELECT ON laboratorio_analisi TO coordinatore;
GRANT SELECT ON telefono_lab_analisi TO coordinatore;
GRANT SELECT ON professionista_sanitario TO coordinatore;
GRANT SELECT ON telefono_pro_san TO coordinatore;
GRANT ALL PRIVILEGES ON assiste TO coordinatore;