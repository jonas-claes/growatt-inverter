# Importable Test Package (No-Touch Existing Setup)

Goal: allow an electrician to test Growatt communication without changing the existing production Loxone project.

## What is included
- Importable example project file:
  - docs/tests/tcp/Growatt Inverter Example.Loxone
- Analysis proof of transport mode in that file:
  - docs/tests/tcp/LOXONE_TEMPLATE_891_ANALYSIS.md
- Quick register sheet for building a temporary TCP test device:
  - docs/electrician/GROWATT_TCP_TEST_REGISTERS.csv

## Important finding
The official Loxone Growatt template 891 example file is RS485 (Comm485), not a direct Modbus TCP object. So this file is safe for structure/reference, but it is not proof of external TCP acceptance by the logger.

## Safe workflow for electrician
1. Do not edit the production project first.
2. Open the example file in a separate Loxone Config session/workspace.
3. Create a temporary test device only in this test project.
4. Configure test device for Modbus TCP to the logger IP and test with the register list.
5. Only after successful read/write in the test project, replicate settings into production under change control.

## Why this avoids risk
- Existing production logic remains untouched.
- Test object and test polling are isolated.
- Rollback is trivial: close/discard test project.
