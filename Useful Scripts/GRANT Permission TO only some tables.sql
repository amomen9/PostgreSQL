-- Simple static version (pgAdmin friendly)
BEGIN;

REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM dataplatform_ro;

GRANT SELECT ON
	public.message_message_details_view,
	public.message_receivedmessage_details_view,
	public.message_email_details_view
TO dataplatform_ro;

-- Stop future implicit SELECT (run for each table owner that might create new tables)
-- Replace table_owner1, table_owner2 with real owning roles (often the role that creates tables).
ALTER DEFAULT PRIVILEGES FOR ROLE /*table_owner1*/ payam IN SCHEMA public REVOKE SELECT ON TABLES FROM dataplatform_ro;
-- Repeat as needed:
-- ALTER DEFAULT PRIVILEGES FOR ROLE table_owner2 IN SCHEMA public REVOKE SELECT ON TABLES FROM dataplatform_ro;

COMMIT;