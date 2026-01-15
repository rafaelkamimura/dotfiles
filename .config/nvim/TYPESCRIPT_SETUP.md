# TypeScript/JavaScript Development Environment for Neovim

This configuration provides a comprehensive TypeScript and JavaScript development environment using LazyVim with modern tooling and best practices.

## Features

### Language Server Support
- **vtsls**: Modern TypeScript Language Server (replaces legacy tsserver)
- **ESLint LSP**: Advanced linting with flat config support
- **JSON LSP**: Enhanced JSON support with schema validation
- **HTML/CSS LSP**: Complete markup and styling support
- **Tailwind CSS LSP**: Utility-first CSS framework support

### Framework Support
- **React/Next.js**: Complete JSX/TSX support with debugging
- **Vue.js**: SFC support with proper TypeScript integration
- **Svelte**: Modern component framework support
- **Astro**: Multi-framework static site generator
- **Angular**: Enterprise-grade framework support

### Testing Framework Integration
- **Jest**: Popular testing framework with debugging
- **Vitest**: Fast unit testing for Vite projects
- **Playwright**: End-to-end testing support
- **Neotest**: Unified testing interface in Neovim

### Debugging Capabilities
- **Node.js**: Server-side JavaScript/TypeScript debugging
- **Browser**: Client-side debugging for React, Vue, etc.
- **Jest/Vitest**: Test debugging with breakpoints
- **Chrome DevTools**: Integration for web applications

### Developer Experience
- **Auto-imports**: Intelligent import management
- **Code actions**: Automated refactoring and fixes
- **Inlay hints**: Type information display
- **Package management**: npm/yarn/pnpm integration
- **Import cost**: Bundle size analysis
- **Coverage**: Test coverage visualization

## Quick Start

1. **Ensure Prerequisites**:
   ```bash
   # Node.js (recommended version 18+)
   node --version
   
   # Package manager (npm/yarn/pnpm)
   npm --version
   ```

2. **Open Neovim**: The configuration will automatically install required tools
   ```bash
   nvim
   ```

3. **Wait for Setup**: LazyVim will install all plugins and Mason will install language servers

4. **Verify Installation**: Open a TypeScript file and check:
   ```vim
   :checkhealth vim.lsp
   :Mason
   ```

## Key Mappings

### Language Server Actions
| Key | Action | Description |
|-----|--------|-------------|
| `gd` | Go to Definition | Jump to symbol definition |
| `gD` | Go to Declaration | Jump to symbol declaration |
| `gi` | Go to Implementation | Jump to implementation |
| `gr` | References | Show all references |
| `gt` | Type Definition | Jump to type definition |
| `K` | Hover | Show documentation |
| `<C-k>` | Signature Help | Show function signature |

### Code Actions
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ca` | Code Action | Show available code actions |
| `<leader>cr` | Rename | Rename symbol |
| `<leader>co` | Organize Imports | Organize import statements |
| `<leader>cM` | Add Missing Imports | Add missing imports |
| `<leader>cu` | Remove Unused | Remove unused imports |
| `<leader>cD` | Fix All | Fix all issues |
| `<leader>cV` | TS Version | Select TypeScript version |

### Testing
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tr` | Run Test | Run nearest test |
| `<leader>tR` | Run File Tests | Run current file tests |
| `<leader>ta` | Run All Tests | Run entire test suite |
| `<leader>td` | Debug Test | Debug nearest test |
| `<leader>ts` | Test Summary | Toggle test summary |
| `<leader>tw` | Watch Tests | Toggle test watch mode |

### Debugging
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>db` | Toggle Breakpoint | Set/remove breakpoint |
| `<leader>dB` | Conditional Breakpoint | Set conditional breakpoint |
| `<leader>dc` | Continue | Start/continue debugging |
| `<leader>di` | Step Into | Step into function |
| `<leader>do` | Step Over | Step over statement |
| `<leader>dO` | Step Out | Step out of function |
| `<leader>du` | Toggle UI | Toggle debug UI |

### Package Management
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ns` | Show Versions | Show package versions |
| `<leader>nu` | Update Package | Update package on line |
| `<leader>ni` | Install Package | Install new package |
| `<leader>np` | Change Version | Change package version |

## Supported File Types

