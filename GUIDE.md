# Step-by-step guide: using the CybRelay MCP server

*Version française : [GUIDE.fr.md](GUIDE.fr.md)*

This guide takes you from zero to your first fix in about 10 minutes. No security background is needed.

**What you will get:** your AI assistant (Claude Code, Cursor, VS Code, Windsurf, Claude Desktop…) can ask CybRelay to scan a website or a file, list the vulnerabilities, and give you a fix script written by the CybRelay engine. The AI explains; the engine writes the fix; **you** decide what to apply.

---

## Step 1 — Create your CybRelay account (2 min)

1. Go to **https://cybrelay.com** and click **Sign up**.
2. Sign up with your e-mail, Google, GitHub or Microsoft.
3. You receive **50 free credits** (no card needed). The MCP gateway is open on every plan, including the free one.

## Step 2 — Get your API key (1 min)

1. In CybRelay, open **Settings** (left menu).
2. Tab **Company Profile** → box **Organisational API Key**.
3. Click the **🔄** button, type the confirmation word shown on screen, then confirm.
4. Click **Copy**. ⚠️ The key is shown **only once**.

> Already using this key in a CI pipeline? Regenerating it **cuts the old key immediately**: update your CI secret with the new one.

## Step 3 — Store the key safely (1 min)

Never paste the key into a file that goes to Git. Put it in an environment variable:

- **macOS / Linux** (add the line to `~/.zshrc` or `~/.bashrc`, then open a new terminal):
  ```bash
  export CYBRELAY_API_KEY="paste-your-key-here"
  ```
- **Windows (PowerShell)**, then open a new terminal:
  ```powershell
  setx CYBRELAY_API_KEY "paste-your-key-here"
  ```

## Step 4 — Connect your AI assistant (2 min)

Pick **your** tool. Address: `https://api.cybrelay.com/mcp` — header: `Authorization: Bearer <your key>`.

### Claude Code
```bash
claude mcp add --transport http cybrelay https://api.cybrelay.com/mcp \
  --header "Authorization: Bearer $CYBRELAY_API_KEY"
```

### Cursor
Copy [`examples/cursor.mcp.json`](examples/cursor.mcp.json) to `~/.cursor/mcp.json` (or `.cursor/mcp.json` in your project), then restart Cursor.

### VS Code (Copilot agent mode)
Copy [`examples/vscode.mcp.json`](examples/vscode.mcp.json) to `.vscode/mcp.json`. VS Code asks for the key the first time and stores it securely.

### Windsurf
Copy [`examples/windsurf.mcp_config.json`](examples/windsurf.mcp_config.json) to `~/.codeium/windsurf/mcp_config.json`.

### Claude Desktop
Use [`examples/claude-desktop.json`](examples/claude-desktop.json) (goes through `mcp-remote`, needs Node.js). Settings → Developer → Edit Config, paste, restart.

## Step 5 — Check the connection (1 min)

Ask your assistant:

> *"Which CybRelay tools do you have?"*

It should list `scan_url_surface`, `analyze_file`, `list_vulnerabilities`, `get_scan_status`, `get_remediation_patch` (plus two older names kept for compatibility).

Without an assistant, from a terminal: `CYBRELAY_API_KEY=... ./examples/curl.sh` returns the tool list.
Server status: https://api.cybrelay.com/api/mcp/healthz

---

## Step 6 — Your first scan: a website (free)

> *"Scan https://my-site.com with CybRelay and explain the 3 most important issues in simple words."*

- What is checked: HTTP security headers, TLS, HTTPS redirect, cookies, mail DNS (SPF/DMARC), security.txt. Grade from A+ to F.
- **Passive checks only — no intrusion test.**
- 1 free scan per day per workspace, then paid in credits. The result stays hidden from CybRelay's public list unless you ask otherwise.

## Step 7 — Scan your code

