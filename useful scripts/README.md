# active error log reader.sql

**Short Summary:**

Dynamically see, slice and dice the active log file of the PostgreSQL database cluster (It has to be a primary and cannot be in recovery state). This script introduces a way to read the DBMS error log like how `xp_readerrorlog` in SQL Server does.

### **Script Description and Purpose**

This script is designed to dynamically monitor and query PostgreSQL log files using a  **foreign data wrapper (FDW)** . It creates a foreign table (`pg_log_file_dynamic`) that maps to the PostgreSQL log file, allowing you to query the log data directly from the database. The script also includes a function (`update_log_file_path`) to dynamically update the log file path when the log file rotates (e.g., when `pg_rotate_logfile()` is called or the log file reaches its size limit).

---

### **Key Components and Their Purpose**

1. **Foreign Data Wrapper (FDW) Setup** :

* The script creates a `file_fdw` extension and a foreign server (`my_log_server`) to enable PostgreSQL to read external files (in this case, the PostgreSQL log file).

1. **Foreign Table (`pg_log_file_dynamic`)** :

* A foreign table is created to map the PostgreSQL log file (in CSV format) to a structured table format. Each column in the table corresponds to a field in the log file, such as `log_time`, `user`, `database`, `error_severity`, etc.
* This allows you to query the log file directly using SQL.

1. **Dynamic Log File Path Update** :

* The `update_log_file_path` function dynamically updates the foreign table's `filename` option to point to the current log file. This is useful when the log file rotates (e.g., after calling `pg_rotate_logfile()` or when the log file reaches its size limit).
* The function retrieves the current log file path using `pg_current_logfile()` and updates the foreign table accordingly.

1. **Querying Log Data** :

* The script includes an example query to retrieve log entries from the foreign table. It extracts and formats specific fields, such as the transaction ID (`xid`) and process ID (`pid`), and orders the results by `log_time` in descending order.

---

### **Use Cases**

* **Real-Time Log Monitoring** : Query the PostgreSQL log file in real-time to monitor errors, warnings, or other log events.
* **Troubleshooting** : Quickly identify and analyze errors or issues by querying the log file directly from the database.
* **Automation** : Integrate log analysis into automated workflows or monitoring systems.

---

### **How It Works**

1. The script sets up a foreign table (`pg_log_file_dynamic`) that maps to the PostgreSQL log file.
2. The `update_log_file_path` function ensures the foreign table always points to the current log file, even after log rotation.
3. You can query the foreign table to retrieve and analyze log data directly from the database.

---

### **Example Query**

The provided query extracts and formats specific fields from the log file, such as:

* `log_time`: The timestamp of the log entry.
* `error_severity`: The severity level of the log entry (e.g., ERROR, WARNING).
* `executed_text`: The SQL query that was executed (if available).
* Other fields like `user`, `database`, `pid`, and `application_name` provide additional context for the log entry.

---

### **Benefits**

* **Dynamic Log File Handling** : Automatically updates the log file path when the log file rotates.
* **SQL-Based Log Analysis** : Enables powerful SQL queries for filtering, sorting, and analyzing log data.
* **Integration** : Can be integrated into monitoring tools or scripts for automated log analysis.

This script is particularly useful for database administrators and developers who need to monitor and analyze PostgreSQL logs in real-time or as part of their troubleshooting workflows.

# get objects added by an installed extension.sql

Get the names and types and arguments/column names of the objects that creating an extension has added to the database

# pg_class report.sql

### **Script Description and Purpose**

This script is a **comprehensive metadata query** designed to retrieve detailed information about database objects (tables, indexes, etc.) in a PostgreSQL database. It provides a consolidated view of object relationships, ownership, storage details, and other metadata by joining multiple system catalog tables.

---

### **Key Components and Their Purpose**

1. **Metadata Retrieval** :

* The script queries the `pg_class` system catalog table, which contains information about database objects like tables, indexes, sequences, and more.
* It joins other system catalog tables (`pg_namespace`, `pg_type`, `pg_authid`, `pg_am`, `pg_tablespace`, `pg_rewrite`, `pg_index`) to enrich the metadata with additional details.

1. **Object Relationships** :

* It identifies relationships between objects, such as:
  * Parent tables for indexes (`cindex2parent.relname`).
  * Indexes associated with tables (`STRING_AGG(cparent2index.relname, ', ')`).
  * TOAST tables (`ctoast.relname`) associated with large objects.
  * Rewrite rules (`rw.rulename`) applied to the object.

1. **Ownership and Storage Details** :

* Retrieves the owner of the object (`a.rolname`).
* Provides the access method (`am.amname`) and tablespace (`ts.spcname`) used by the object.

1. **Grouping and Aggregation** :

* Uses `GROUP BY` and `STRING_AGG` to consolidate related information, such as listing all indexes associated with a table in a single row.

1. **Ordering** :

* Orders the results by the object ID (`c.oid`) for a consistent and logical output.

---

### **Use Cases**

* **Database Documentation** : Generate a detailed report of database objects, their relationships, and metadata.
* **Troubleshooting** : Identify object dependencies, ownership, and storage details for debugging or optimization.
* **Schema Analysis** : Understand the structure of the database, including indexes, TOAST tables, and rewrite rules.
* **Audit and Compliance** : Review object ownership and access methods for security or compliance purposes.

---

### **Output Columns**

* `oid`: The object ID of the database object.
* `relname`: The name of the object (e.g., table, index).
* `Schema Name`: The schema in which the object resides.
* `Type Name`: The data type of the object.
* `Composite Type Name`: The composite type name (if applicable).
* `Owner Name`: The owner of the object.
* `Access Method Name`: The access method used by the object (e.g., heap, btree).
* `relfilenode`: The file node associated with the object.
* `Tablespace Name`: The tablespace where the object is stored.
* `Index Parent Table`: The parent table for an index (if applicable).
* `Table Indexes`: A comma-separated list of indexes associated with a table.
* `Toast Relname`: The TOAST table associated with the object (if applicable).
* `Rewrite Rulename`: The rewrite rule associated with the object (if applicable).

---

### **Benefits**

* **Comprehensive Metadata** : Provides a detailed view of database objects and their relationships.
* **Flexibility** : Can be customized to filter specific objects (e.g., using the `WHERE` clause).
* **Efficiency** : Consolidates information from multiple system catalog tables into a single query.

This script is particularly useful for database administrators and developers who need to analyze or document the structure and relationships of objects in a PostgreSQL database.
