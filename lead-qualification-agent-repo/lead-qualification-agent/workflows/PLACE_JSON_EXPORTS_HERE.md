## How to add your workflow files

1. Open each workflow in n8n
2. Click the **"..."** (three dots) menu, top right → **Download**
3. This saves a `.json` file — n8n exports the full workflow (nodes, connections, settings)
4. Rename and drop them into this folder as:
   - `workflow-1-data-ingestion.json`
   - `workflow-2-lead-agent.json`
5. Delete this file once both are added

**Important before exporting:** open each node with credentials and make sure n8n hasn't embedded your actual API keys/tokens in the export. n8n usually excludes credential values by default, but double-check the JSON for anything sensitive before pushing to a public repo.
