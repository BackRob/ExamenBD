-- =====================================================
-- EFT Semana 9 - Modelamiento de Bases de Datos
-- Caso: ANFP
-- Usuario: PRY2204_S9
-- =====================================================

-- Borrado de objetos (para poder ejecutar el script varias veces)
-- la primera vez estos DROP dan error porque las tablas no existen, es normal
DROP TABLE HISTORIAL_CLUB CASCADE CONSTRAINTS;
DROP TABLE JUGADOR_IDIOMA CASCADE CONSTRAINTS;
DROP TABLE PERSONAL_PLANTA CASCADE CONSTRAINTS;
DROP TABLE JUGADOR CASCADE CONSTRAINTS;
DROP TABLE TRABAJADOR CASCADE CONSTRAINTS;
DROP TABLE IDIOMA CASCADE CONSTRAINTS;
DROP TABLE ESCUELA_FUTBOL CASCADE CONSTRAINTS;
DROP TABLE CLUB_FUTBOL CASCADE CONSTRAINTS;
DROP TABLE ASOCIACION CASCADE CONSTRAINTS;
DROP TABLE ESTADO_CIVIL CASCADE CONSTRAINTS;
DROP TABLE NACIONALIDAD CASCADE CONSTRAINTS;
DROP TABLE COMUNA CASCADE CONSTRAINTS;
DROP TABLE REGION CASCADE CONSTRAINTS;
DROP SEQUENCE SEQ_CLUB;


-- =====================================================
-- CREACION DE TABLAS
-- primero las que no tienen FK
-- =====================================================

CREATE TABLE REGION (
    id_region  NUMBER(2)     NOT NULL,
    nombre     VARCHAR2(50)  NOT NULL
);
ALTER TABLE REGION ADD CONSTRAINT REGION_PK PRIMARY KEY (id_region);


CREATE TABLE COMUNA (
    id_comuna  NUMBER(4)     NOT NULL,
    id_region  NUMBER(2)     NOT NULL,
    nombre     VARCHAR2(50)  NOT NULL
);
ALTER TABLE COMUNA ADD CONSTRAINT COMUNA_PK PRIMARY KEY (id_comuna);


-- PK con IDENTITY que parte en 210 y sube de 2 en 2
CREATE TABLE NACIONALIDAD (
    id_nacion    NUMBER(4) GENERATED ALWAYS AS IDENTITY (START WITH 210 INCREMENT BY 2),
    descripcion  VARCHAR2(30) NOT NULL
);
ALTER TABLE NACIONALIDAD ADD CONSTRAINT NACIONALIDAD_PK PRIMARY KEY (id_nacion);


CREATE TABLE ESTADO_CIVIL (
    id_estado_civil  NUMBER(2)     NOT NULL,
    descripcion      VARCHAR2(20)  NOT NULL
);
ALTER TABLE ESTADO_CIVIL ADD CONSTRAINT ESTADO_CIVIL_PK PRIMARY KEY (id_estado_civil);


CREATE TABLE ASOCIACION (
    id_asociacion      NUMBER(4)     NOT NULL,
    nombre_asociacion  VARCHAR2(60)  NOT NULL,
    fecha_creacion     DATE          NOT NULL,
    tipo_asociacion    CHAR(1)       NOT NULL
);
ALTER TABLE ASOCIACION ADD CONSTRAINT ASOCIACION_PK PRIMARY KEY (id_asociacion);
-- la fecha de creacion tiene que ser igual o posterior al 31-12-1980
ALTER TABLE ASOCIACION ADD CONSTRAINT ASOCIACION_FECHA_CK
    CHECK (fecha_creacion >= TO_DATE('31-12-1980','DD-MM-YYYY'));
-- P = profesional, A = amateur
ALTER TABLE ASOCIACION ADD CONSTRAINT ASOCIACION_TIPO_CK
    CHECK (tipo_asociacion IN ('P','A'));


-- el codigo del club se genera con la secuencia SEQ_CLUB
CREATE TABLE CLUB_FUTBOL (
    id_club          NUMBER(5)      NOT NULL,
    nombre_club      VARCHAR2(50)   NOT NULL,
    patrimonio       NUMBER(15)     NOT NULL,
    ubicacion_calle  VARCHAR2(80)   NOT NULL,
    tipo_club        VARCHAR2(15)   DEFAULT 'Profesional' NOT NULL
);
ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_PK PRIMARY KEY (id_club);
ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_NOMBRE_UN UNIQUE (nombre_club);
ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_TIPO_CK
    CHECK (tipo_club IN ('Profesional','Amateur'));
