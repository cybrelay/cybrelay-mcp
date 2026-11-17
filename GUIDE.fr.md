# Guide pas à pas : utiliser le serveur MCP CybRelay

*English version: [GUIDE.md](GUIDE.md)*

Ce guide vous mène de zéro à votre première correction en une dizaine de minutes. Aucune connaissance en sécurité n'est nécessaire.

**Ce que vous obtenez :** votre assistant IA (Claude Code, Cursor, VS Code, Windsurf, Claude Desktop…) peut demander à CybRelay de scanner un site ou un fichier, de lister les failles, et de vous donner un script de correction écrit par le moteur CybRelay. L'IA explique ; le moteur écrit la correction ; **vous** décidez de ce qui est appliqué.

---

## Étape 1 — Créer votre compte CybRelay (2 min)

1. Allez sur **https://cybrelay.com** et cliquez sur **S'inscrire**.
2. Inscrivez-vous avec votre e-mail, Google, GitHub ou Microsoft.
3. Vous recevez **50 crédits offerts** (sans carte bancaire). La passerelle MCP est ouverte à toutes les offres, y compris la gratuite.

## Étape 2 — Récupérer votre clé d'API (1 min)

1. Dans CybRelay, ouvrez **Paramètres** (menu de gauche).
2. Onglet **Fiche Société** → encadré **Clé d'API Organisationnelle**.
3. Cliquez sur le bouton **🔄**, tapez le mot de confirmation affiché à l'écran, puis validez.
4. Cliquez sur **Copier**. ⚠️ La clé ne s'affiche **qu'une seule fois**.

> Vous utilisez déjà cette clé dans un pipeline CI ? La régénérer **coupe immédiatement l'ancienne** : mettez à jour le secret de votre CI.

## Étape 3 — Ranger la clé en sécurité (1 min)

Ne collez jamais la clé dans un fichier envoyé sur Git. Mettez-la dans une variable d'environnement :

- **macOS / Linux** (ajoutez la ligne dans `~/.zshrc` ou `~/.bashrc`, puis ouvrez un nouveau terminal) :
  ```bash
  export CYBRELAY_API_KEY="collez-votre-clé-ici"
  ```
- **Windows (PowerShell)**, puis ouvrez un nouveau terminal :
  ```powershell
  setx CYBRELAY_API_KEY "collez-votre-clé-ici"
  ```

## Étape 4 — Brancher votre assistant IA (2 min)

Choisissez **votre** outil. Adresse : `https://api.cybrelay.com/mcp` — en-tête : `Authorization: Bearer <votre clé>`.

### Claude Code
```bash
claude mcp add --transport http cybrelay https://api.cybrelay.com/mcp \
  --header "Authorization: Bearer $CYBRELAY_API_KEY"
```

### Cursor
Copiez [`examples/cursor.mcp.json`](examples/cursor.mcp.json) dans `~/.cursor/mcp.json` (ou `.cursor/mcp.json` dans votre projet), puis redémarrez Cursor.

### VS Code (mode agent de Copilot)
Copiez [`examples/vscode.mcp.json`](examples/vscode.mcp.json) dans `.vscode/mcp.json`. VS Code demande la clé la première fois et la garde en lieu sûr.

### Windsurf
Copiez [`examples/windsurf.mcp_config.json`](examples/windsurf.mcp_config.json) dans `~/.codeium/windsurf/mcp_config.json`.

### Claude Desktop
Utilisez [`examples/claude-desktop.json`](examples/claude-desktop.json) (passe par `mcp-remote`, nécessite Node.js). Réglages → Développeur → Modifier la configuration, collez, redémarrez.

## Étape 5 — Vérifier la connexion (1 min)

Demandez à votre assistant :

> *« Quels outils CybRelay as-tu ? »*

Il doit citer `scan_url_surface`, `analyze_file`, `list_vulnerabilities`, `get_scan_status`, `get_remediation_patch` (plus deux anciens noms gardés pour compatibilité).

Sans assistant, depuis un terminal : `CYBRELAY_API_KEY=... ./examples/curl.sh` renvoie la liste des outils.
État du serveur : https://api.cybrelay.com/api/mcp/healthz

---

## Étape 6 — Premier scan : un site web (gratuit)

> *« Scanne https://mon-site.com avec CybRelay et explique-moi simplement les 3 problèmes les plus importants. »*

- Ce qui est contrôlé : en-têtes de sécurité HTTP, TLS, redirection HTTPS, cookies, DNS de messagerie (SPF/DMARC), security.txt. Note de A+ à F.
- **Contrôles passifs uniquement, aucun test d'intrusion.**
- 1 scan gratuit par jour et par espace, ensuite payé en crédits. Le résultat reste masqué de la liste publique de CybRelay, sauf demande contraire.

## Étape 7 — Scanner votre code

### Option A — un fichier, depuis l'assistant
> *« Envoie `src/routes/user.ts` à CybRelay et liste ce qu'il trouve, P1 en premier. »*

