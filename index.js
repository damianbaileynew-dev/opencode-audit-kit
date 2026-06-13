// OpenCode Audit Kit v2.0 — Module Entry Point
// This file makes the package require()-able

module.exports = {
  name: 'opencode-audit-kit',
  version: '2.0.0',
  description: '10-dimension automated code audit kit for OpenCode AI',

  // Supported frameworks
  frameworks: ['js-express', 'typescript-express', 'fastapi', 'nestjs'],

  // 10 audit dimensions
  dimensions: [
    { name: 'Security', icon: '🔒', checks: 12 },
    { name: 'Performance', icon: '⚡', checks: 6 },
    { name: 'Code Quality', icon: '🔍', checks: 6 },
    { name: 'Architecture', icon: '🏗️', checks: 6 },
    { name: 'Test', icon: '🧪', checks: 6 },
    { name: 'Accessibility', icon: '♿', checks: 7 },
    { name: 'UX', icon: '🎨', checks: 7 },
    { name: 'DevOps', icon: '🚀', checks: 6 },
    { name: 'SEO', icon: '🔎', checks: 6 },
    { name: 'Documentation', icon: '📚', checks: 5 },
  ],

  // Total: 67 checks across 10 dimensions
  totalChecks: 67,
};