ALTER TABLE CLUB_FUTBOL ADD CONSTRAINT CLUB_FUTBOL_PATRIMONIO_CK
    CHECK (patrimonio >= 0);


CREATE TABLE ESCUELA_FUTBOL (
    id_escuela       NUMBER(4)     NOT NULL,
    nombre           VARCHAR2(50)  NOT NULL,
    capacidad        NUMBER(5)     NOT NULL,
    fecha_fundacion  DATE          NOT NULL
);
ALTER TABLE ESCUELA_FUTBOL ADD CONSTRAINT ESCUELA_FUTBOL_PK PRIMARY KEY (id_escuela);


CREATE TABLE IDIOMA (
    id_idioma  NUMBER(3)     NOT NULL,
    nombre     VARCHAR2(30)  NOT NULL
);
ALTER TABLE IDIOMA ADD CONSTRAINT IDIOMA_PK PRIMARY KEY (id_idioma);


-- supertipo TRABAJADOR (tiene los datos comunes de jugadores y personal de planta)
CREATE TABLE TRABAJADOR (
    nro_inscripcion   NUMBER(10)    NOT NULL,
    rut               NUMBER(8)     NOT NULL,
    dv                CHAR(1)       NOT NULL,
    nombres           VARCHAR2(50)  NOT NULL,
    ap_paterno        VARCHAR2(30)  NOT NULL,
    ap_materno        VARCHAR2(30),
    sueldo_base       NUMBER(10)    NOT NULL,
    fecha_nacimiento  DATE          NOT NULL,
    genero            CHAR(1)       NOT NULL,
    fono_movil        VARCHAR2(15),
    email             VARCHAR2(60),
    direccion         VARCHAR2(80)  NOT NULL,
    tipo_trabajador   CHAR(1)       NOT NULL,
    id_comuna         NUMBER(4)     NOT NULL,
    id_estado_civil   NUMBER(2)     NOT NULL,
    id_nacion         NUMBER(4)     NOT NULL
);
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_PK PRIMARY KEY (nro_inscripcion);
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_RUT_UN UNIQUE (rut);
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_GENERO_CK CHECK (genero IN ('M','F'));
-- J = jugador, P = personal de planta
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_TIPO_CK CHECK (tipo_trabajador IN ('J','P'));
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_SUELDO_CK CHECK (sueldo_base > 0);


-- subtipo JUGADOR
CREATE TABLE JUGADOR (
    nro_inscripcion   NUMBER(10)    NOT NULL,
    puesto            VARCHAR2(20)  NOT NULL,
    monto_premios     NUMBER(12)    DEFAULT 0 NOT NULL,
    id_asociacion     NUMBER(4)     NOT NULL,
    id_escuela        NUMBER(4),
    anio_egreso       NUMBER(4)
);
ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_PK PRIMARY KEY (nro_inscripcion);
ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_PUESTO_CK
    CHECK (puesto IN ('Arquero','Defensa','Mediocampista','Delantero'));


-- subtipo PERSONAL DE PLANTA (horas y valor hora extra pueden quedar en null)
CREATE TABLE PERSONAL_PLANTA (
    nro_inscripcion    NUMBER(10)  NOT NULL,
    horas_trabajadas   NUMBER(4),
    valor_hora_extra   NUMBER(8),
    id_club            NUMBER(5)   NOT NULL
);
ALTER TABLE PERSONAL_PLANTA ADD CONSTRAINT PERSONAL_PLANTA_PK PRIMARY KEY (nro_inscripcion);


-- tabla intermedia jugador - idioma (N:M) con el nivel de dominio
CREATE TABLE JUGADOR_IDIOMA (
    nro_inscripcion  NUMBER(10)    NOT NULL,
    id_idioma        NUMBER(3)     NOT NULL,
    nivel_dominio    VARCHAR2(15)  NOT NULL
);
ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_PK PRIMARY KEY (nro_inscripcion, id_idioma);
ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_NIVEL_CK
    CHECK (nivel_dominio IN ('Basico','Intermedio','Avanzado','Nativo'));


-- historial de clubes del jugador (periodo de permanencia en cada club)
CREATE TABLE HISTORIAL_CLUB (
    nro_inscripcion      NUMBER(10)  NOT NULL,
    id_club              NUMBER(5)   NOT NULL,
    fecha_incorporacion  DATE        NOT NULL,
    fecha_termino        DATE
);
ALTER TABLE HISTORIAL_CLUB ADD CONSTRAINT HISTORIAL_CLUB_PK
    PRIMARY KEY (nro_inscripcion, id_club, fecha_incorporacion);
