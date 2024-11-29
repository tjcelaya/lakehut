CREATE USER icebergcat      WITH PASSWORD 'icebergcat';
CREATE DATABASE icebergcat  OWNER icebergcat;
GRANT ALL PRIVILEGES        ON DATABASE icebergcat TO icebergcat;

CREATE USER airflow         WITH PASSWORD 'airflow';
CREATE DATABASE airflow     OWNER airflow;
GRANT ALL PRIVILEGES        ON DATABASE airflow TO airflow;

CREATE USER spark           WITH PASSWORD 'spark';
CREATE DATABASE spark       OWNER spark;
GRANT ALL PRIVILEGES        ON DATABASE spark TO spark;

CREATE USER superset        WITH PASSWORD 'superset';
CREATE DATABASE superset    OWNER superset;
GRANT ALL PRIVILEGES        ON DATABASE superset TO superset;
