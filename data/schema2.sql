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

-- update count per state
update nig_state_affected a 
	join nig_state_affected_tmp b on (a.state=b.state)
	set a.confirm_cases=b.confirm_cases,
		a.on_admission=b.on_admission,
		a.discharged=b.discharged,
		a.deaths=b.deaths;




