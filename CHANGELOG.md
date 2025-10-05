# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-03

### Author
- Gaston Morixe <gaston@gastonmorixe.com>

### License
- MIT License

##

### Added
- 🎉 Initial release
- **Interactive Launcher** (`itau.fish`) - One-command automation with saved configuration
- **Auto-Discovery** (`discover-accounts.ts`) - Automatically extracts all bank accounts and credit cards from Itau homepage
- **Cookie Automation** (`get-cookies.ts`) - Uses Playwright + WebKit to automate login and extract session cookies
- **Exchange Rate Fetcher** (`get-exchange-rate.ts`) - Automatically fetches current USD→UYU exchange rate
- **Account Balance Script** (`itau_accounts.fish`) - Fetches balances from multiple bank accounts (UYU/USD)
- **Credit Card Balance Script** (`itau_balance.fish`) - Displays future credit card balances month-by-month
- **Cookie Loader** (`load_cookies.fish`) - Auto-loads cookies with expiry warnings
- **Rate Loader** (`load_rate.fish`) - Auto-loads exchange rate with age warnings
- Comprehensive documentation in README.md
- Security features: `.gitignore` configured to exclude sensitive files
- NPM scripts for all functionality
- TypeScript configuration with strict mode
- EditorConfig for consistent code style

### Features
- 🔐 Secure cookie management with automatic expiry detection
- 💱 Automatic exchange rate fetching from exchangerate-api.com
- 🔍 Smart auto-discovery that handles AJAX-loaded credit card sections
- 🚀 Smart retry logic: offers to login if auto-discovery fails
- 📊 Beautiful CLI output with colors and progress indicators
- 💾 Persistent configuration in `~/.itau_config.json`
- ⏰ Automatic cookie/rate refresh when older than 24 hours
- 🌐 WebKit browser automation for native Safari compatibility
- 📈 Real-time balance totals with currency conversion

### Security
- Cookie files stored in home directory (not in repository)
- Automatic cookie expiration warnings
- No credentials stored in code
- `.gitignore` protects sensitive files

### Documentation
- Complete README with quick start guide
- Manual setup instructions for advanced users
- Troubleshooting section
- API endpoint documentation
- File structure overview
- Security notes and disclaimers

[1.0.0]: https://github.com/gastonmorixe/itau-uruguay-automation/releases/tag/v1.0.0
