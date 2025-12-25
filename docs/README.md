# Dotfiles Documentation

Welcome to the comprehensive documentation for this dotfiles management system. This documentation covers everything from quick start to advanced customization.

## Documentation Index

### Getting Started
- [Quick Start Guide](getting-started.md) - Get up and running in 5 minutes
- [Installation Guide](installation.md) - Detailed installation instructions and prerequisites
- [Migration Guide](migration.md) - How to migrate from your existing dotfiles

### Architecture & Design
- [Architecture Overview](architecture.md) - System design and component relationships
- [Directory Structure](directory-structure.md) - What each directory contains
- [Ownership Model](ownership-model.md) - Understanding what the repo owns vs. what you own

### User Guides
- [Configuration Guide](configuration.md) - How to customize your environment
- [Zsh Configuration](zsh-configuration.md) - Managing zsh setup and plugins
- [Update Management](updates.md) - Keeping your dotfiles up to date
- [Backup & Recovery](backup-recovery.md) - Safety features and rollback procedures

### Developer Documentation
- [Ansible Playbook](ansible-playbook.md) - Understanding the automation
- [Bootstrap Process](bootstrap-process.md) - How the bootstrap script works
- [Adding New Configurations](adding-configurations.md) - Extending the system
- [Testing & Development](testing.md) - How to test changes safely

### Reference
- [Command Reference](command-reference.md) - All available commands and scripts
- [Environment Variables](environment-variables.md) - Configuration options
- [Troubleshooting](troubleshooting.md) - Common issues and solutions
- [FAQ](faq.md) - Frequently asked questions

## Quick Links

### Most Common Tasks
- **First Installation**: See [Quick Start Guide](getting-started.md)
- **Add Custom Aliases**: Edit `zsh/zshrc.d/10-aliases.zsh`
- **Add Machine-Specific Config**: Use `~/.zshrc.local` (never tracked by git)
- **Update Dotfiles**: Run `dotfiles-pull-updates.sh` or let auto-update handle it
- **Rollback Changes**: See [Backup & Recovery](backup-recovery.md)

### Platform-Specific
- [Linux Setup](platform-linux.md)
- [macOS Setup](platform-macos.md)

## Philosophy

This dotfiles system is built on three core principles:

1. **Single Source of Truth**: The repository is the canonical source for all managed files
2. **Clear Ownership**: Explicit boundaries between repo-managed and user-managed files
3. **Safety First**: Backups, dry-run mode, and idempotent operations throughout

## Support

For issues, questions, or contributions:
- Check the [Troubleshooting Guide](troubleshooting.md)
- Review the [FAQ](faq.md)
- Open an issue on the repository

## Contributing

Interested in contributing? See:
- [Development Guide](testing.md)
- [Adding New Configurations](adding-configurations.md)
- Repository contribution guidelines

---

**Note**: This documentation is maintained alongside the code. If you find outdated information, please submit a pull request.
