-- public.tiger_arealm definition

-- Drop table

DROP TABLE public.tiger_arealm;

CREATE TABLE public.tiger_arealm (
	gid serial4 NOT NULL,
	statefp varchar(2) NULL,
	ansicode varchar(8) NULL,
	areaid varchar(22) NULL,
	fullname varchar(100) NULL,
	mtfcc varchar(5) NULL,
	aland float8 NULL,
	awater float8 NULL,
	intptlat varchar(11) NULL,
	intptlon varchar(12) NULL,
	partflg varchar(1) NULL,
	the_geom public.geometry(multipolygon) NULL,
	uid uuid NULL DEFAULT uuid_generate_v4(),
	"type" text NULL,
	CONSTRAINT tiger_arealm_pkey PRIMARY KEY (gid)
);
CREATE INDEX tiger_arealm_geom_idx ON public.tiger_arealm USING gist (the_geom);
CREATE INDEX tiger_arealm_mtfcc_idx ON public.tiger_arealm USING btree (mtfcc);
CREATE INDEX tiger_arealm_name_idx ON public.tiger_arealm USING gin (fullname gin_trgm_ops);



-- public.tiger_areawater definition

-- Drop table

-- DROP TABLE public.tiger_areawater;

CREATE TABLE public.tiger_areawater (
	gid serial4 NOT NULL,
	ansicode varchar(8) NULL,
	hydroid varchar(22) NULL,
	fullname varchar(100) NULL,
	mtfcc varchar(5) NULL,
	aland float8 NULL,
	awater float8 NULL,
	intptlat varchar(11) NULL,
	intptlon varchar(12) NULL,
	the_geom public.geometry(multipolygon) NULL,
	"type" text NULL,
	CONSTRAINT tiger_areawater_pkey PRIMARY KEY (gid)
);
CREATE INDEX tiger_areawater_geom_idx ON public.tiger_areawater USING gist (the_geom);
CREATE INDEX tiger_areawater_mtfcc_idx ON public.tiger_areawater USING btree (mtfcc);
CREATE INDEX tiger_areawater_name_idx ON public.tiger_areawater USING gin (fullname gin_trgm_ops);


-- public.tiger_counties definition

-- Drop table

-- DROP TABLE public.tiger_counties;

CREATE TABLE public.tiger_counties (
	gid serial4 NOT NULL,
	statefp varchar(2) NULL,
	countyfp varchar(3) NULL,
	countyns varchar(8) NULL,
	geoid varchar(5) NULL,
	"name" varchar(100) NULL,
	namelsad varchar(100) NULL,
	lsad varchar(2) NULL,
	classfp varchar(2) NULL,
	mtfcc varchar(5) NULL,
	csafp varchar(3) NULL,
	cbsafp varchar(5) NULL,
	metdivfp varchar(5) NULL,
	funcstat varchar(1) NULL,
	aland float8 NULL,
	awater float8 NULL,
	intptlat varchar(11) NULL,
	intptlon varchar(12) NULL,
	the_geom public.geometry(multipolygon) NULL,
	"type" text NULL,
	CONSTRAINT tiger_counties_pkey PRIMARY KEY (gid)
);
CREATE INDEX tiger_counties_geom_idx ON public.tiger_counties USING gist (the_geom);
CREATE INDEX tiger_counties_lsad_idx ON public.tiger_counties USING btree (lsad);
CREATE INDEX tiger_counties_name_idx ON public.tiger_counties USING gin (name gin_trgm_ops);
