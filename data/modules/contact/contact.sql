SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
--SET row_security = off;


CREATE SCHEMA contact;


SET search_path = contact, pg_catalog;
SET default_with_oids = false;

------------------------
--TABLES AND SEQUENCES--
------------------------

CREATE TABLE t_obs_contact (
    id_obs_contact bigint NOT NULL,
    id_lot integer NOT NULL,
    id_nomenclature_obs_technique integer NOT NULL DEFAULT 343,
    id_digitiser integer,
    date_min date NOT NULL,
    date_max date NOT NULL,
    obs_hour integer,
    insee character(5),
    altitude_min integer,
    altitude_max integer,
    initial_entry character varying(20),
    deleted boolean DEFAULT false NOT NULL,
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now(),
    obs_context text,
    comment text,
    the_geom_local public.geometry(Geometry,MYLOCALSRID),
    the_geom_3857 public.geometry(Geometry,3857),
    CONSTRAINT enforce_dims_the_geom_3857 CHECK ((public.st_ndims(the_geom_3857) = 2)),
    CONSTRAINT enforce_dims_the_geom_local CHECK ((public.st_ndims(the_geom_local) = 2)),
    CONSTRAINT enforce_srid_the_geom_3857 CHECK ((public.st_srid(the_geom_3857) = 3857)),
    CONSTRAINT enforce_srid_the_geom_local CHECK ((public.st_srid(the_geom_local) = MYLOCALSRID))
);

CREATE SEQUENCE t_obs_contact_id_obs_contact_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE t_obs_contact_id_obs_contact_seq OWNED BY t_obs_contact.id_obs_contact;
ALTER TABLE ONLY t_obs_contact ALTER COLUMN id_obs_contact SET DEFAULT nextval('t_obs_contact_id_obs_contact_seq'::regclass);
SELECT pg_catalog.setval('t_obs_contact_id_obs_contact_seq', 1, false);


CREATE TABLE t_occurrences_contact (
    id_occurrence_contact bigint NOT NULL,
    id_obs_contact bigint NOT NULL,
    id_nomenclature_obs_meth integer DEFAULT 42,
    id_nomenclature_bio_condition integer NOT NULL DEFAULT 177,
    id_nomenclature_bio_status integer DEFAULT 30,
    id_nomenclature_naturalness integer DEFAULT 182,
    id_nomenclature_exist_proof integer DEFAULT 91,
    id_nomenclature_obs_status integer DEFAULT 101,
    id_nomenclature_valid_status integer DEFAULT 347,
    id_nomenclature_accur_level integer DEFAULT 163,
    id_validator integer,
    determiner character varying(255),
    determination_method character varying(255),
    cd_nom integer,
    nom_cite character varying(255),
    v_taxref character varying(6) DEFAULT 'V9.0',
    sample_number_contact text,
    digital_proof text,
    non_digital_proof text,
    deleted boolean DEFAULT false NOT NULL,
    meta_create_date timestamp without time zone,
    meta_update_date timestamp without time zone,
    comment character varying
);
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_obs_meth IS 'Correspondance nomenclature INPN = methode_obs';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_bio_condition IS 'Correspondance nomenclature INPN = etat_bio';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_bio_status IS 'Correspondance nomenclature INPN = statut_bio';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_naturalness IS 'Correspondance nomenclature INPN = naturalite';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_exist_proof IS 'Correspondance nomenclature INPN = preuve_exist';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_obs_status IS 'Correspondance nomenclature INPN = statut_obs';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_valid_status IS 'Correspondance nomenclature INPN = statut_valide';
COMMENT ON COLUMN contact.t_occurrences_contact.id_nomenclature_accur_level IS 'Correspondance nomenclature INPN = niv_precis';

CREATE SEQUENCE t_occurrences_contact_id_occurrence_contact_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE t_occurrences_contact_id_occurrence_contact_seq OWNED BY t_occurrences_contact.id_occurrence_contact;
ALTER TABLE ONLY t_occurrences_contact ALTER COLUMN id_occurrence_contact SET DEFAULT nextval('t_occurrences_contact_id_occurrence_contact_seq'::regclass);
SELECT pg_catalog.setval('t_occurrences_contact_id_occurrence_contact_seq', 1, false);