ALTER TABLE HISTORIAL_CLUB ADD CONSTRAINT HISTORIAL_CLUB_FECHAS_CK
    CHECK (fecha_termino IS NULL OR fecha_termino > fecha_incorporacion);


-- =====================================================
-- CLAVES FORANEAS
-- =====================================================
ALTER TABLE COMUNA ADD CONSTRAINT COMUNA_REGION_FK
    FOREIGN KEY (id_region) REFERENCES REGION (id_region);

ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_COMUNA_FK
    FOREIGN KEY (id_comuna) REFERENCES COMUNA (id_comuna);
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_ESTADO_CIVIL_FK
    FOREIGN KEY (id_estado_civil) REFERENCES ESTADO_CIVIL (id_estado_civil);
ALTER TABLE TRABAJADOR ADD CONSTRAINT TRABAJADOR_NACIONALIDAD_FK
    FOREIGN KEY (id_nacion) REFERENCES NACIONALIDAD (id_nacion);

ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_TRABAJADOR_FK
    FOREIGN KEY (nro_inscripcion) REFERENCES TRABAJADOR (nro_inscripcion);
ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_ASOCIACION_FK
    FOREIGN KEY (id_asociacion) REFERENCES ASOCIACION (id_asociacion);
ALTER TABLE JUGADOR ADD CONSTRAINT JUGADOR_ESCUELA_FK
    FOREIGN KEY (id_escuela) REFERENCES ESCUELA_FUTBOL (id_escuela);

ALTER TABLE PERSONAL_PLANTA ADD CONSTRAINT PERSONAL_PLANTA_TRABAJADOR_FK
    FOREIGN KEY (nro_inscripcion) REFERENCES TRABAJADOR (nro_inscripcion);
ALTER TABLE PERSONAL_PLANTA ADD CONSTRAINT PERSONAL_PLANTA_CLUB_FK
    FOREIGN KEY (id_club) REFERENCES CLUB_FUTBOL (id_club);

ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_JUGADOR_FK
    FOREIGN KEY (nro_inscripcion) REFERENCES JUGADOR (nro_inscripcion);
ALTER TABLE JUGADOR_IDIOMA ADD CONSTRAINT JUGADOR_IDIOMA_IDIOMA_FK
    FOREIGN KEY (id_idioma) REFERENCES IDIOMA (id_idioma);

ALTER TABLE HISTORIAL_CLUB ADD CONSTRAINT HISTORIAL_CLUB_JUGADOR_FK
    FOREIGN KEY (nro_inscripcion) REFERENCES JUGADOR (nro_inscripcion);
ALTER TABLE HISTORIAL_CLUB ADD CONSTRAINT HISTORIAL_CLUB_CLUB_FK
    FOREIGN KEY (id_club) REFERENCES CLUB_FUTBOL (id_club);


-- =====================================================
-- SECUENCIA PARA CLUB_FUTBOL (parte en 703, de 4 en 4)
-- =====================================================
CREATE SEQUENCE SEQ_CLUB
    START WITH 703
    INCREMENT BY 4;


-- =====================================================
-- POBLAMIENTO DE TABLAS
-- =====================================================

-- REGION
-- se agregan tambien la region 8 y 16 porque las comunas de Concepcion y Chillan
-- las usan, si no se agregan da error de FK (ORA-02291)
INSERT INTO REGION VALUES (1, 'ARICA Y PARINACOTA Y TARAPACA');
INSERT INTO REGION VALUES (2, 'ANTOFAGASTA');
INSERT INTO REGION VALUES (3, 'ATACAMA Y COQUIMBO');
INSERT INTO REGION VALUES (5, 'VALPARAISO');
INSERT INTO REGION VALUES (13, 'METROPOLITANA');
INSERT INTO REGION VALUES (8, 'BIOBIO');
INSERT INTO REGION VALUES (16, 'ÑUBLE');

-- COMUNA
INSERT INTO COMUNA VALUES (101, 13, 'Santiago');
INSERT INTO COMUNA VALUES (102, 5, 'Valparaíso');
INSERT INTO COMUNA VALUES (103, 8, 'Concepción');
INSERT INTO COMUNA VALUES (104, 2, 'Antofagasta');
INSERT INTO COMUNA VALUES (105, 16, 'Chillán');