L'assistant envoie le contenu du fichier (aucun dépôt n'est cloné). Coût : min(5, failles uniques) + 1 crédit par faille unique ; 1 crédit si rien n'est trouvé. Le même fichier envoyé deux fois n'est pas facturé deux fois.

### Option B — le rapport de votre scanner
> *« Envoie `trivy-report.json` à CybRelay et liste les failles critiques. »*

Fonctionne avec les rapports SARIF, Trivy, Snyk, SonarQube, Checkmarx, OWASP ZAP, Nessus et PDF. CybRelay fusionne les doublons et classe de P1 à P4.

### Option C — le projet entier (application web)
Sur https://cybrelay.com, **déposez le dossier complet du projet**. CybRelay écarte `node_modules`, `vendor`, `venv`, `.git`, `dist`, `build`, les fichiers minifiés, etc., et n'analyse que vos fichiers source et d'infrastructure. Les failles apparaissent ensuite dans l'assistant avec `list_vulnerabilities`.

## Étape 8 — Obtenir la correction

> *« Pour chaque faille P1, récupère le script de correction CybRelay. Envoie le contenu actuel du fichier pour que le moteur valide un correctif. »*

Vous recevez :
- un **script Bash ou Python** écrit par le moteur (l'IA ajoute seulement des conseils en commentaires) ;
- un **`.patch` validé** quand le moteur a pu l'appliquer en mémoire, vérifier la syntaxe et confirmer que la faille a disparu ;
- sinon un **guide écrit** : aucun correctif risqué n'est produit.

**CybRelay n'applique rien dans votre dépôt.** Aucune branche, aucun commit, aucune pull request n'est créé à votre place.

## Étape 9 — Appliquer la correction sans risque

1. **Commitez ou mettez de côté (stash) votre travail d'abord.** Le script Bash s'arrête si votre dépôt Git a des modifications non commitées, ou si vous n'êtes pas dans un dépôt Git.
2. Enregistrez le script (par exemple `cybrelay-fix.sh`), lisez-le, puis lancez-le depuis la racine du projet :
   ```bash
   bash cybrelay-fix.sh
   ```
3. Le script Bash :
   - fait d'abord une **simulation** du correctif ; s'il ne s'applique pas proprement, rien n'est modifié et le guide s'affiche ;
   - applique le correctif, puis lance une **vérification de syntaxe et les tests du projet** ;
   - **annule automatiquement** le correctif si les tests échouent.
4. Relisez la modification (`git diff HEAD~1`) et testez votre application avant la mise en ligne.

---

## Demandes utiles

- *« Liste mes failles CybRelay du projet PRJ-… de gravité CRITICAL. »*
- *« Où en est l'analyse CybRelay <identifiant> ? »*
- *« Explique cette faille CybRelay à un débutant, puis donne-moi le script de correction en Python. »*
- *« Scanne avec CybRelay les 3 fichiers que j'ai modifiés aujourd'hui avant que je commite. »*

## Coûts et limites

| | Découverte | Starter | Pro | Entreprise |
|---|---|---|---|---|
| Passerelle MCP | oui | oui | oui | oui |
| Appels par minute | 30 | 60 | 120 | 600 |

- Analyses : 60 par heure et par espace. La liste des failles, l'état d'une analyse et les scripts de correction sont gratuits (compris dans le prix de l'analyse).
- Prix et crédits : https://cybrelay.com/#pricing

## En cas de problème

| Message | Cause | Que faire |
|---|---|---|
| `401` « En-tête Authorization Bearer manquant ou invalide » | Clé absente, ou `Bearer ` oublié | Vérifiez que l'en-tête est exactement `Authorization: Bearer <clé>` et que la variable existe dans le terminal qui lance votre outil |
| `403` « Clé d'authentification MCP invalide » | Clé fausse, ancienne ou régénérée | Générez une nouvelle clé (étape 2) et mettez à jour la configuration |
| `429` « Limite atteinte : … appels par minute » | Limite par minute de votre offre | Attendez le nombre de secondes indiqué, ou ralentissez votre agent |
| `429` « Trop de tentatives… » | Nombreux échecs de connexion depuis votre adresse IP | Corrigez la clé, puis patientez quelques minutes |
| « Crédits insuffisants » | Pas assez de crédits pour cette analyse | Rechargez ou abonnez-vous sur cybrelay.com ; la liste des failles et les corrections restent gratuites |
| `405` sur `GET /mcp` | Normal : l'adresse n'accepte que `POST` | Utilisez un client MCP, pas un navigateur |
| Les outils n'apparaissent pas | Ancien client sans transport HTTP | Utilisez la configuration `mcp-remote` (exemple Claude Desktop) ou l'adresse SSE `https://api.cybrelay.com/sse` |

## Aide

- Support : support@cybrelay.com
- Signaler une faille de CybRelay : security@cybrelay.com
- Documentation complète : [README.fr.md](README.fr.md)
