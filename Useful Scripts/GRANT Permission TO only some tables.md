# 🎯 Targeted SELECT Privilege Configuration for Reporting Role

---

## 1. Purpose

Limit the reporting role `dataplatform_ro` to `SELECT` only on an approved subset of views/tables while revoking any broad access and preventing future implicit grants via default privileges.

---

## 2. Scenario Overview

| Aspect | Description |
|--------|-------------|
| Reporting Role | `dataplatform_ro` |
| Schema Scope | `public` |
| Granted Objects | `message_message_details_view`, `message_receivedmessage_details_view`, `message_email_details_view` |
| Protection Mechanism | `ALTER DEFAULT PRIVILEGES` to block automatic grants on future tables |
| Transaction Safety | Wrapped in `BEGIN ... COMMIT` |

---

## 3. Why This Matters ✅

- Enforces least privilege.
- Prevents accidental exposure of new tables.
- Centralizes explicit grants for auditability.
- Supports compliance and controlled data dissemination.

---

## 4. Steps

### 4.1 Revoke Existing Broad Access
Remove any prior `SELECT` granted implicitly or globally.

### 4.2 Grant Explicit Access
Whitelist only the approved views.

### 4.3 Block Future Auto-Grants
Alter default privileges for each object-creating owner role (repeat per owner).

### 4.4 Commit Changes
Persist modifications atomically.

---

## 5. Refactored Script 🛠️

```sql
-- GRANT Permission TO only some tables.sql
-- Objective: Enforce a curated read scope for role dataplatform_ro in schema public.

BEGIN;  -- 1️⃣ Start transactional scope to ensure atomic privilege changes

/* 2️⃣ Revoke any existing broad SELECT access on ALL current tables in schema public
      This clears prior blanket grants so we can rebuild a minimal whitelist.
*/
REVOKE SELECT ON ALL TABLES IN SCHEMA public FROM dataplatform_ro;

/* 3️⃣ Grant SELECT only on approved reporting views.
      Add/remove entries in this list as the reporting catalog evolves.
*/
GRANT SELECT ON
    public.message_message_details_view,
    public.message_receivedmessage_details_view,
    public.message_email_details_view
TO dataplatform_ro;

/* 4️⃣ Prevent future implicit SELECT grants on newly created tables:
      Run one ALTER DEFAULT PRIVILEGES per table-owning role that creates objects in public.
      Replace 'payam' with actual owning roles as needed (e.g., app writers, ETL roles).
*/
ALTER DEFAULT PRIVILEGES FOR ROLE payam IN SCHEMA public
    REVOKE SELECT ON TABLES FROM dataplatform_ro;

/* 🔁 Example pattern for additional owners (uncomment & adjust):
ALTER DEFAULT PRIVILEGES FOR ROLE another_owner IN SCHEMA public
    REVOKE SELECT ON TABLES FROM dataplatform_ro;
*/

COMMIT;  -- 5️⃣ Finalize changes
```

---

## 6. Extension Ideas 💡

- Add `COMMENT ON ROLE dataplatform_ro IS 'Reporting limited read role';`
- Create a helper view listing current whitelisted objects.
- Schedule a periodic audit to detect unauthorized grants.

---

## 7. Verification Checklist 📝

| Check | Command | Expected |
|-------|---------|----------|
| Current accessible objects | `\dp public.*` | Only 3 listed with SELECT |
| Future table test | Create table as `payam` | No SELECT for `dataplatform_ro` |
| Role grants | `\dg dataplatform_ro` | No unexpected memberships |

---

## 8. Notes ⚠️

- Views may depend on underlying tables; ensure dependency access is not required directly.
- If base tables reside outside `public`, adapt schema references accordingly.
- Revoking default privileges does not retroactively affect already granted tables.

---

## 9. Next Steps 🚀

1. Add monitoring for privilege drift.
2. Version-control this script.
3. Integrate into deployment pipelines.

---

**End of Document** ✅