### Primary Languages
- `.ts` - TypeScript files
- `.tsx` - TypeScript React files
- `.js` - JavaScript files  
- `.jsx` - JavaScript React files
- `.vue` - Vue.js Single File Components
- `.svelte` - Svelte components
- `.astro` - Astro components

### Configuration Files
- `package.json` - Package configuration
- `tsconfig.json` - TypeScript configuration
- `.eslintrc.*` - ESLint configuration
- `prettier.config.*` - Prettier configuration
- `jest.config.*` - Jest configuration
- `vitest.config.*` - Vitest configuration

## Configuration Customization

### ESLint Setup
Create `.eslintrc.js` for legacy config:
```javascript
module.exports = {
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
  ],
  parser: '@typescript-eslint/parser',
  plugins: ['@typescript-eslint'],
  rules: {
    // Your custom rules
  },
};
```

Or `eslint.config.js` for flat config:
```javascript
import js from '@eslint/js';
import tseslint from 'typescript-eslint';

export default [
  js.configs.recommended,
  ...tseslint.configs.recommended,
  {
    rules: {
      // Your custom rules
    },
  },
];
```

### Prettier Setup
Create `.prettierrc.js`:
```javascript
module.exports = {
  semi: true,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'es5',
  printWidth: 100,
};
```

### TypeScript Configuration
Example `tsconfig.json`:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"],
      "~/*": ["./*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## Framework-Specific Setup

### React/Next.js
```bash
# Install dependencies
npm install react react-dom
npm install -D @types/react @types/react-dom

# For Next.js
npm install next
```

### Vue.js
```bash
# Install dependencies  
npm install vue
npm install -D @vue/tsconfig

# For Nuxt.js
npm install nuxt
```

### Testing Setup

#### Jest
```bash
npm install -D jest @types/jest ts-jest
```

#### Vitest
```bash
npm install -D vitest @vitest/ui
```

## Troubleshooting

### Common Issues

1. **TypeScript not working**:
   ```vim
   :LspInfo
   :Mason
   ```
   Ensure vtsls is installed and running.

2. **ESLint not linting**:
   Check ESLint configuration and ensure eslint-lsp is installed.

3. **Prettier not formatting**:
   Verify Prettier configuration exists and conform.nvim is set up.

4. **Tests not running**:
   Ensure test framework is installed and Neotest adapters are configured.

5. **Debugging not working**:
   Check that js-debug-adapter is installed via Mason.

### Performance Optimization

For large projects, consider:
```lua
-- In your configuration
vim.g.lazyvim_typescript_performance = {
  max_ts_server_memory = 8192, -- MB
  disable_automatic_type_acquisition = true,
  exclude_directories = { "node_modules", "dist", "build" },
}
```

## Commands

### TypeScript Commands
- `:TSOrganizeImports` - Organize imports
- `:TSAddMissingImports` - Add missing imports  
- `:TSRemoveUnusedImports` - Remove unused imports
- `:TSFixAll` - Fix all TypeScript issues
- `:TSSelectVersion` - Select TypeScript version
- `:TSRenameFile` - Rename current file

### Package Commands
- `:PackageInstall` - Install packages
- `:PackageUpdate` - Update packages
- `:PackageAudit` - Audit packages
- `:NpmRun [script]` - Run npm script
- `:DetectProject` - Detect project type

### Development Commands
- `:FormatAndLint` - Format and lint current buffer
- `:ToggleAutoOrganizeImports` - Toggle auto-organize imports
- `:ToggleAutoFormat` - Toggle auto-format on save

## Performance Tips

1. **Use TypeScript project references** for monorepos
2. **Configure path mapping** in tsconfig.json for better imports
3. **Use .nvmrc** for consistent Node.js versions
4. **Set up workspace-specific settings** for large projects
5. **Use incremental compilation** with TypeScript

## Resources

- [TypeScript Handbook](https://www.typescriptlang.org/docs/)
- [ESLint Configuration](https://eslint.org/docs/user-guide/configuring/)
- [Prettier Configuration](https://prettier.io/docs/en/configuration.html)
- [Jest Documentation](https://jestjs.io/docs/getting-started)
- [Vitest Guide](https://vitest.dev/guide/)
- [LazyVim Documentation](https://lazyvim.github.io/)

## Contributing

This configuration is designed to be modular and extensible. Feel free to customize based on your specific needs and workflow preferences.