CREATE TABLE cor_stage_sexe_number (
    id_occurrence_contact bigint NOT NULL,
    id_nomenclature_life_stage integer NOT NULL,
    id_nomenclature_sexe integer NOT NULL,
    id_nomenclature_obj_count integer NOT NULL DEFAULT 166,
    id_nomenclature_typ_count integer DEFAULT 107,
    counting_min integer,
    counting_max integer
);


CREATE TABLE cor_role_obs_contact (
    id_obs_contact bigint NOT NULL,
    id_role integer NOT NULL
);


---------------
--PRIMARY KEY--
---------------
ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT pk_t_occurrences_contact PRIMARY KEY (id_occurrence_contact);

ALTER TABLE ONLY t_obs_contact
    ADD CONSTRAINT pk_t_obs_contact PRIMARY KEY (id_obs_contact);

ALTER TABLE ONLY cor_stage_sexe_number
    ADD CONSTRAINT pk_cor_stage_sexe_number_contact PRIMARY KEY (id_occurrence_contact, id_nomenclature_life_stage, id_nomenclature_sexe);

ALTER TABLE ONLY cor_role_obs_contact
    ADD CONSTRAINT pk_cor_role_obs_contact PRIMARY KEY (id_obs_contact, id_role);


---------------
--FOREIGN KEY--
---------------
ALTER TABLE ONLY t_obs_contact
    ADD CONSTRAINT fk_t_obs_contact_t_lots FOREIGN KEY (id_lot) REFERENCES meta.t_lots(id_lot) ON UPDATE CASCADE;

ALTER TABLE ONLY t_obs_contact
    ADD CONSTRAINT fk_t_obs_contact_obs_technique FOREIGN KEY (id_nomenclature_obs_technique) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_obs_contact
    ADD CONSTRAINT fk_t_obs_contact_t_roles FOREIGN KEY (id_digitiser) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_t_obs_contact FOREIGN KEY (id_obs_contact) REFERENCES t_obs_contact(id_obs_contact) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_t_roles FOREIGN KEY (id_validator) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_obs_meth FOREIGN KEY (id_nomenclature_obs_meth) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_bio_condition FOREIGN KEY (id_nomenclature_bio_condition) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_bio_status FOREIGN KEY (id_nomenclature_bio_status) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_naturalness FOREIGN KEY (id_nomenclature_naturalness) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_exist_proof FOREIGN KEY (id_nomenclature_exist_proof) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_obs_status FOREIGN KEY (id_nomenclature_obs_status) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_valid_status FOREIGN KEY (id_nomenclature_valid_status) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT fk_t_occurrences_contact_accur_level FOREIGN KEY (id_nomenclature_accur_level) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


ALTER TABLE ONLY cor_stage_sexe_number
    ADD CONSTRAINT fk_cor_stage_number_id_taxon FOREIGN KEY (id_occurrence_contact) REFERENCES t_occurrences_contact(id_occurrence_contact) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY cor_stage_sexe_number
    ADD CONSTRAINT fk_cor_stage_sexe_number_sexe FOREIGN KEY (id_nomenclature_sexe) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_stage_sexe_number
    ADD CONSTRAINT fk_cor_stage_sexe_number_life_stage FOREIGN KEY (id_nomenclature_life_stage) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_stage_sexe_number
    ADD CONSTRAINT fk_cor_stage_sexe_number_obj_count FOREIGN KEY (id_nomenclature_obj_count) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_stage_sexe_number
    ADD CONSTRAINT fk_cor_stage_sexe_number_typ_count FOREIGN KEY (id_nomenclature_typ_count) REFERENCES nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


ALTER TABLE ONLY cor_role_obs_contact
    ADD CONSTRAINT fk_cor_role_obs_contact_t_obs_contact FOREIGN KEY (id_obs_contact) REFERENCES t_obs_contact(id_obs_contact) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY cor_role_obs_contact
    ADD CONSTRAINT fk_cor_role_obs_contact_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;

--------------
--CONSTRAINS--
--------------
ALTER TABLE ONLY t_obs_contact
    ADD CONSTRAINT check_t_obs_contact_altitude_max CHECK (altitude_max >= altitude_min);

