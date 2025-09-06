--   AI Contributed Query

WITH roles AS (
  SELECT rolname
  FROM pg_roles
  WHERE rolcanlogin
),
objects AS (
  SELECT format('%I.%I', n.nspname, c.relname) AS object_name,
         CASE c.relkind
           WHEN 'r' THEN 'TABLE'
           WHEN 'p' THEN 'PARTITIONED TABLE'
           WHEN 'v' THEN 'VIEW'
           WHEN 'm' THEN 'MATERIALIZED VIEW'
           WHEN 'f' THEN 'FOREIGN TABLE'
         END AS object_type,
         pg_get_userbyid(c.relowner) AS owner_name
  FROM pg_class c
  JOIN pg_namespace n ON n.oid = c.relnamespace
  WHERE c.relkind IN ('r','p','v','m','f')
),
permissions AS (
  SELECT unnest(ARRAY[
    'SELECT','INSERT','UPDATE','DELETE','TRUNCATE','REFERENCES','TRIGGER','owner'
  ]) AS permission_type
)
SELECT r.rolname AS user_name,
       o.object_name,
       o.object_type,
       p.permission_type
FROM roles r
CROSS JOIN objects o
CROSS JOIN permissions p
CROSS JOIN LATERAL (
  SELECT CASE
           WHEN p.permission_type = 'owner'
             THEN (r.rolname = o.owner_name)
           ELSE has_table_privilege(r.rolname, o.object_name, p.permission_type)
         END AS allowed
) chk
WHERE chk.allowed
ORDER BY user_name, object_name, permission_type;
