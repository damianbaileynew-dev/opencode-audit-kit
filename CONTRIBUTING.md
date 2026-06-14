# Contributing to OpenCode Audit Kit

Thank you for your interest in contributing! 🎉

## Quick Start

1. **Fork** the repository
2. **Clone** your fork locally
3. **Create** a feature branch: `git checkout -b feature/your-feature`
4. **Make** your changes
5. **Validate**: `bash validate.sh` (must pass with 0 FAIL)
6. **Commit**: `git commit -m 'feat: add your feature'`
7. **Push**: `git push origin feature/your-feature`
8. **Open** a Pull Request

## Validation

All changes must pass the validation suite:

```bash
bash validate.sh
```

Current baseline: **369 PASS, 4 WARN, 0 FAIL**

Any new FAIL is a regression and must be fixed before merge.

## Adding a New Skill

1. Create directory: `global/skills/your-skill-name/`
2. Create `SKILL.md` with frontmatter:
   ```markdown
   ---
   name: your-skill-name
   description: One-line description
   version: 1.0.0
   ---
   # Skill Title
   ## Purpose
   ## Steps
   ## References
   ```
3. Add skill name to `validate.sh` skill list
4. Test with: `npx opencode-ai run "skill:your-skill-name" --model opencode/deepseek-v4-flash-free`

## Adding a New Framework

1. Add framework detection in `score.sh` (FRAMEWORK variable)
2. Add framework-specific scoring block in `score.sh`
3. Create `global/skills/fix-yourframework/SKILL.md`
4. Create a test project with known bugs
5. Run: `bash score.sh /path/to/test-project`
6. Verify: buggy < 20%, fixed ≥ 80%

## Code Style

- **Skills**: Markdown, < 500 lines each
- **Shell scripts**: bash, POSIX-compatible where possible
- **JavaScript**: Node.js 18+, CommonJS
- **Comments**: English
- **Communication**: Turkish is fine in issues/PRs

## Commit Convention

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `refactor:` Code restructuring
- `test:` Test additions
- `chore:` Maintenance

## Questions?

Open an issue with the `question` label.