### Option A — one file, from the assistant
> *"Send `src/routes/user.ts` to CybRelay and list what it finds, P1 first."*

The assistant sends the file content (no repository is cloned). Cost: min(5, unique findings) + 1 credit per unique finding; 1 credit if nothing is found. The same file sent twice is not charged twice.

### Option B — a report from your scanner
> *"Send `trivy-report.json` to CybRelay and list the critical vulnerabilities."*

Works with SARIF, Trivy, Snyk, SonarQube, Checkmarx, OWASP ZAP, Nessus and PDF reports. CybRelay merges duplicates and ranks P1 → P4.

### Option C — the whole project (web app)
In https://cybrelay.com, **drop the entire project folder**. CybRelay sets aside `node_modules`, `vendor`, `venv`, `.git`, `dist`, `build`, minified files, etc., and analyses only your source and infrastructure files. The findings then appear in the assistant through `list_vulnerabilities`.

## Step 8 — Get the fix

> *"For each P1 finding, get the CybRelay remediation script. Send the current file content so the engine can validate a patch."*

You receive:
- a **Bash or Python script** written by the engine (the AI only adds advice as comments);
- a **validated `.patch`** when the engine could apply it in memory, check the syntax and confirm the issue is gone;
- otherwise a **written guide**: no risky patch is produced.

**CybRelay applies nothing to your repository.** No branch, no commit, no pull request is created for you.

## Step 9 — Apply the fix safely

1. **Commit or stash your work first.** The Bash script stops if your Git tree has uncommitted changes, or if you are not in a Git repository.
2. Save the script (for example as `cybrelay-fix.sh`), read it, then run it from the project root:
   ```bash
   bash cybrelay-fix.sh
   ```
3. The Bash script:
   - runs a **dry-run** of the patch; if it does not apply cleanly, nothing is changed and the guide is printed;
   - applies the patch, then runs a **syntax check and your project's tests**;
   - **rolls the patch back automatically** if the tests fail.
4. Review the change (`git diff HEAD~1`) and run your app before shipping.

---

## Useful prompts

- *"List my CybRelay findings for project PRJ-… with severity CRITICAL."*
- *"What is the status of CybRelay analysis <id>?"*
- *"Explain this CybRelay finding to a beginner, then give me the fix script in Python."*
- *"Scan the 3 files I changed today with CybRelay before I commit."*

## Costs and limits

| | Free | Starter | Pro | Enterprise |
|---|---|---|---|---|
| MCP gateway | yes | yes | yes | yes |
| Calls per minute | 30 | 60 | 120 | 600 |

- Analyses: 60 per hour per workspace. Listing findings, status and fix scripts are free (included in the analysis price).
- Prices and credits: https://cybrelay.com/#pricing

## Troubleshooting

| Message | Cause | What to do |
|---|---|---|
| `401` "Authorization Bearer missing or invalid" | No key sent, or `Bearer ` missing | Check the header is exactly `Authorization: Bearer <key>` and that the variable is set in the terminal that starts your tool |
| `403` "Clé d'authentification MCP invalide" | Wrong, old or regenerated key | Generate a new key (step 2) and update your config |
| `429` "Limite atteinte : … appels par minute" | Per-minute limit of your plan | Wait the number of seconds shown, or slow down your agent |
| `429` "Trop de tentatives…" | Many failed logins from your IP | Fix the key, then wait a few minutes |
| "Crédits insuffisants" | Not enough credits for this analysis | Top up or subscribe on cybrelay.com; listing and fixes stay free |
| `405` on `GET /mcp` | Normal: the endpoint only accepts `POST` | Use an MCP client, not a browser |
| Tools do not appear | Old client without HTTP transport | Use the `mcp-remote` config (Claude Desktop example) or the SSE address `https://api.cybrelay.com/sse` |

## Help

- Support: support@cybrelay.com
- Report a vulnerability in CybRelay: security@cybrelay.com
- Full documentation: [README.md](README.md)
