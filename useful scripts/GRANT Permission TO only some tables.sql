-- Simple static version (pgAdmin friendly)
BEGIN;

REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM dataplatform_ro;

GRANT SELECT ON
    public.message_message,
    public.api_application,
    public.message_receivedmessage,
    public.clerk_clerk
TO dataplatform_ro;

-- Stop future implicit SELECT (run for each table owner that might create new tables)
-- Replace table_owner1, table_owner2 with real owning roles (often the role that creates tables).
ALTER DEFAULT PRIVILEGES FOR ROLE /*table_owner1*/ payam IN SCHEMA public REVOKE SELECT ON TABLES FROM dataplatform_ro;
-- Repeat as needed:
-- ALTER DEFAULT PRIVILEGES FOR ROLE table_owner2 IN SCHEMA public REVOKE SELECT ON TABLES FROM dataplatform_ro;

COMMIT;