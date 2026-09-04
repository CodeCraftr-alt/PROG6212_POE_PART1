# RaceDay – Part 1

RaceDay is a web-based event management system for South African road running, walking and cycling events.

## Part 1 contents

- `docs/RaceDay_ERD.png` – Entity Relationship Diagram
- `docs/RaceDay_Endpoint_Plan.md` – complete API endpoint plan
- `docs/RaceDay.sql` – SQL Server database creation and sample data script
- `.github/workflows/validate.yml` – GitHub Actions repository validation

## Roles

**Organiser:** creates, edits and deletes events, manages categories, views event enrolments and records participant results.

**Participant:** creates an account, browses events, enrols in events, views their own enrolments and tracks their results.

## Database design

The database contains six entities: Users, Categories, Routes, Events, Enrollments and Results. Primary keys identify records and foreign keys connect related records. The design also uses UNIQUE, NOT NULL, DEFAULT and CHECK constraints to reduce invalid data.

## Running the SQL script

1. Open SQL Server Management Studio.
2. Open `docs/RaceDay.sql`.
3. Run the whole script on a test SQL Server instance.
4. Check the six tables and sample records using the SELECT statements at the end.

## API planning

The API uses standard HTTP methods and JSON. Protected endpoints require authentication and authorisation. The endpoint plan is kept in `docs/RaceDay_Endpoint_Plan.md`.

## GitHub Actions

The workflow checks that the required `docs` files exist and that the SQL file contains the main `CREATE TABLE` statements. The final submission should include a real screenshot of a successful green workflow run.

## Video

Add the unlisted YouTube walkthrough link here before submitting:



