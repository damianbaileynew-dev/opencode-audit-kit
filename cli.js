#!/usr/bin/env node
// OpenCode Audit Kit v2.0 — CLI Entry Point
const { execSync } = require('child_process');
const path = require('path');

const SCRIPT_DIR = __dirname;

function showHelp() {
  console.log(`
🔍 OpenCode Audit Kit v2.0 — 10-Dimension Code Audit CLI

Usage:
  opencode-audit <command> [options]

Commands:
  score <dir>            Score a project across 10 dimensions (terminal output)
  validate               Validate skill and agent integrity (299 checks)
  auto-audit <dir> [n]   Run audit with retry (n=max runs, default 3)
  install <dir>          Install audit kit into a project
  install:global         Install audit kit globally
  uninstall              Uninstall audit kit

OpenCode Integration:
  npx opencode-ai run "10 boyut audit yap"
  npx opencode-ai run "skill:score-report"
  → Runs inside OpenCode, shows markdown score report in chat

Supported Frameworks:
  ✅ Express.js (vanilla JS)     ✅ TypeScript/Express
  ✅ FastAPI (Python)            ✅ NestJS (TypeScript)
  🔄 Next.js (planned)

10 Dimensions (67 checks):
  🔒 Security (12)    ⚡ Performance (6)    🔍 Code Quality (6)
  🏗️ Architecture (6) 🧪 Test (6)          ♿ Accessibility (7)
  🎨 UX (7)           🚀 DevOps (6)         🔎 SEO (6)
  📚 Documentation (5)

Examples:
  opencode-audit score ./my-project
  opencode-audit auto-audit ./my-project 3
  opencode-audit validate
  `);
}

const command = process.argv[2];
const arg = process.argv[3];

switch (command) {
  case 'score': {
    if (!arg || arg.startsWith('-')) { console.error('❌ Provide project directory: opencode-audit score ./my-project'); process.exit(1); }
    try { execSync(`bash "${SCRIPT_DIR}/score.sh" "${path.resolve(arg)}"`, { stdio: 'inherit' }); }
    catch (e) { process.exit(e.status || 1); }
    break;
  }

  case 'validate':
    try { execSync(`bash "${SCRIPT_DIR}/validate.sh"`, { stdio: 'inherit', cwd: SCRIPT_DIR }); }
    catch (e) { process.exit(e.status || 1); }
    break;

  case 'auto-audit': {
    if (!arg) { console.error('❌ Provide project directory: opencode-audit auto-audit ./my-project 3'); process.exit(1); }
    const maxRuns = process.argv[4] || '3';
    try { execSync(`bash "${SCRIPT_DIR}/auto-audit.sh" "${path.resolve(arg)}" ${maxRuns}`, { stdio: 'inherit' }); }
    catch (e) { process.exit(e.status || 1); }
    break;
  }

  case 'install': {
    if (!arg) { console.error('❌ Provide project directory'); process.exit(1); }
    try { execSync(`bash "${SCRIPT_DIR}/install-project.sh" "${path.resolve(arg)}"`, { stdio: 'inherit' }); }
    catch (e) { process.exit(e.status || 1); }
    break;
  }

  case 'install:global':
    try { execSync(`bash "${SCRIPT_DIR}/install-global.sh"`, { stdio: 'inherit', cwd: SCRIPT_DIR }); }
    catch (e) { process.exit(e.status || 1); }
    break;

  case 'uninstall':
    try { execSync(`bash "${SCRIPT_DIR}/uninstall.sh"`, { stdio: 'inherit', cwd: SCRIPT_DIR }); }
    catch (e) { process.exit(e.status || 1); }
    break;

  case 'help':
  case '--help':
  case '-h':
    showHelp();
    break;

  default:
    console.error(`❌ Unknown command: ${command || '(none)'}`);
    showHelp();
    process.exit(1);
}
