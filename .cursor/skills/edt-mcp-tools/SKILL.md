# EDT MCP Tools — catalog and task routing

Single MCP server for this project: **EDT MCP Server** (`http://localhost:8765/mcp`).

A tool counts as available only when it is exposed in the current agent session.

**Hard stop:** for any 1C task in mandatory MCP scope (`AGENTS.md` → Tooling → A.1), if EDT MCP is offline or tools are not usable — **stop work and tell the user**. Do not fall back to file-only BSL/metadata edits or “reduced verification”. Exception: Docs-fix (Markdown / rules, no verifiable 1C metadata claims).

Load this skill before calling any EDT MCP tool.

## Prerequisites

- 1C:EDT running with the target project imported (OneSniffer: `bp3.OneSniffer/`).
- EDT MCP Server plugin active and listening on port **8765**.
- After starting EDT or the MCP plugin — restart Cursor so the MCP session reconnects.

## Task → tool mapping

| Task | EDT MCP tools (preferred order) |
|------|----------------------------------|
| Find code by text / identifier | `search_in_code` → `find_references` |
| Read module / method source | `read_module_source`, `read_method_source` |
| Module overview | `get_module_structure`, `list_modules` |
| Call hierarchy | `get_method_call_hierarchy`, `find_references` |
| Go to definition | `go_to_definition` |
| Metadata object structure | `get_metadata_details`, `get_metadata_objects` |
| List subsystems / content | `list_subsystems`, `get_subsystem_content` |
| Form layout | `get_form_layout_snapshot`, `get_form_screenshot` |
| Platform API / syntax help | `get_platform_documentation`, `get_content_assist` |
| Validate BSL after edit | `revalidate_objects`, `get_project_errors`, `get_problem_summary` |
| Query syntax check | `validate_query` |
| Check descriptions / standards | `get_check_description` |
| Impact before rename / delete | `find_references`, `get_method_call_hierarchy` |
| Debug runtime issue | `debug_launch`, `set_breakpoint`, `wait_for_break`, `evaluate_expression`, `get_variables` |
| Run tests | `run_yaxunit_tests`, `debug_yaxunit_tests` |
| Update infobase from EDT | `update_database` |
| Export / import XML | `export_configuration_to_xml`, `import_configuration_from_xml` |

## Project-source search fallback

Before `Grep` / `Glob` on BSL or EDT metadata under `bp3.OneSniffer/`:

1. `search_in_code` with a tuned query.
2. `find_references` when you know the symbol name.
3. `get_metadata_objects` / `get_metadata_details` for metadata questions.

Only then `Grep` / `Glob`, with a one-line note explaining why EDT search was insufficient.

## Verification (replaces external BSL validators)

After non-trivial BSL edits:

1. `revalidate_objects` on touched objects, or `get_project_errors` for the project.
2. `get_problem_summary` for a compact defect list.

One call per verification cycle by default; re-run only when the previous run reported a substantive defect you then fixed.

For metadata XML / form edits without BSL: `revalidate_objects` + cross-check `metadata-xml-workarounds.mdc`.

## Parameter discipline

- Read the live tool schema in the MCP descriptor before the first call in a session.
- Do not invent parameter names.
- Do not repeat the same call against unchanged state.
- Every call must close a concrete context gap.

## What EDT MCP does not provide

- Vector project memory — use `PROJECT.md` for durable project facts; update it when conventions change.
- External template library — search existing project code via `search_in_code`.
- ITS / 1С:Напарник review — use `get_check_description`, `get_project_errors`, and manual review against project rules.

## Unavailable server

If EDT MCP tools are missing from the session, calls fail with connection errors, or the server is not usable:

1. **Stop** any in-progress 1C work in mandatory MCP scope — do not edit BSL / metadata / forms via file tools as a substitute.
2. Tell the user clearly that EDT MCP is unavailable and that work is paused until it is restored.
3. Remind the user of the usual recovery steps (they fix the environment; the agent waits):
   - EDT running with the project imported; MCP plugin listening on port **8765**;
   - `.cursor/mcp.json` lists `EDT MCP Server` at `http://localhost:8765/mcp`;
   - restart Cursor so the MCP session reconnects.
4. Resume only after the user confirms EDT MCP is back, or a probe (`get_server_status` / listed tools) succeeds.

Docs-fix (no BSL/metadata, no factual 1C claims needing EDT) may continue without MCP.
