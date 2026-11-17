# CybRelay MCP server

**Security remediation for AI coding agents. The engine writes the fix. The AI only advises.**

CybRelay is a vulnerability analysis and remediation platform ([cybrelay.com](https://cybrelay.com)). This repository documents its **remote MCP server**, which lets an AI agent (Claude Code, Claude Desktop, Cursor, Windsurf, VS Code, Cline, or your own agent) analyse code, read the findings of your workspace, get a remediation script, and run a passive security scan of a website — all with your workspace API key, paid in credits.

> **First time?** → [Step-by-step guide](GUIDE.md) · [Guide pas à pas (FR)](GUIDE.fr.md)

> This repository contains documentation and configuration examples only. The CybRelay engine is a hosted service; its source code is not published here.

🇫🇷 [Version française](README.fr.md)

---

## Why CybRelay

Most AI remediation tools ask a large language model to **write** the fix. CybRelay takes the opposite approach:

| | CybRelay |
|---|---|
| Who writes the fix | A **deterministic engine** (rules and syntax analysis). The same input always gives the same script. |
| What the AI does | Adds **advice as comments** in the script (once per finding). It never writes or rewrites the fix. |
| When a fix is not safe | You get a **remediation guide** instead of a patch. A `.patch` file is only provided when it has been validated in memory (applied, syntax-checked, vulnerability neutralised). |
| Your repository | CybRelay **never** connects to, clones, or writes to your repository. No branch, no commit, no pull request. You (or your agent) review and apply. |
| Your existing scanners | CybRelay **reads their reports** (SARIF, Trivy, Snyk, SonarQube, Checkmarx, OWASP ZAP, Nessus, PDF), removes duplicates and prioritises P1 → P4. It does not replace them. |
| Data | Hosted in the EU (Google Cloud, Belgium). Only the useful code excerpt is sent to the AI, with secrets masked. Content purged **48 hours** after each analysis. No customer code used to train models. |
| Price | **Credits**, no per-developer seats. Free plan with 50 credits. |

CybRelay is aligned with OWASP, NIS2, ISO 27001 and GDPR: it helps you work towards these frameworks; it does not replace an official audit, and it is not a penetration testing tool.

## Drop the whole project — built for vibe coders too

You do not need to pick files by hand. In the web app, **drop the entire project folder**:

1. **Cleaning.** CybRelay skips what is not your code: `node_modules`, `vendor`, `venv`, `.git`, `dist`, `build`, `.next`, `target`, caches, IDE folders, minified files (`.min.js`, `.min.css`) and source maps. Only source and infrastructure files are analysed (TypeScript/JavaScript, Python, Go, Java, PHP, C#, Ruby, Rust, Terraform, YAML, Dockerfile, shell…). The app shows how many folders and files were set aside.
2. **Scan.** The engine reads the remaining code, removes duplicates and ranks findings P1 → P4.
3. **Fix with safety nets.** Each fix script runs in steps:
   - **dry-run** of the patch first; if it does not apply cleanly, nothing is changed and you get the written guide instead;
   - patch applied, then **syntax check and your project's tests**;
   - if the tests fail, the patch is **rolled back automatically**.

This is useful if you build with AI assistants ("vibe coding") without being a security specialist: you get readable explanations and fixes that are checked before they touch your project. It does not replace your own review before you ship.

**Where your code goes.** Analysis runs on Google Cloud in the EU (europe-west1, Belgium). AI advice uses Gemini on **Vertex AI**, Google's enterprise AI platform, in a European region by default. Under Google's terms, data sent to Vertex AI is not used to train or fine-tune models ([Google Cloud documentation](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/data-governance)). CybRelay does not keep your code: content is purged automatically **48 hours** after each analysis; only a trace remains (file name, date, counts, SHA-256).

## How CybRelay differs from other tools

Facts below come from each vendor's public documentation (links). They describe approaches, not quality rankings.

| Tool | How the fix is produced | Delivery |
|---|---|---|
| **CybRelay** | Deterministic engine; AI adds comments only; guide when no safe fix | Bash / Python script, validated `.patch` when possible; nothing pushed to your repo |
| GitHub Copilot Autofix | LLM-generated from the code-scanning alert ([GitHub docs](https://docs.github.com/en/code-security/concepts/code-scanning/autofix-for-code-scanning)) | Suggested change / pull request in GitHub |
| Snyk Agent Fix | LLM with Snyk's database of expert fixes as context ([Snyk docs](https://docs.snyk.io/scan-with-snyk/snyk-code/manage-code-vulnerabilities/fix-code-vulnerabilities-automatically)) | In the IDE / pull request |
| Semgrep Autofix | LLM using Semgrep context and guidance ([Semgrep docs](https://semgrep.dev/docs/semgrep-assistant/overview)) | Pull-request comment / draft PR |
| Corgea | AI-native platform generating fixes ([GitHub Marketplace](https://github.com/marketplace/corgea)) | Pull requests or patches |
| Pixee | Deterministic codemods for known patterns, LLM for the rest ([Pixee docs](https://docs.pixee.ai/platform/remediation)) | Pull requests |

**In short:** if you want an AI to write and push code to your repository, the tools above do that. If you want **reproducible fixes written by an engine, reviewed by a human, with the AI kept in an advisory role and nothing pushed for you**, that is what CybRelay is built for.

---

## Connect

**Endpoint (Streamable HTTP, recommended):** `https://api.cybrelay.com/mcp`
**Legacy SSE endpoint:** `https://api.cybrelay.com/sse`
**Authentication:** header `Authorization: Bearer <your CybRelay API key>`

1. Create a free account on [cybrelay.com](https://cybrelay.com) (50 credits offered).
2. In **Settings → Company Profile → Organisational API Key**, click 🔄 to generate your workspace API key. It is shown once; store it in an environment variable or your secret manager, never in a committed file.

**New to MCP? Follow the [step-by-step guide](GUIDE.md).**
3. Add the server to your client (examples below and in [`examples/`](examples/)).

### Claude Code
```bash
claude mcp add --transport http cybrelay https://api.cybrelay.com/mcp \
  --header "Authorization: Bearer $CYBRELAY_API_KEY"
```

### Cursor — `~/.cursor/mcp.json`
```json
{
  "mcpServers": {
    "cybrelay": {
      "url": "https://api.cybrelay.com/mcp",
      "headers": { "Authorization": "Bearer ${env:CYBRELAY_API_KEY}" }
    }
  }
}
```

### VS Code — `.vscode/mcp.json`
```json
{
  "inputs": [
    { "type": "promptString", "id": "cybrelay-key", "description": "CybRelay API key", "password": true }
  ],
  "servers": {
    "cybrelay": {
      "type": "http",
      "url": "https://api.cybrelay.com/mcp",
      "headers": { "Authorization": "Bearer ${input:cybrelay-key}" }
    }
  }
}
```

### Windsurf — `~/.codeium/windsurf/mcp_config.json`
```json
{
  "mcpServers": {
    "cybrelay": {
      "serverUrl": "https://api.cybrelay.com/mcp",
      "headers": { "Authorization": "Bearer ${env:CYBRELAY_API_KEY}" }
    }
  }
}
```

### Claude Desktop (through `mcp-remote`)
```json
{
  "mcpServers": {
    "cybrelay": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "https://api.cybrelay.com/mcp", "--header", "Authorization:${CYBRELAY_AUTH}"],
      "env": { "CYBRELAY_AUTH": "Bearer <your CybRelay API key>" }
    }
  }
}
```

Check that the server is up: `https://api.cybrelay.com/api/mcp/healthz`.

---

## Tools

| Tool | What it really does | Cost |
|---|---|---|
| `scan_url_surface` | Passive configuration scan of a website (HTTP security headers, TLS, HTTPS redirect, cookies, mail DNS, security.txt). Grade A+ to F. **No intrusion testing.** Result readable for 48 h; hidden from the public list unless `hidden: false`. | 1 free scan per day per workspace, then 2 credits |
| `analyze_file` | Analyses content **sent by the agent**: a source file or a scanner report (SARIF, Trivy, Snyk, SonarQube, Checkmarx, ZAP…). No repository is cloned. Identical content already analysed is not charged twice. | min(5, unique findings) + 1 credit per unique finding; 1 credit if nothing is found |
| `list_vulnerabilities` | Lists the findings stored in your workspace, sorted by priority; filters by project, analysis, severity, priority. | Free |
| `get_scan_status` | Status and summary of an analysis (severities, priorities, SHA-256 of the analysed file). | Free |
| `get_remediation_patch` | Returns the remediation script of a finding (Bash or Python), and a validated `.patch` when you send the current file. **Applies nothing.** | Free (included in the analysis) |
| `trigger_pipeline_scan`, `apply_remediation_patch` | Former names of `analyze_file` and `get_remediation_patch`, kept for compatibility. | — |

### Example prompts
- *"Scan https://example.com with CybRelay and explain the top 3 issues."*
- *"Send `src/routes/user.ts` to CybRelay, then give me the remediation script for every P1 finding."*
- *"Import `trivy-report.json` into CybRelay and list the critical vulnerabilities."*

---

## Plans, credits and limits

| | Free (Découverte) | Starter | Pro | Enterprise |
|---|---|---|---|---|
| Price | free | €39 / month | €99 / month | quote |
| Credits | 50 once (valid 1 month), then top-ups | 300 / month | 1,000 / month | 2,000+ / month |
| MCP gateway | ✅ | ✅ | ✅ | ✅ |
| MCP calls per minute | 30 | 60 | 120 | 600 |
| BYOK / BYOM (your own AI key or model) | — | — | ✅ | ✅ |

Top-ups without subscription: 35 credits €9, 130 credits €29, 300 credits €60. Purchased credits are valid 1 year. Current prices: [cybrelay.com/#pricing](https://cybrelay.com/#pricing) (the website prevails).

**Limits:** file 15 MB; CI / API / MCP analyses limited to 60 per hour per workspace; website scans limited per domain and per hour. CybRelay does not run your tests and does not read lock files directly (send a Trivy or Snyk report instead).

---

## Security and data

- Each API key sees **only its own workspace**. Keys are stored as hashes; a lost key is regenerated.
- Hosting: Google Cloud, EU (europe-west1, Belgium). AI: Gemini on Vertex AI in Europe by default.
- Sent to the AI: only the relevant code excerpt and the finding description; secrets, internal IPs, internal host names and e-mail addresses are masked first.
- Purge: content deleted automatically **48 h** after each analysis; only a trace remains (file name, date, counts, credits, SHA-256).
- Report a vulnerability in CybRelay: security@cybrelay.com ([security.txt](https://cybrelay.com/.well-known/security.txt)).

---

## About

CybRelay was founded by **Mounim Alami**, former R&D director in military data connectivity and encryption. The platform is built and operated by a small team working with AI agents, every change reviewed by the founder.

- Website: [cybrelay.com](https://cybrelay.com) · Public scan: [scan.cybrelay.com](https://scan.cybrelay.com)
- API documentation: [api.cybrelay.com/api/v1/docs](https://api.cybrelay.com/api/v1/docs)
- Contact: sales@cybrelay.com · Support: support@cybrelay.com · Security: security@cybrelay.com

The documentation and examples in this repository are under the MIT licence.
