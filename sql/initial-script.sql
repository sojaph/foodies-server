-- database schema draft

DROP TABLE IF EXISTS public.ingredients cascade;
CREATE TABLE public.ingredients(
	id serial PRIMARY KEY,
	name VARCHAR(250) NOT NULL UNIQUE,
	vegetarian boolean,
	vegan boolean,
	keto boolean,
	paleo boolean
);

DROP TABLE IF EXISTS public.recipes cascade;
CREATE TABLE public.recipes(
	id serial PRIMARY KEY,
	name text NOT NULL,
	origin VARCHAR(250),
	description text
);

DROP TABLE IF EXISTS public.recipe_ingredients cascade;
CREATE TABLE public.recipe_ingredients(
	id serial PRIMARY,
	recipe_id integer,
	ingredient_id integer,
	amount VARCHAR(250),
	FOREIGN KEY (recipe_id) REFERENCES recipes (id),
	FOREIGN KEY (ingredient_id) REFERENCES ingredients (id)
);

DROP SCHEMA IF EXISTS audit cascade;
CREATE SCHEMA IF NOT EXISTS audit;

drop table if exists audit.foodies;
create table audit.foodies(
	id bigserial primary key,
	rel_id oid not null,
	table_name varchar(200) not null,
	audit_ts timestamp not null default now(), 
	operation varchar(10) not null,
	username varchar(200) not null default "current_user"(),
	before jsonb,
	after jsonb
);

-- FUNCTION: audit_trigger()
CREATE OR REPLACE FUNCTION public.audit_trigger()
 RETURNS trigger LANGUAGE plpgsql
AS $function$
declare
  audit_pk bigint;
begin
IF TG_OP = 'INSERT'
THEN
INSERT INTO audit.foodies (rel_id, table_name, operation, after)
VALUES (TG_RELID, TG_TABLE_NAME, TG_OP, to_jsonb(NEW)) returning id into audit_pk;
 new.audit_id := audit_pk;
RETURN NEW;
ELSIF TG_OP = 'UPDATE'
THEN
IF NEW != OLD THEN
 INSERT INTO audit.foodies (rel_id, table_name, operation, before, after)
VALUES (TG_RELID, TG_TABLE_NAME, TG_OP, to_jsonb(OLD), to_jsonb(NEW)) returning id into audit_pk;
 new.audit_id := audit_pk;
END IF;
RETURN NEW;
END IF;
end;
$function$;

CREATE TRIGGER ingredients_audit_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON public.ingredients
FOR EACH ROW
EXECUTE PROCEDURE public.audit_trigger();

CREATE TRIGGER recipes_audit_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON public.recipes
FOR EACH ROW
EXECUTE PROCEDURE public.audit_trigger();
