# Rust Development Environment Setup

This document describes the comprehensive Rust development environment configured for your Neovim/LazyVim setup.

## 🦀 Features Installed

### Core Tools
- **Rust Toolchain**: Latest stable Rust with rustc, cargo, rustfmt, clippy
- **rust-analyzer**: Advanced language server with performance optimizations
- **cargo-nextest**: Fast test runner with better output
- **taplo**: TOML formatter for Cargo.toml files

### Development Tools
- **cargo-edit**: Add/remove dependencies with `cargo add` and `cargo rm`
- **cargo-watch**: Automatically run commands on file changes
- **cargo-expand**: Show macro expansions
- **codelldb**: Advanced debugger for Rust (via LLVM)

## 📁 Configuration Files Created

### Plugin Configurations
- `lua/plugins/rust.lua` - Main rustaceanvim configuration with advanced rust-analyzer settings
- `lua/plugins/dap-rust.lua` - Debugging configuration with codelldb and nvim-dap
- `lua/plugins/neotest-rust.lua` - Testing framework with neotest and coverage support
- `lua/plugins/rust-formatting.lua` - Formatting and linting with rustfmt and clippy
- `lua/plugins/rust-performance.lua` - Performance optimizations and memory management
- `lua/plugins/cargo-integration.lua` - Comprehensive cargo commands and workspace management

### LazyVim Integration
- Added `lazyvim.plugins.extras.lang.rust` to `lazyvim.json`

## 🚀 Key Features

### 1. Advanced Language Support
- **IntelliSense**: Fast and accurate code completion
- **Inlay Hints**: Type hints, parameter names, and more
- **Semantic Highlighting**: Enhanced syntax highlighting
- **Error Diagnostics**: Real-time error checking with clippy integration
- **Hover Documentation**: Instant access to documentation
- **Go to Definition/References**: Navigate code effortlessly

### 2. Debugging
- **Integrated Debugger**: Set breakpoints, step through code, inspect variables
- **Test Debugging**: Debug individual tests with neotest integration
- **Multiple Debug Configurations**: 
  - Launch Rust programs
  - Attach to running processes
  - Debug current tests
  - Launch with custom arguments

### 3. Testing
- **neotest Integration**: Run tests with visual feedback
- **cargo-nextest**: Faster test execution
- **Test Navigation**: Jump between failed tests
- **Coverage Reports**: Generate and view test coverage
- **Benchmark Support**: Run cargo bench commands

### 4. Code Quality
- **rustfmt**: Automatic code formatting with customizable settings
- **clippy**: Comprehensive linting with all lint groups enabled
- **Dependency Management**: Add/remove crates interactively
- **Security Auditing**: Built-in cargo audit integration

### 5. Workspace Management
- **Multi-crate Workspaces**: Full support for Cargo workspaces
- **Project Templates**: Quick setup for different project types
- **Workspace Switching**: Navigate between workspace members
- **Dependency Trees**: Visualize project dependencies

## ⌨️ Key Mappings

### Rust-specific Actions (Leader + r)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>rr` | Runnables | Show runnable targets |
| `<leader>rt` | Testables | Show test targets |
| `<leader>rm` | Expand Macro | Show macro expansion |
| `<leader>rc` | Open Cargo.toml | Navigate to Cargo.toml |
| `<leader>re` | Explain Error | Show error explanations |
| `<leader>rd` | Render Diagnostic | Show diagnostic details |
| `<leader>rf` | Format | Format current buffer |
| `<leader>rC` | Clippy | Run clippy on current buffer |

### Cargo Commands (Leader + c)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>cb` | Build | Cargo build |
| `<leader>cB` | Build Release | Cargo build --release |
| `<leader>ct` | Test | Cargo test |
| `<leader>cT` | Test Release | Cargo test --release |
| `<leader>cc` | Check | Cargo check |
| `<leader>cl` | Clippy | Run clippy |
| `<leader>cf` | Format | Run rustfmt |
| `<leader>cd` | Documentation | Generate and open docs |
| `<leader>cs` | Switch Member | Switch workspace member |
| `<leader>ca` | Add Dependency | Add crate dependency |
| `<leader>cr` | Remove Dependency | Remove crate dependency |

