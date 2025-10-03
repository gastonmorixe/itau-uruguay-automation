# Contributing to Itau Uruguay Automation

Thank you for your interest in contributing! This project automates Itau (Uruguay) banking operations.

## 🔒 Security First

**IMPORTANT:** This project deals with banking credentials and sensitive data.

- Never commit real cookies, tokens, or credentials
- Always test with your own test accounts
- Report security vulnerabilities privately to the maintainer

## 🚀 Getting Started

1. **Fork the repository**
2. **Clone your fork:**
   ```bash
   git clone https://github.com/yourusername/itau-uruguay-automation.git
   cd itau-uruguay-automation
   ```

3. **Install dependencies:**
   ```bash
   npm install
   npx playwright install webkit
   ```

4. **Ensure you have required tools:**
   - Fish Shell 4.1+
   - Node.js 18+
   - jq (JSON processor)
   - gdate (GNU coreutils)

## 🛠️ Development

### Code Style

- **TypeScript:** 2 spaces, strict mode enabled
- **Fish Shell:** 4 spaces
- Use the provided `.editorconfig`

### Testing Your Changes

1. **Test cookie gathering:**
   ```bash
   npm run get-cookies
   ```

2. **Test auto-discovery:**
   ```bash
   npm run discover
   ```

3. **Test full flow:**
   ```bash
   npm start
   ```

### Making Changes

1. Create a new branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes

3. Test thoroughly

4. Commit with descriptive messages:
   ```bash
   git commit -m "feat: add support for X"
   ```

5. Push and create a pull request

## 📝 Commit Convention

We follow conventional commits:

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting)
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `chore:` - Maintenance tasks

## 🐛 Reporting Bugs

1. Check existing issues first
2. Include:
   - Clear description
   - Steps to reproduce
   - Expected vs actual behavior
   - Environment (OS, Node version, etc.)
   - **Sanitized** error messages (remove sensitive data!)

## 💡 Feature Requests

1. Open an issue with `[Feature Request]` prefix
2. Describe the use case
3. Explain why it's useful
4. Suggest implementation if possible

## 🔐 Security Issues

**DO NOT** open public issues for security vulnerabilities.

Instead, email the maintainer privately with:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## 📄 License

By contributing, you agree that your contributions will be licensed under the ISC License.

## ❓ Questions?

Open a discussion or issue - we're happy to help!
