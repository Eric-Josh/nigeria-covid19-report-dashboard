
-- Database creation
create database nig_covid;

-- Table creation
drop table if exists nig_state_affected_tmp;
create table nig_state_affected_tmp(
	state varchar(50) default null,
	confirm_cases varchar(11) default null,
	on_admission varchar(11) default null,
	discharged varchar(11) default null,
	deaths varchar(11) default null,
	X decimal(10,8) not null,
	Y decimal(10,8) not null,
	id int(11) not null auto_increment,
	PRIMARY KEY (id)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- load data using infile for CSV
truncate table nig_state_affected_tmp;
LOAD DATA LOCAL 
INFILE '~/Desktop/py/covid19-dashboard/data/covid19.csv' 
INTO TABLE nig_state_affected_tmp
CHARACTER SET latin1 
FIELDS TERMINATED BY ","   
optionally enclosed by '"' 
lines terminated by '\n'
ignore 1 lines;

-- trim out white space from state
update nig_state_affected_tmp set state = trim(leading '\n' from state);

-- remove comma from count per state
update nig_state_affected_tmp set confirm_cases = CONVERT(REPLACE(REPLACE(confirm_cases, ',', ''), ',', ''), decimal(20,2)),
	on_admission = CONVERT(REPLACE(REPLACE(on_admission, ',', ''), ',', ''), decimal(20,2)),
	discharged = CONVERT(REPLACE(REPLACE(discharged, ',', ''), ',', ''), decimal(20,2)),
	deaths = CONVERT(REPLACE(REPLACE(deaths, ',', ''), ',', ''), decimal(20,2));

-- create transaction table
create table nig_state_affected as select * from nig_state_affected_tmp;

-- create transaction history table to get newly added records
create table nig_state_affected_history as select * from nig_state_affected;
ALTER TABLE `nig_state_affected_history` DROP `X`, DROP `Y`;

-- set data types back to int
-- alter table nig_state_affected change `confirm_cases` `confirm_cases` int(11) not null;
-- alter table nig_state_affected change `on_admission` `on_admission` int(11) not null;
-- alter table nig_state_affected change `discharged` `discharged` int(11) not null;
-- alter table nig_state_affected change `deaths` `deaths` int(11) not null;

-- create state lat, lng (should be ran only once)
drop table if exists nig_state_gps;
create table nig_state_gps(
	state varchar(50) default null,
	lat decimal(10,8) not null,
	lng decimal(10,8) not null,
	id int(11) not null auto_increment,
	PRIMARY KEY (id)
)ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- load data using infile for CSV
LOAD DATA LOCAL 
INFILE '~/Desktop/py/covid19-dashboard/data/state_lat_lng.csv' 
INTO TABLE nig_state_gps
CHARACTER SET latin1 
FIELDS TERMINATED BY ","   
optionally enclosed by '"' 
lines terminated by '\n'
ignore 1 lines;

-- update nig_state_affected with cordinates 
update nig_state_affected a 
	join nig_state_gps b on (a.state=b.state)
	set a.X=b.lng, a.Y=b.lat;

-- create triggers on update
DELIMITER //
CREATE TRIGGER nig_state_affected_trig BEFORE UPDATE
ON nig_state_affected
FOR EACH ROW
BEGIN
insert into nig_state_affected_history (
	state,
	confirm_cases,
	on_admission,
	discharged,
	deaths,
	id)
select 	
	state,
	confirm_cases,
	on_admission,
	discharged,
	deaths,
	id
  FROM nig_state_affected e
  WHERE e.id = new.id;
END //

