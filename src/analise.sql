-- copiar arquivo Cartorios~utf8.csv para /tmp
DROP FOREIGN TABLE IF EXISTS vw_cartorios_original CASCADE;
CREATE FOREIGN TABLE vw_cartorios_original (
  "UF" text,             "CNPJ" text,           "CNS" text,
  "Data de Instalação" text,  "Nome Oficial" text,
  "Nome Fantasia" text,  "Endereço" text,  "Bairro" text,
  "Município" text,  "CEP" text,  "Nome do Titular" text,
  "Nome do Substituto" text,  "Nome do Juiz" text,  "Homepage" text,
  "Email" text,  "Telefone" text,  "Fax" text,  "Observação" text,
  "Última Atualização" text,  "Horário de Funcionamento" text,
  "Área de Abrangência" text,  "Atribuições" text,  "Comarca" text,  "Entrância" text,
  nada text
) SERVER csv_files OPTIONS (
   filename '/tmp/Cartorios2013~utf8.csv', -- pasta permitida para qualquer PostgreSQL
   format 'csv',
   delimiter ';',
   quote '"',
   header 'true'
);

CREATE SCHEMA IF NOT EXISTS lib;

CREATE or replace FUNCTION lib.brdate2isodate(text,text default NULL) RETURNS text AS $f$
	SELECT CASE
		WHEN array_length(x,1)>1 THEN concat(x[3],'-',x[2],'-',x[1])
		ELSE CASE WHEN $2 IS NOT NULL THEN $2||$1 ELSE NULL END
	END
	FROM (SELECT regexp_split_to_array(COALESCE($1,''), '/')) t(x)
$f$ language SQL IMMUTABLE;

CREATE or replace FUNCTION array_distinct_sort (ANYARRAY) RETURNS ANYARRAY AS $f$
	SELECT ARRAY(SELECT DISTINCT unnest($1) ORDER BY 1)
$f$ language SQL strict IMMUTABLE;

CREATE or replace FUNCTION lib.supertrim(
	-- sanitize text
	text,       		-- 1. input string (many words separed by spaces or punctuation)
	text DEFAULT ' ' 	-- 2. output separator
) RETURNS text AS $f$
  SELECT
	TRIM( regexp_replace(  -- for review: regex(regex()) for ` , , ` remove
		TRIM(regexp_replace($1,E'[\\n\\r \\+/,;:\\(\\)\\{\\}\\[\\]="\\s ]*[\\+/,;:\\(\\)\\{\\}\\[\\]="]+[\\+/,;:\\(\\)\\{\\}\\[\\]="\\s ]*|[\\s ]+[–\\-][\\s ]+',
				   $2, 'g'),' ,'),   -- s*ps*|s-s
		E'[\\s ;\\|"]+[\\.\'][\\s ;\\|"]+|[\\s ;\\|"]+',    -- s.s|s
		$2,
		'g'
	))
$f$ LANGUAGE SQL IMMUTABLE;


CREATE or replace FUNCTION lib.cart_sanitize_abrangencia(text,text default ';') RETURNS text AS $f$
-- falta debug de trim, maldito ainda retorna espaco.
  SELECT array_to_string( array_distinct_sort(array_agg(lower(x))),  $2 )
  FROM (
    SELECT CASE WHEN x='' OR x IS NULL THEN NULL ELSE trim(lib.supertrim(x),chr(160)) END as x
  	FROM (
      SELECT trim(  regexp_split_to_table(COALESCE($1,''), ',')  , ' ;.,')
    ) t(x)
  ) t2
$f$ language SQL IMMUTABLE;


-- == ==
-- DROP VIEW vw_cartorios_basico cascade;
CREATE or replace VIEW vw_cartorios_basico AS
  SELECT "UF" uf, trim("CNPJ") cnpj, trim("CNS") cns,
    lower(trim("Nome Oficial",' ,.')) nome_oficial,
    trim("Município",' ,;.') municipio,  "CEP" cep, lower(trim("Homepage")) homepage,
    lib.brdate2isodate("Data de Instalação")::date as data_instalacao, -- falta sanitizar
    lib.cart_sanitize_abrangencia("Atribuições") atribuicoes,
    lib.cart_sanitize_abrangencia("Área de Abrangência") area_abrangencia,
    lower(trim("Comarca",' ,.;')) as comarca
  FROM  vw_cartorios_original
;

-- -- -- -- --
-- RELATORIOS:

CREATE or replace VIEW vw_cartorios_relat01_datas AS
 SELECT distinct data_instalacao as data_instalacao
 FROM vw_cartorios_basico
 ORDER BY 1 desc
; -- 2012-11-19, 2012-11-09, 2012-09-19. Determinou 2013 como ano de referencia.


CREATE or replace VIEW vw_cartorios_relat02_atribs AS
  SELECT regexp_split_to_table(atribuicoes,';') as atribuicoes,
         count(*) as n
  FROM vw_cartorios_basico
  GROUP BY 1 ORDER BY 1
;

CREATE or replace VIEW vw_cartorios_relat03_areas AS
  SELECT uf, replace(regexp_split_to_table(area_abrangencia,';'),'município de','') as area_abrangencia,
         count(*) as n
  FROM vw_cartorios_basico
  GROUP BY 1,2
  ORDER BY 3 desc, 1,2
;
------

CREATE or replace VIEW vw_cartorios_relat04_nonrepeat_v1 AS
 SELECT cns, array_distinct_sort(array_agg(cnpj)) as cnpjs,
        jsonb_agg(jsonb_build_object('cnpj',cnpj, 'uf',uf, 'cep',cep, 'atribuicoes',atribuicoes)) as info
 FROM vw_cartorios_basico
 group by 1,2 having count(*)>1
 ORDER BY 1
;
----
CREATE or replace VIEW vw_cartorios_relat04_nonrepeat_v2 AS
  SELECT cns,  round(avg(1+length(regexp_replace(atribuicoes, '[^;]+', '','g')))) as atrib_len_avg,
         count(*) n,
         count(distinct cnpj) as cnpjs,
         count(distinct cep) as ceps
  FROM vw_cartorios_basico
  group by 1 having count(*)>1
  ORDER BY 1
;

CREATE or replace VIEW vw_cartorios_relat04_nonrepeat_v3 AS
  SELECT cnpj, round(avg(1+length(regexp_replace(atribuicoes, '[^;]+', '','g')))) as atrib_len_avg,
         count(*) n,
         count(distinct cns) as cnss,
         count(distinct cep) as ceps
  FROM vw_cartorios_basico
  group by 1 having count(*)>1
  ORDER BY 1
;


-- -- -- -- --
-- OUTPUT:

COPY (select * from vw_cartorios_basico)
  TO '/tmp/cartorios2013_basico.csv' HEADER CSV;

COPY (select * from vw_cartorios_relat02_atribs)
  TO '/tmp/cartorios2013_relat02_atribs.csv' HEADER CSV;

COPY (select uf, trim(substr(area_abrangencia,0,30)) area_abrangencia,
              sum(n) as n
      from vw_cartorios_relat03_areas
      group by 1,2
      having sum(n)>2
      order by 3 desc, 1,2
) TO '/tmp/cartorios2013_relat03_areas_multi.csv' HEADER CSV;
