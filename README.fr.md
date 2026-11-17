# Serveur MCP CybRelay

**La remédiation de sécurité pour les agents IA de développement. Le moteur écrit la correction. L'IA ne fait que conseiller.**

CybRelay est une plateforme d'analyse et de remédiation de vulnérabilités ([cybrelay.com](https://cybrelay.com)). Ce dépôt documente son **serveur MCP distant** : un agent IA (Claude Code, Claude Desktop, Cursor, Windsurf, VS Code, Cline ou votre propre agent) peut analyser du code, lire les failles de votre espace, obtenir un script de correction et lancer un scan passif d'un site, avec la clé d'API de votre espace, payé en crédits.

> **Première fois ?** → [Guide pas à pas](GUIDE.fr.md) · [Step-by-step guide (EN)](GUIDE.md)

> Ce dépôt ne contient que de la documentation et des exemples de configuration. Le moteur CybRelay est un service hébergé ; son code n'est pas publié ici.

🇬🇧 [English version](README.md)

---

## Pourquoi CybRelay

La plupart des outils de remédiation par IA demandent à un grand modèle de langage d'**écrire** la correction. CybRelay fait l'inverse :

| | CybRelay |
|---|---|
| Qui écrit la correction | Un **moteur déterministe** (règles et analyse syntaxique). La même entrée donne toujours le même script. |
| Rôle de l'IA | Elle ajoute des **conseils en commentaires** dans le script (une fois par faille). Elle n'écrit ni ne réécrit jamais la correction. |
| Quand une correction n'est pas sûre | Vous recevez un **guide de correction** au lieu d'un patch. Un fichier `.patch` n'est fourni que s'il a été validé en mémoire (appliqué, vérifié syntaxiquement, faille neutralisée). |
| Votre dépôt | CybRelay ne se connecte **jamais** à votre dépôt, ne le clone pas et n'y écrit rien. Pas de branche, pas de commit, pas de pull request. Vous (ou votre agent) relisez et appliquez. |
| Vos scanners actuels | CybRelay **lit leurs rapports** (SARIF, Trivy, Snyk, SonarQube, Checkmarx, OWASP ZAP, Nessus, PDF), regroupe les doublons et priorise de P1 à P4. Il ne les remplace pas. |
| Données | Hébergement dans l'Union européenne (Google Cloud, Belgique). Seul l'extrait de code utile est envoyé à l'IA, secrets masqués. Contenu purgé **48 heures** après chaque analyse. Aucun code client utilisé pour entraîner des modèles. |
| Prix | En **crédits**, sans facturation par développeur. Offre gratuite avec 50 crédits. |

CybRelay est aligné sur l'OWASP, NIS2, l'ISO 27001 et le RGPD : il aide à travailler vers ces référentiels, il ne remplace pas un audit officiel et ce n'est pas un outil de test d'intrusion.

## Déposez le projet entier — pensé aussi pour le « vibe coding »

Pas besoin de choisir les fichiers un par un. Dans l'application web, **déposez le dossier complet du projet** :

1. **Nettoyage.** CybRelay écarte ce qui n'est pas votre code : `node_modules`, `vendor`, `venv`, `.git`, `dist`, `build`, `.next`, `target`, caches, dossiers d'éditeur, fichiers minifiés (`.min.js`, `.min.css`) et cartes de source. Seuls les fichiers source et d'infrastructure sont analysés (TypeScript/JavaScript, Python, Go, Java, PHP, C#, Ruby, Rust, Terraform, YAML, Dockerfile, shell…). L'application indique combien de dossiers et de fichiers ont été écartés.
2. **Scan.** Le moteur lit le code restant, fusionne les doublons et classe les failles de P1 à P4.
3. **Correction avec garde-fous.** Chaque script de correction avance par étapes :
   - **simulation** du correctif d'abord ; s'il ne s'applique pas proprement, rien n'est modifié et vous recevez le guide écrit à la place ;
   - application, puis **vérification de la syntaxe et lancement des tests du projet** ;
   - si les tests échouent, le correctif est **annulé automatiquement**.

