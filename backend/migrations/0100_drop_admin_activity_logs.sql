-- Migration: 0100_drop_admin_activity_logs
-- Description: Drop admin_activity_logs table after removing activity feature from UI

DROP TABLE IF EXISTS admin_activity_logs;
