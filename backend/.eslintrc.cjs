/**
 * Backend ESLint configuration.
 *
 * Goal: catch real issues (unsafe any, unused vars, async mistakes) without
 * becoming noisy. Formatting is handled by Prettier.
 */

module.exports = {
  root: true,
  env: {
    node: true,
    es2020: true,
  },
  parser: '@typescript-eslint/parser',
  parserOptions: {
    ecmaVersion: 2020,
    sourceType: 'script',
  },
  plugins: ['@typescript-eslint'],
  extends: [
    'eslint:recommended',
    // NOTE: We intentionally start with the non-typechecked ruleset.
    // The codebase interacts heavily with dynamic data (Supabase, AI payloads),
    // and turning on no-unsafe-* across the whole repo creates too much churn.
    //
    // Type safety is still enforced via the separate `tsc --noEmit` gate.
    'plugin:@typescript-eslint/recommended',
    'plugin:@typescript-eslint/stylistic',
    'prettier',
  ],
  ignorePatterns: ['dist/', 'node_modules/'],
  rules: {
    '@typescript-eslint/no-explicit-any': 'warn',
    '@typescript-eslint/consistent-type-imports': [
      'warn',
      { prefer: 'type-imports', fixStyle: 'inline-type-imports' },
    ],
    '@typescript-eslint/no-unused-vars': [
      'warn',
      { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
    ],
  },
};

