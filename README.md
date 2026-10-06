# Asset Management Database Module
This repository contains the DB codebase for the **Asset Management System**. 
The asset management system tracks day-to-day asset holding information across various customer accounts. Because underlying asset positions flux continuously throughout the day, the module is engineered to handle both high-velocity streaming ingestion and heavy end-of-day batch reconciliation.

## 🚀 Dual-Engine Repository (Oracle & PostgreSQL)
⚠️ **Major Highlight:** This repository hosts database code for both **Oracle** and **PostgreSQL**. The legacy Oracle codebase is systematically migrated to PostgreSQL. The repository is structured into two primary directories to separate these dialects:
* `/PLSQL` — Contains the legacy Oracle database tables, types, and packages.
* `/PLpgSQL` — Contains the migrated, PostgreSQL tables , user-defined types, procedures and functions.

## 🏗️ System Architecture & Data Flow
The database module is powered by an upstream Java microservice that ingests payloads from a **Kafka stream**. The microservice maps incoming stream messages directly into user-defined object/composite types before passing them down to this layer.
The architecture services two distinct data-loading patterns:

[ Kafka Stream ] ──> [ Java Microservice ] ──> [DB Object Format ]

┌───────────────────────────┴───────────────────────────┐
【 1. Real-Time Ingest 】                                      【 2. End-of-Day Batch 】

Near real-time asset updates via stream.                Autosys triggered mass-load/reconciliation.
### 1. Real-Time Use Case
* Captures real-time asset fluctuations as they occur throughout the day.
* Executes stream-based updates to keep accounts dynamically updated.

### 2. Batch Use Case
* Triggered at the end of the business day via an **Autosys batch job**.
* Performs bulk loads and reconciliation to consolidate and lock down the final asset positions for all accounts.
