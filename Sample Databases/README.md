## Northwind Database
The files have been obtained from ["Lorin Thwaits" Northwind repository](https://github.com/lorint/Northwind) and modified and improved.

Copy the files to the client from which you want to export Northwind data to using `psql` command

a. Northwind_schema and data_with namespace.sql

Modified lorint full database creation sql script with added backward compatibility for role "admin".
 It suffices to run the following to install the database completely:
```shell
psql -Upostgres < Northwind_schema\ and\ data_with\ namespace.sql
```
---
b. Original lorint <ins>Schema and Data</ins> sql script. The following steps are required to install
 the database:
 1. Create the Northwind database
```shell
psql -Upostgres -c "create database \"Northwind\""
```
 2. Create the role "admin" for backward compatibility
```shell
psql -Upostgres -dNorthwind -c "
DO \$\$ BEGIN
    -- Check the major version number
    IF substring(current_setting('server_version_num') from 1 for 2)::integer < 81 THEN
        -- Create the role 'admin' if it does not exist
        IF NOT EXISTS ( SELECT 1 FROM pg_roles WHERE rolname = 'admin') THEN
            CREATE ROLE admin;
        END IF;
    END IF;
END \$\$;
"
```
 3. Import data (Tables without schema classification)
```shell
psql -Upostgres -dNorthwind < Northwind_lorint_schema\ and\ data.sql
```