-- ASOCIACION
INSERT INTO ASOCIACION VALUES (25, 'Asociación de Fútbol de Santiago', TO_DATE('15-05-2001','DD-MM-YYYY'), 'P');
INSERT INTO ASOCIACION VALUES (26, 'Asociación Nacional de Fútbol Amateur', TO_DATE('10-03-1998','DD-MM-YYYY'), 'A');
INSERT INTO ASOCIACION VALUES (27, 'Asociación de Fútbol de Valparaíso', TO_DATE('21-07-1987','DD-MM-YYYY'), 'P');
INSERT INTO ASOCIACION VALUES (28, 'Asociación de Fútbol de Concepción', TO_DATE('30-11-1995','DD-MM-YYYY'), 'A');
INSERT INTO ASOCIACION VALUES (29, 'Asociación de Fútbol de Antofagasta', TO_DATE('25-06-2003','DD-MM-YYYY'), 'P');
INSERT INTO ASOCIACION VALUES (30, 'Asociación de Fútbol de Temuco', TO_DATE('12-01-2010','DD-MM-YYYY'), 'A');
INSERT INTO ASOCIACION VALUES (31, 'Asociación de Fútbol de Rancagua', TO_DATE('08-09-1999','DD-MM-YYYY'), 'P');
INSERT INTO ASOCIACION VALUES (32, 'Asociación de Fútbol de Puerto Montt', TO_DATE('20-04-2005','DD-MM-YYYY'), 'A');
INSERT INTO ASOCIACION VALUES (33, 'Asociación de Fútbol de La Serena', TO_DATE('14-08-2012','DD-MM-YYYY'), 'P');
INSERT INTO ASOCIACION VALUES (34, 'Asociación de Fútbol de Chillán', TO_DATE('01-12-2018','DD-MM-YYYY'), 'A');

-- NACIONALIDAD (el id lo genera el IDENTITY: 210, 212, 214...)
INSERT INTO NACIONALIDAD (descripcion) VALUES ('Chilena');
INSERT INTO NACIONALIDAD (descripcion) VALUES ('Argentina');
INSERT INTO NACIONALIDAD (descripcion) VALUES ('Peruana');
INSERT INTO NACIONALIDAD (descripcion) VALUES ('Boliviana');
INSERT INTO NACIONALIDAD (descripcion) VALUES ('Brasileña');

-- CLUB_FUTBOL (el id lo da la secuencia: 703, 707, 711...)
INSERT INTO CLUB_FUTBOL VALUES (SEQ_CLUB.NEXTVAL, 'Colo-Colo', 500000000, 'Av. Marathon 5300', 'Profesional');
INSERT INTO CLUB_FUTBOL VALUES (SEQ_CLUB.NEXTVAL, 'Universidad de Chile', 450000000, 'Av. El Parrón 0931', 'Profesional');
INSERT INTO CLUB_FUTBOL VALUES (SEQ_CLUB.NEXTVAL, 'Deportes Antofagasta', 180000000, 'Avenida Angamos 01606', 'Profesional');
INSERT INTO CLUB_FUTBOL VALUES (SEQ_CLUB.NEXTVAL, 'Huachipato', 220000000, 'Avenida Desiderio García 909', 'Profesional');
INSERT INTO CLUB_FUTBOL VALUES (SEQ_CLUB.NEXTVAL, 'Ñublense', 170000000, 'Avenida Pedro Aguirre Cerda 1003', 'Profesional');

COMMIT;


-- =====================================================
-- INFORMES
-- =====================================================

-- INFORME 1: asociaciones profesionales creadas despues del 2000
SELECT 'ID:' || id_asociacion || ' * ' || nombre_asociacion AS "ASOCIACION",
       TO_CHAR(fecha_creacion, 'DD-MM-YYYY') AS "CREADA",
       tipo_asociacion AS "TIPO"
FROM ASOCIACION
WHERE tipo_asociacion = 'P'
  AND EXTRACT(YEAR FROM fecha_creacion) > 2000
ORDER BY fecha_creacion DESC;


-- INFORME 2: patrimonio de los clubes en pesos y en dolares (dolar a $955)
SELECT id_club AS "CLUB",
       nombre_club AS "NOMBRE CLUB",
       patrimonio AS "PATRIMONIO EN PESOS",
       patrimonio / 955 AS "PATRIMONIO EN DOLARES"
FROM CLUB_FUTBOL
WHERE nombre_club LIKE '%a%'
  AND patrimonio > 200000000
  AND tipo_club = 'Profesional'
ORDER BY id_club DESC;
