-- ============================================================
-- BELLABEAT DATA ASSEMBLY & INITIAL CLEANING
-- Analyst: Oluwasijibomi Oderinde
-- Date: April 2026
-- Tool: DB Browser for SQLite
-- ============================================================

-- ------------------------------------------------------------
-- 1. Clean Daily Activity Table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS daily_activity_clean;

CREATE TABLE daily_activity_clean AS
SELECT
  Id AS user_id,
  ActivityDate AS activity_date,
  TotalSteps AS total_steps,
  TotalDistance AS total_distance,
  VeryActiveMinutes AS very_active_minutes,
  FairlyActiveMinutes AS fairly_active_minutes,
  LightlyActiveMinutes AS lightly_active_minutes,
  SedentaryMinutes AS sedentary_minutes,
  Calories AS calories
FROM daily_activity_raw
WHERE
  Id IS NOT NULL
  AND TotalSteps >= 0
  AND Calories > 0
  AND NOT (TotalSteps = 0 AND Calories = 0);

-- ------------------------------------------------------------
-- 2. Clean Sleep Table
-- ------------------------------------------------------------
DROP TABLE IF EXISTS sleep_clean;

CREATE TABLE sleep_clean AS
SELECT
  Id AS user_id,
  SleepDay AS sleep_date,
  TotalSleepRecords AS total_sleep_records,
  TotalMinutesAsleep AS total_minutes_asleep,
  TotalTimeInBed AS total_time_in_bed
FROM sleep_raw
WHERE
  Id IS NOT NULL
  AND TotalMinutesAsleep > 0
  AND TotalTimeInBed >= TotalMinutesAsleep;

-- ------------------------------------------------------------
-- 3. User Count Verification
-- ------------------------------------------------------------
SELECT
  'Daily Activity' AS table_name,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) AS total_records
FROM daily_activity_clean

UNION ALL

SELECT
  'Sleep' AS table_name,
  COUNT(DISTINCT user_id) AS unique_users,
  COUNT(*) AS total_records
FROM sleep_clean;