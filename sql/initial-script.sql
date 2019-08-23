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
)
