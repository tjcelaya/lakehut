CREATE USER airflow  WITH PASSWORD 'airflow';
CREATE USER spark    WITH PASSWORD 'spark';
CREATE USER superset WITH PASSWORD 'superset';

CREATE DATABASE airflow   OWNER airflow;
CREATE DATABASE spark     OWNER spark;
CREATE DATABASE superset  OWNER superset;

GRANT ALL PRIVILEGES ON DATABASE airflow  TO airflow;
GRANT ALL ON *.*                          TO airflow;
GRANT ALL ON SCHEMA public                TO airflow;

GRANT ALL PRIVILEGES ON DATABASE spark    TO spark;
GRANT ALL ON *.*                          TO spark;
GRANT ALL ON SCHEMA public                TO spark;

GRANT ALL PRIVILEGES ON DATABASE superset TO superset;
GRANT ALL ON *.*                          TO superset;
GRANT ALL ON SCHEMA public                TO superset;