C'est utile si vous développez avec des assistants IA (« vibe coding ») sans être spécialiste de la sécurité : explications lisibles, et corrections vérifiées avant de toucher votre projet. Cela ne remplace pas votre propre relecture avant la mise en ligne.

**Où va votre code.** L'analyse tourne sur Google Cloud en Europe (europe-west1, Belgique). Les conseils de l'IA passent par Gemini sur **Vertex AI**, la plateforme d'IA entreprise de Google, dans une région européenne par défaut. Selon les conditions de Google, les données envoyées à Vertex AI ne servent pas à entraîner ni à ajuster des modèles ([documentation Google Cloud](https://docs.cloud.google.com/vertex-ai/generative-ai/docs/data-governance)). CybRelay ne conserve pas votre code : le contenu est purgé automatiquement **48 heures** après chaque analyse ; seule une trace reste (nom du fichier, date, compteurs, SHA-256).

## Ce qui distingue CybRelay

Les informations ci-dessous viennent de la documentation publique de chaque éditeur (liens). Elles décrivent des approches, pas un classement de qualité.

| Outil | Comment la correction est produite | Livraison |
|---|---|---|
| **CybRelay** | Moteur déterministe ; l'IA ajoute seulement des commentaires ; guide quand aucune correction sûre n'existe | Script Bash / Python, `.patch` validé quand c'est possible ; rien n'est poussé dans votre dépôt |
| GitHub Copilot Autofix | Générée par un LLM à partir de l'alerte ([documentation GitHub](https://docs.github.com/en/code-security/concepts/code-scanning/autofix-for-code-scanning)) | Suggestion / pull request dans GitHub |
| Snyk Agent Fix | LLM, avec la base de corrections d'experts de Snyk comme contexte ([documentation Snyk](https://docs.snyk.io/scan-with-snyk/snyk-code/manage-code-vulnerabilities/fix-code-vulnerabilities-automatically)) | Dans l'IDE / pull request |
| Semgrep Autofix | LLM, avec le contexte et les recommandations de Semgrep ([documentation Semgrep](https://semgrep.dev/docs/semgrep-assistant/overview)) | Commentaire de pull request / brouillon de PR |
| Corgea | Plateforme « AI-native » qui génère les corrections ([GitHub Marketplace](https://github.com/marketplace/corgea)) | Pull requests ou patches |
| Pixee | Transformations déterministes pour les cas connus, LLM pour le reste ([documentation Pixee](https://docs.pixee.ai/platform/remediation)) | Pull requests |

**En résumé :** si vous voulez qu'une IA écrive du code et le pousse dans votre dépôt, les outils ci-dessus le font. Si vous voulez des **corrections reproductibles écrites par un moteur, relues par un humain, avec une IA qui reste conseillère et rien de poussé à votre place**, c'est pour cela que CybRelay est fait.

---

## Connexion

**Adresse (Streamable HTTP, recommandée) :** `https://api.cybrelay.com/mcp`
**Ancienne adresse SSE :** `https://api.cybrelay.com/sse`
**Authentification :** en-tête `Authorization: Bearer <clé d'API CybRelay>`

1. Créez un compte gratuit sur [cybrelay.com](https://cybrelay.com) (50 crédits offerts).
2. Dans **Paramètres → Fiche Société → Clé d'API Organisationnelle**, cliquez sur 🔄 pour générer la clé d'API de votre espace. Elle ne s'affiche qu'une fois : gardez-la dans une variable d'environnement ou votre gestionnaire de secrets, jamais dans un fichier versionné.

**Débutant avec MCP ? Suivez le [guide pas à pas](GUIDE.fr.md).**
3. Ajoutez le serveur à votre client : exemples dans la [version anglaise](README.md#connect) et dans [`examples/`](examples/).

---

## Outils

| Outil | Ce qu'il fait réellement | Coût |
|---|---|---|
| `scan_url_surface` | Scan passif de configuration d'un site (en-têtes de sécurité HTTP, TLS, redirection HTTPS, cookies, DNS de messagerie, security.txt). Note de A+ à F. **Aucun test d'intrusion.** Résultat lisible 48 h ; absent de la liste publique sauf `hidden: false`. | 1 scan gratuit par jour et par espace, puis 2 crédits |
| `analyze_file` | Analyse le contenu **envoyé par l'agent** : un fichier de code ou un rapport de scanner (SARIF, Trivy, Snyk, SonarQube, Checkmarx, ZAP…). Aucun dépôt cloné. Un contenu déjà analysé n'est pas facturé deux fois. | min(5, failles uniques) + 1 crédit par faille unique ; 1 crédit si aucune faille |
| `list_vulnerabilities` | Liste les failles enregistrées dans votre espace, triées par priorité ; filtres projet, analyse, gravité, priorité. | Gratuit |
| `get_scan_status` | État et synthèse d'une analyse (gravités, priorités, empreinte SHA-256 du fichier analysé). | Gratuit |
| `get_remediation_patch` | Renvoie le script de correction d'une faille (Bash ou Python), et un `.patch` validé si vous envoyez le fichier actuel. **N'applique rien.** | Gratuit (compris dans l'analyse) |
| `trigger_pipeline_scan`, `apply_remediation_patch` | Anciens noms de `analyze_file` et `get_remediation_patch`, gardés pour compatibilité. | — |

---

## Offres, crédits et limites

| | Découverte | Starter | Pro | Entreprise |
|---|---|---|---|---|
| Prix | gratuit | 39 € / mois | 99 € / mois | sur devis |
| Crédits | 50 offerts une fois (valables 1 mois), puis recharges | 300 / mois | 1 000 / mois | 2 000 et plus / mois |
| Passerelle MCP | ✅ | ✅ | ✅ | ✅ |
| Appels MCP par minute | 30 | 60 | 120 | 600 |
| BYOK / BYOM (votre clé ou votre modèle d'IA) | — | — | ✅ | ✅ |

Recharges sans abonnement : 35 crédits 9 €, 130 crédits 29 €, 300 crédits 60 €. Crédits achetés valables 1 an. Prix en vigueur : [cybrelay.com/#pricing](https://cybrelay.com/#pricing) (le site fait foi).

**Limites :** fichier de 15 Mo ; analyses par CI, API et MCP limitées à 60 par heure et par espace ; scans de sites limités par domaine et par heure. CybRelay n'exécute pas vos tests et ne lit pas directement les fichiers de dépendances (envoyez un rapport Trivy ou Snyk).

---

## Sécurité et données

- Chaque clé d'API ne voit **que son propre espace**. Les clés sont conservées sous forme d'empreinte ; une clé perdue se régénère.
- Hébergement : Google Cloud, Union européenne (europe-west1, Belgique). IA : Gemini sur Vertex AI en Europe par défaut.
- Envoyé à l'IA : seulement l'extrait de code utile et la description de la faille ; secrets, adresses IP internes, noms de machines internes et adresses e-mail masqués avant l'envoi.
- Purge : contenu effacé automatiquement **48 h** après chaque analyse ; il ne reste qu'une trace (nom du fichier, date, compteurs, crédits, SHA-256).
- Signaler une faille de CybRelay : security@cybrelay.com ([security.txt](https://cybrelay.com/.well-known/security.txt)).

---

## Qui sommes-nous

CybRelay a été fondé par **Mounim Alami**, ancien directeur R&D en connectique de données militaire et en chiffrement. La plateforme est construite et exploitée par une petite équipe qui travaille avec des agents IA ; chaque changement est relu par le fondateur.

- Site : [cybrelay.com](https://cybrelay.com) · Scan public : [scan.cybrelay.com](https://scan.cybrelay.com)
- Documentation de l'API : [api.cybrelay.com/api/v1/docs](https://api.cybrelay.com/api/v1/docs)
- Contact : sales@cybrelay.com · Support : support@cybrelay.com · Sécurité : security@cybrelay.com

La documentation et les exemples de ce dépôt sont sous licence MIT.
