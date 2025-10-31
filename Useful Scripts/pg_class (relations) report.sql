-- =============================================
-- Author:              "a-momen"
-- Contact & Report:    "amomen@gmail.com"
-- Update date:         "2025-03-01"
-- Description:         "pg_class (relations) report"
-- License:             "Please refer to the license file"
-- =============================================



SELECT 
    c.oid,
    c.relname,
    ns.nspname AS "Schema Name",
    ty.typname AS "Type Name",
    ofty.typname AS "Composite Type Name",
    a.rolname AS "Owner Name",
    am.amname AS "Access Method Name",
    c.relfilenode,
    ts.spcname AS "Tablespace Name",
    cindex2parent.relname AS "Index Parent Table",
    STRING_AGG(cparent2index.relname, ', ') AS "Table Indexes",
    ctoast.relname AS "Toast Relname",
    rw.rulename AS "Rewrite Rulename"
FROM pg_class c
LEFT JOIN pg_namespace ns ON c.relnamespace = ns.oid
LEFT JOIN pg_type ty ON c.reltype = ty.oid
LEFT JOIN pg_type ofty ON c.reloftype = ofty.oid
LEFT JOIN pg_authid a ON c.relowner = a.oid
LEFT JOIN pg_am am ON c.relam = am.oid
LEFT JOIN pg_tablespace ts ON c.reltablespace = ts.oid
LEFT JOIN pg_class ctoast ON c.reltoastrelid = ctoast.oid
LEFT JOIN pg_rewrite rw ON c.relrewrite = rw.oid
LEFT JOIN pg_index iparent ON iparent.indexrelid = c.oid
LEFT JOIN pg_class cindex2parent ON iparent.indrelid = cindex2parent.oid
LEFT JOIN pg_index ichild ON ichild.indrelid = c.oid
LEFT JOIN pg_class cparent2index ON ichild.indexrelid = cparent2index.oid
--WHERE c.relname IN ('customers', 'idx_60550_pk_customers')
GROUP BY 
    c.oid, c.relname, ns.nspname, ty.typname, ofty.typname, 
    a.rolname, am.amname, c.relfilenode, ts.spcname, 
    cindex2parent.relname, ctoast.relname, rw.rulename
ORDER BY c.oid ASC;
