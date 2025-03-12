## Northwind Database
The files have been obtained from ["Lorin Thwaits" Northwind repository](https://github.com/lorint/Northwind) and modified and improved.

Copy the files to the client from which you want to export Northwind data to using `psql` command

The Lorint SQL script has also been modified to add backward compatibility for the role "admin" that 
existed before PostgreSQL 8.1 but not in the later versions.

---
A. Original Lorint <b>Schema and Data</b> SQL script (<ins>Northwind_lorint_raw.sql</ins>).

It suffices to run the following to install the database completely:
```shell
psql < Northwind_complete.sql
```
---

B. Complete Schema Classified Tables with relations (<ins>Northwind_complete.sql</ins>)

It suffices to run the following to install the database completely:
```shell
psql < Northwind_complete.sql
```

---

C. Imported to PostgreSQL from SQL Server (<ins>Northwind_MSSQL.sql</ins>)

This `SQL` file is imported to PostgreSQL using `pgloader`. It has the schema <b>dbo</b>