ALTER TABLE ONLY t_obs_contact
    ADD CONSTRAINT check_t_obs_contact_date_max CHECK (date_max >= date_min);

ALTER TABLE t_obs_contact
  ADD CONSTRAINT check_t_obs_contact_obs_technique CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_obs_technique,100));


ALTER TABLE ONLY t_occurrences_contact
    ADD CONSTRAINT check_t_occurrences_contact_cd_nom_isinbib_noms CHECK (taxonomie.check_is_inbibnoms(cd_nom));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check_t_obs_contact_obs_meth CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_obs_meth,14));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check_t_occurrences_contact_bio_condition CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_bio_condition,7));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check__occurrences_contact_bio_status CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_bio_status,13));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check__occurrences_contact_naturalness CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_naturalness,8));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check__occurrences_contact_exist_proof CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_exist_proof,15));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check__occurrences_contact_obs_status CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_obs_status,18));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check__occurrences_contact_valid_status CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_valid_status,101));

ALTER TABLE t_occurrences_contact
  ADD CONSTRAINT check__occurrences_contact_accur_level CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_accur_level,5));


ALTER TABLE cor_stage_sexe_number
  ADD CONSTRAINT check_t_obs_contact_life_stage CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_life_stage,10));

ALTER TABLE cor_stage_sexe_number
  ADD CONSTRAINT check_t_obs_contact_sexe CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_sexe,9));

ALTER TABLE cor_stage_sexe_number
  ADD CONSTRAINT check_t_obs_contact_obj_count CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_obj_count,6));

ALTER TABLE cor_stage_sexe_number
  ADD CONSTRAINT check_t_obs_contact_typ_count CHECK (nomenclatures.check_nomenclature_type(id_nomenclature_typ_count,21));


----------------------
--FUNCTIONS TRIGGERS--
----------------------
CREATE OR REPLACE FUNCTION insert_occurrences_contact()
  RETURNS trigger AS
$BODY$
DECLARE
    idsensibilite integer;
BEGIN
    --calcul de la valeur de la sensibilité
    SELECT INTO idsensibilite nomenclatures.calculate_sensitivity(new.cd_nom,new.id_nomenclature_obs_meth);
    new.id_nomenclature_accur_level = idsensibilite;
    RETURN NEW;             
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION update_occurrences_contact()
  RETURNS trigger AS
$BODY$
DECLARE
    idsensibilite integer;
BEGIN
    --calcul de la valeur de la sensibilité
    SELECT INTO idsensibilite nomenclatures.calculate_sensitivity(new.cd_nom,new.id_nomenclature_obs_meth);
    new.id_nomenclature_accur_level = idsensibilite;
    RETURN NEW;             
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


------------
--TRIGGERS--
------------
CREATE TRIGGER tri_insert_occurrences_contact
  BEFORE INSERT
  ON t_occurrences_contact
  FOR EACH ROW
  EXECUTE PROCEDURE insert_occurrences_contact();

CREATE TRIGGER tri_update_occurrences_contact
  BEFORE INSERT
  ON t_occurrences_contact
  FOR EACH ROW
  EXECUTE PROCEDURE update_occurrences_contact();


---------
--DATAS--
---------

INSERT INTO meta.t_lots  VALUES (1, 'contact', 'Observation aléatoire de la faune, de la flore ou de la fonge', 1, 2, 2, 2, 2, true, NULL, '2017-06-01 00:00:00', '2017-06-01 00:00:00');

INSERT INTO synthese.bib_modules (id_module, name_module, desc_module, entity_module_pk_field, url_module, target, picto_module, groupe_module, actif) VALUES (1, 'contact', 'Données issues du contact aléatoire', 'contact.t_occurrences_contact.id_occurrence_contact', '/contact', NULL, NULL, 'CONTACT', true);

INSERT INTO t_obs_contact VALUES(1,1,343,1,'2017-01-01','2017-01-01',12,'05100',5,10,'web',FALSE,NULL,NULL,'exemple test',NULL,NULL);
SELECT pg_catalog.setval('t_obs_contact_id_obs_contact_seq', 2, true);

INSERT INTO t_occurrences_contact VALUES(1,1,65,177,30,182,91,101,347,163,1,'gil','gees',60612,'Lynx Boréal','V9.0','','','poil',FALSE, now(),now(),'test');