### Testing (Leader + t)
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tt` | Test Nearest | Run nearest test |
| `<leader>tf` | Test File | Run all tests in file |
| `<leader>ta` | Test All | Run all tests |
| `<leader>td` | Debug Test | Debug nearest test |
| `<leader>ts` | Test Summary | Toggle test summary |
| `<leader>to` | Test Output | Show test output |

### Debugging (Leader + d)
| Key | Action | Description |
|-----|--------|-------------|
| `<F5>` | Continue | Start/continue debugging |
| `<F10>` | Step Over | Step over current line |
| `<F11>` | Step Into | Step into function |
| `<F12>` | Step Out | Step out of function |
| `<leader>db` | Breakpoint | Toggle breakpoint |
| `<leader>dB` | Conditional Breakpoint | Set conditional breakpoint |
| `<leader>dr` | REPL | Open debug REPL |
| `<leader>du` | Debug UI | Toggle debug UI |

## 🛠️ Advanced Configurations

### rust-analyzer Settings
The configuration includes performance optimizations:
- **Cache Priming**: Multi-threaded cache building
- **All Features**: Load all Cargo features for better analysis
- **Build Scripts**: Enable build script analysis
- **Clippy Integration**: Use clippy for check-on-save
- **Inlay Hints**: Comprehensive type and parameter hints
- **Semantic Highlighting**: Enhanced syntax coloring

### Performance Optimizations
- **Memory Management**: Automatic memory optimization for large projects
- **File Watching**: Optimized file patterns for Rust projects
- **Completion Tuning**: Faster completion with appropriate timeouts
- **Large File Handling**: Disable expensive features for large files

### Project Templates
Available project templates:
- CLI Application (with clap)
- Web Server (with Axum)
- Library
- WebAssembly
- Async Application
- Game (Bevy)
- Desktop App (Tauri)

## 🏗️ Usage Examples

### Creating a New Project
```bash
# In Neovim command mode
:CargoNewProject
# Or use template
:CargoTemplate
```

### Adding Dependencies
```bash
# Interactive dependency addition
:CargoAddDep
# Or use keybinding
<leader>ca
```

### Running Tests with Coverage
```bash
# Generate coverage report
:CargoCoverage
# Or use keymap
<leader>tc
```

### Debugging a Test
1. Navigate to a test function
2. Press `<leader>td` to debug the nearest test
3. Set breakpoints with `<leader>db`
4. Use `<F5>` to continue execution

### Workspace Management
```bash
# Switch between workspace members
:CargoSwitchMember
# Or use keymap
<leader>cs
```

## 🔧 Configuration Commands

### Setup Configuration Files
- `:RustSetupFmt` - Create rustfmt.toml with recommended settings
- `:RustSetupClippy` - Create clippy.toml with recommended settings
- `:RustSetupAll` - Create both configuration files

### Performance Monitoring
- `:RustMemoryUsage` - Show Neovim memory usage
- `:RustProjectStats` - Display project statistics
- `:RustOptimizeCargo` - Show Cargo.toml optimization suggestions

### Project Maintenance
- `:RustCleanArtifacts` - Clean build artifacts
- `:CargoUpdate` - Update dependencies
- `:CargoAudit` - Security audit dependencies

## 📊 Monitoring and Optimization

### Memory Usage
The setup includes automatic memory monitoring for large Rust projects, with warnings when memory usage exceeds 1GB.

### Build Performance
Cargo.toml optimization suggestions are available to improve build times:
- Development profile optimizations
- Release profile settings
- Workspace configuration
- Build cache settings

### File Performance
Large Rust files (>100KB) automatically disable expensive features like treesitter highlighting to maintain responsiveness.

## 🎯 Next Steps

1. **Restart Neovim** to load all new configurations
2. **Create a test Rust project** to verify setup:
   ```bash
   cargo new hello-rust
   cd hello-rust
   nvim src/main.rs
   ```
3. **Test key features**:
   - Type some Rust code and observe IntelliSense
   - Run tests with `<leader>tt`
   - Set a breakpoint and debug with `<F5>`
   - Format code with `<leader>rf`

## 🐛 Troubleshooting

### Common Issues
1. **rust-analyzer not starting**: Ensure PATH includes `~/.cargo/bin`
2. **Debugging not working**: Install codelldb with `:Mason`
3. **Tests not found**: Ensure you're in a Cargo project directory
4. **Slow performance**: Check memory usage with `:RustMemoryUsage`

### Environment Check
```bash
# Verify Rust installation
cargo --version
rustc --version
rust-analyzer --version

# Check cargo tools
cargo nextest --version
cargo clippy --version
cargo fmt --version
```

## 🔄 Updates and Maintenance

### Keeping Tools Updated
```bash
# Update Rust toolchain
rustup update

# Update cargo tools
cargo install-update -a

# Update rust-analyzer
rustup component add rust-analyzer --force
```

### Configuration Updates
The plugin configurations will automatically update with LazyVim. To manually update:
```bash
# In Neovim
:Lazy update
```

---

*This setup provides a professional-grade Rust development environment with all the tools and features needed for modern Rust development. Happy coding! 🦀*