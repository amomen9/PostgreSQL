select 
	c.oid,
	c.relname,
	ns.nspname "Schema Name",
	ty.typname "Type Name",
	ofty.typname "Composite Type Name",
	a.rolname "Owner Name",
	am.amname "Access Method Name",
	c.relfilenode,
	ts.spcname "Tablespace Name",
	c3.relname "Index Parent Table",
	c2.relname "Toast Relname",
	rw.rulename "Rewrite Rulename"
from pg_class c 
left join pg_namespace ns	on c.relnamespace = ns.oid
left join pg_type ty		on c.reltype=ty.oid
left join pg_type ofty		on c.reloftype=ofty.oid
left join pg_authid a		on c.relowner=a.oid
left join pg_am am			on c.relam=am.oid
left join pg_tablespace ts	on c.reltablespace = ts.oid
left join pg_class c2		on c.reltoastrelid=c2.oid
left join pg_rewrite rw		on c.relrewrite=rw.oid
left join pg_index i		on i.indexrelid=c.oid
left join pg_class c3		on i.indrelid=c3.oid
--where c.relname in ('customers','idx_60550_pk_customers')
order by oid asc


