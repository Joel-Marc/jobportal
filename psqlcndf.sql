--SQL STATEMENTS and stuff 


CREATE TABLE loga (
	name VARCHAR ( 30 ) NOT NULL ,
	password VARCHAR (1) NOT NULL,
	PRIMARY KEY(name)	
);

CREATE TABLE loge (
	name VARCHAR ( 30 ) NOT NULL ,
	password VARCHAR (1) NOT NULL,
	PRIMARY KEY(name)	
);

CREATE TABLE jobs (
	j_id serial PRIMARY KEY,
	job_title VARCHAR ( 50 ) NOT NULL,
	degree_req VARCHAR ( 2 ) NOT NULL,
	loca VARCHAR ( 50 ) NOT NULL,
	salary NUMERIC (5,2) NOT NULL
);


CREATE TABLE empdet (
  f_name VARCHAR ( 50 ) NOT NULL,
  l_name VARCHAR ( 50 ) NOT NULL,
  phno VARCHAR ( 10 ) NOT NULL,
  email VARCHAR ( 255 ) NOT NULL,
  qal VARCHAR ( 2 ) NOT NULL,
  skills VARCHAR ( 150 ) NOT NULL,
  age INTEGER NOT NULL,
  gender VARCHAR ( 2 ) NOT NULL,
  p_exp NUMERIC (5,2) NOT NULL,
  name VARCHAR ( 30 ) NOT NULL,
  PRIMARY KEY (name),
  FOREIGN KEY (name)
      REFERENCES loge (name)
);

CREATE TABLE appl (
	j_id INTEGER NOT NULL,
	name VARCHAR ( 30 ) NOT NULL,
	status VARCHAR (1) NOT NULL,
	PRIMARY KEY (j_id, name),
  	FOREIGN KEY (j_id)
      REFERENCES jobs (j_id),
  	FOREIGN KEY (name)
      REFERENCES loge (name)
	
);

create or replace function sume(
  aname varchar
) 
	returns table (
		j_title varchar,
		loca varchar,
		status varchar
	) 
	language plpgsql
as $$
begin
	return query 
	select distinct jobs.job_title as j_title,jobs.loca as locat,status as stat 
		from jobs join appl on jobs.j_id=appl.j_id 
		where appl.name=aname;

end;$$


create or replace function suma(
		out app integer,
		out acpt integer,
		out rjct integer
	) 
	language plpgsql
as $$
begin
		select count(*) into app from appl where status='O';
		select count(*) into rjct from appl where status='R';
		select count(*) into acpt from appl where status='A';
end;$$



create or replace function showanr(

	gen varchar,
	degr varchar,
	pexp int
) 
returns table (
	t1 varchar,
	t2 varchar,
	t3 numeric,
	t4 text,
	t5 int,
	t6 varchar,
	t7 numeric,
	t8 varchar,
	t9 int
)
	language plpgsql
as $$
declare 
 base text := 'select jobs.job_title as j1,jobs.loca as j2,jobs.salary as j3,
 concat_ws('' '',empdet.f_name,empdet.l_name) as j4,empdet.age as j5,
 empdet.gender as j6,empdet.p_exp as j7,empdet.name as j8,appl.j_id as j9
from jobs join appl on jobs.j_id=appl.j_id
join empdet on appl.name=empdet.name where appl.status = ''O''';
begin
if degr != '' then
	base := base || ' AND empdet.qal= ''' || degr || '''';
end if;

if gen != '' then
	base := base || ' AND empdet.gender= ''' || gen || ''''; 
end if;

if pexp is not null then
	base := base || ' AND empdet.p_exp >= ''' || pexp || '''';
end if;

return query execute base;
	
end;$$



CREATE OR REPLACE FUNCTION fun1() 
RETURNS trigger 
AS $$ 
declare
sele empdet.qal%type;
sela jobs.degree_req%type ;
BEGIN
select qal
from empdet into sele
where name = NEW.name;
select degree_req
from jobs into sela
where j_id = NEW.j_id;
if (sele != sela) then raise notice 'Job requires a different Qualification';
end if;
RETURN NEW;
END;
$$ LANGUAGE 'plpgsql';

-- @block

CREATE TRIGGER RES_TRG before
INSERT ON appl FOR EACH ROW EXECUTE PROCEDURE fun1();