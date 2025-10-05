> [!NOTE]
> Vibe-coded with Codex and Claude. *Use it at your own risk.*

# Itau Bank Automation Scripts

Automated scripts to fetch and display your Itau (Uruguay) bank account balances and credit card statements using WebKit automation for cookie management.

## ✨ Features

- 🏦 **Account Balances**: Fetch balances from multiple bank accounts (UYU/USD)
- 💳 **Credit Card Balances**: View future credit card balances month-by-month
- 🍪 **Automatic Cookie Management**: Uses Playwright + WebKit to automate login and extract cookies
- 💱 **Exchange Rate Automation**: Automatically fetches current USD→UYU exchange rates
- 🔍 **Smart Auto-Discovery**: Automatically extracts all your accounts and cards from homepage
- 🚀 **Interactive Launcher**: One-command workflow that remembers your accounts
- 🔄 **Smart Retry Logic**: Offers to login automatically if discovery fails
- 🔒 **Secure**: Cookies stored locally in your home directory
- ⚡ **Fast**: Runs in headless mode for maximum performance
- 🎨 **Beautiful CLI**: Colored output with progress indicators

## Prerequisites

- macOS (tested on macOS 26.1)
- [Fish Shell](https://fishshell.com/) 4.1+
- [Node.js](https://nodejs.org/) v24+
- [jq](https://jqlang.github.io/jq/) (JSON processor)
- [gdate](https://formulae.brew.sh/formula/coreutils) (GNU date, from coreutils)

Install prerequisites:
```bash
brew install fish jq coreutils
```

## Installation

1. Clone or download this repository:
   ```bash
   cd ~/Projects/itau
   ```

2. Install Node.js dependencies:
   ```bash
   npm install
   ```

## Quick Start (Recommended)

### Interactive Launcher

The easiest way to use these scripts is with the interactive launcher:

```bash
npm start
# or
npm run itau
# or
./itau.fish
```

**First time:**
1. Browser opens for login (cookies saved automatically)
2. **Auto-discovery**: Automatically extracts all your accounts and cards from the homepage
3. Or manually enter account IDs if auto-discovery fails
4. Configuration is saved to `~/.itau_config.json`
5. Exchange rate fetched automatically
6. All balances displayed

**Subsequent runs:**
- Shows your saved configuration
- Press Enter to continue or 'n' to reconfigure
- Automatically checks cookie/rate freshness
- Runs all scripts in sequence

**Example first run with auto-discovery:**
```
╔══════════════════════════════════════════╗
║  🏦  Itau Bank Uruguay Automation      ║
╚══════════════════════════════════════════╝

⚙️  First time setup - let's configure your accounts

🔍 Account Discovery
Would you like to automatically discover your accounts and cards?
(This will use your saved cookies to extract all account info)

Auto-discover? [Y/n] [Enter]

🚀 Running auto-discovery...

🌐 Opening Itau homepage with saved cookies...
📊 Extracting bank accounts...
💳 Extracting credit cards...

✅ Discovery complete!

📊 Bank Accounts Found:
   • URGP - Balance: 125,430.50 (DOE JOHN SMITH)
     ID: URGP:abc123def456789...
   • US.D - Balance: 1,250.75 (DOE JOHN SMITH)
     ID: US.D:xyz789ghi012345...

💳 Credit Cards Found:
   • **** 2103
     ID: card456def789abc012...

💾 Configuration saved to: ~/.itau_config.json

✓ Auto-discovery complete!
```

---

## Auto-Discovery (Standalone)

You can also run account discovery independently:

```bash
npm run discover
```

This will:
1. Use your saved cookies to access the Itau homepage
2. Extract all bank accounts from the JavaScript variables
3. Extract all credit cards from the HTML
4. Save to `~/.itau_config.json`

**Requirements**: Cookies must be saved first (`npm run get-cookies`)

---

## Manual Setup (Advanced)

### 1. Get Cookies (First Time)

Run the cookie getter script to open a browser and log into Itau:

```bash
npm run get-cookies
```

This will:
- Open a WebKit browser window
- Navigate to www.itau.com.uy
- Wait for you to log in manually
- Automatically extract cookies after successful login
- Save cookies to `~/.itau_cookies.json`

**Note**: Cookies typically expire after 24 hours. Re-run this command when needed.

### 2. Get Exchange Rate (Optional)

Fetch the current USD→UYU exchange rate:

```bash
npm run get-rate
```

This saves the rate to `~/.itau_usd_rate.json`. If you skip this step, you'll be prompted to enter the rate manually.

## Usage

### Interactive Mode (Recommended)

Simply run:
```bash
./itau.fish
```

This will handle everything automatically: login, rate fetching, and displaying all your configured accounts and cards.

---

### Manual Mode

You can also run scripts individually:

#### Check Bank Account Balances

```bash
./itau_accounts.fish <currency_code>:<account_id> [<currency_code>:<account_id> ...]
```

**Examples:**
```bash
# Single account
./itau_accounts.fish URGP:abc123def456

# Multiple accounts (UYU and USD)
./itau_accounts.fish URGP:abc123def456 US.D:xyz789ghi012
```

**Currency Codes:**
- `URGP` - Uruguayan Pesos (UYU)
- `US.D` - US Dollars (USD)

**Output:**
```
💱 Using exchange rate: 1 USD = 43.5000 UYU
→ UYU account (abc123) balance:   12345.67 UYU | in USD  283.72
→ USD account (xyz789) balance:     500.00 USD | in USD  500.00
TOTAL   → UYU 12345.67 | USD  500.00
GRAND   → USD  783.72 (includes UYU→USD @ 43.5000)
```

### Check Credit Card Balance

```bash
./itau_balance.fish <card_id>
```

**Example:**
```bash
./itau_balance.fish card456def789abc012345
```

**Output:**
```
💱 Using exchange rate: 1 USD = 43.5000 UYU
Fetching future balances for card ceb6e83d...
---------------------------------------------------------
2025-01 →  UYU 1234.56 | USD  123.45 | Total USD:   151.82
2025-02 →  UYU  567.89 | USD   45.67 | Total USD:    58.72
---------------------------------------------------------
TOTAL   → UYU 1802.45 | USD  169.12
GRAND   → USD  210.54 (includes UYU→USD @ 43.5000)
```

## How It Works

### Architecture

```
┌─────────────────────────────────────┐
│  get-cookies.ts                     │
│  (Playwright + WebKit)              │
│  - Opens browser                    │
│  - Waits for login                  │
│  - Extracts cookies                 │
│  - Saves to ~/.itau_cookies.json    │
└─────────────────────────────────────┘
               ↓
┌─────────────────────────────────────┐
│  load_cookies.fish                  │
│  - Reads cookie file                │
│  - Exports ITAU_COOKIE              │
│  - Warns if expired                 │
└─────────────────────────────────────┘
               ↓
┌─────────────────────────────────────┐
│  itau_accounts.fish /               │
│  itau_balance.fish                  │
│  - Uses auto-loaded cookies         │
│  - Fetches data from Itau API       │
│  - Displays formatted results       │
└─────────────────────────────────────┘
```

### Cookie Management

1. **get-cookies.ts**: Uses Playwright to automate the login process
   - Launches WebKit browser (Safari engine)
   - Navigates to www.itau.com.uy
   - Waits for redirect to itaulink.com.uy (indicates successful login)
   - Extracts session cookies
   - Saves to `~/.itau_cookies.json`

2. **load_cookies.fish**: Helper script that loads cookies
   - Reads from `~/.itau_cookies.json`
   - Exports `ITAU_COOKIE` environment variable
   - Warns if cookies are > 24 hours old

3. **Fish scripts**: Automatically source cookie loader
   - Falls back to manual input if cookies unavailable
   - Uses cookies in API requests

### Exchange Rate Automation

1. **get-exchange-rate.ts**: Fetches current USD→UYU rate
   - Uses exchangerate-api.com (free tier)
   - Saves to `~/.itau_usd_rate.json`

2. **load_rate.fish**: Loads exchange rate
   - Reads from `~/.itau_usd_rate.json`
   - Exports `ITAU_RATE` environment variable
   - Warns if rate is > 24 hours old

## File Structure

```
itau/
├── itau.fish                # Fish: Interactive launcher (START HERE!)
├── discover-accounts.ts     # TypeScript: Auto-discover accounts/cards
├── get-cookies.ts           # TypeScript: Cookie automation (Playwright)
├── get-exchange-rate.ts     # TypeScript: Exchange rate fetcher
├── load_cookies.fish        # Fish: Load cookies from file
├── load_rate.fish           # Fish: Load exchange rate from file
├── itau_accounts.fish       # Fish: Fetch account balances
├── itau_balance.fish        # Fish: Fetch credit card balances
├── package.json             # Node.js dependencies
├── .gitignore               # Git ignore (excludes cookies/secrets)
└── README.md                # This file

Stored in home directory:
~/.itau_config.json          # Saved account/card IDs (auto-discovered)
~/.itau_cookies.json         # Saved cookies (DO NOT COMMIT)
~/.itau_usd_rate.json        # Saved exchange rate
```

## Available NPM Scripts

All functionality is available via npm scripts:

| Command | Description |
|---------|-------------|
| `npm start` | Launch interactive mode with auto-discovery (recommended) |
| `npm run itau` | Same as `npm start` |
| `npm run discover` | Auto-discover all accounts and cards |
| `npm run get-cookies` | Open browser to fetch cookies |
| `npm run get-rate` | Fetch current USD→UYU exchange rate |
| `npm run accounts <args>` | Run accounts script (requires account IDs as arguments) |
| `npm run balance <args>` | Run balance script (requires card ID as argument) |

**Examples:**
```bash
# Interactive mode (easiest)
npm start

# Manual cookie refresh
npm run get-cookies

# Manual rate fetch
npm run get-rate

# Direct script calls (requires arguments)
npm run accounts URGP:abc123 US.D:xyz789
npm run balance card123abc
```

## Troubleshooting

### Cookies Expired

If you see authentication errors:
```bash
npm run get-cookies
```

### Exchange Rate Not Found

If you see rate warnings:
```bash
npm run get-rate
```

Or enter manually when prompted.

### "Cookie file not found"

Run the cookie getter:
```bash
npm run get-cookies
```

### Playwright Browser Issues

Reinstall WebKit:
```bash
npx playwright install webkit
```

## Security Notes

⚠️ **IMPORTANT**:
- Never commit `~/.itau_cookies.json` or share it publicly
- Cookies contain session tokens that grant access to your bank account
- `.gitignore` is configured to exclude sensitive files
- Cookies expire after ~24 hours for security

## API Endpoints

The scripts interact with these Itau API endpoints:

- **Login**: `https://www.itau.com.uy/` → redirects to `https://www.itaulink.com.uy/`
- **Account Balance**: `POST https://www.itaulink.com.uy/trx/cuentas/1/{account_id}/mesActual`
- **Credit Card**: `POST https://www.itaulink.com.uy/trx/tarjetas/credito/{card_id}/movimientos_actuales/{period}`

## 📊 Example Output

```bash
npm start

╔════════════════════════════════════╗
║  🏦  Itau Bank Uruguay Automation  ║
╚════════════════════════════════════╝

✓ Found saved configuration:

📊 Bank Accounts:
   • URGP: abc123def456789ghi012345jkl678901mno234567pqr890123stu456
   • US.D: def789ghi012345jkl678901mno234567pqr890123stu456789vwx

💳 Credit Cards:
   • hij456klm789nop012qrs345tuv678wxy901zab234cde567fgh890

Continue with saved config? [Y/n] y
════════════════════════════════════════

🚀 Starting automation sequence...

[1/4] 🍪 Checking authentication...
✓ Cookies found

[2/4] 💱 Fetching exchange rate...

> itau-uruguay-automation@1.0.0 get-rate
> tsx get-exchange-rate.ts

💱 Fetching USD → UYU exchange rate...
✅ Current rate: 1 USD = 43.5000 UYU
💾 Rate saved to: /Users/gaston/.itau_usd_rate.json


[3/4] 📊 Fetching bank account balances...
════════════════════════════════════════

💱 Using exchange rate: 1 USD = 43.5 UYU
→ UYU account (abc123def456789ghi012345jkl678901mno234567pqr890123stu456) balance:  125430.50 UYU | in USD 2883.91
→ USD account (def789ghi012345jkl678901mno234567pqr890123stu456789vwx) balance:    1250.75 USD | in USD 1250.75
TOTAL   → UYU 125430.50 | USD 1250.75
GRAND   → USD 4134.66 (includes UYU→USD @ 43.5000)

[4/4] 💳 Fetching credit card balances...
════════════════════════════════════════

💱 Using exchange rate: 1 USD = 43.5 UYU

Fetching future balances for card hij456klm789nop012qrs345tuv678wxy901zab234cde567fgh890 …
---------------------------------------------------------
Fetching month 2025-10 … 2025-10 →  UYU 15234.89 | USD    0.00 | Total USD:  350.23
Fetching month 2025-11 … 2025-11 →  UYU 12567.34 | USD    0.00 | Total USD:  288.91
Fetching month 2025-12 … 2025-12 →  UYU  9876.12 | USD    0.00 | Total USD:  227.04
Fetching month 2026-01 … 2026-01 →  UYU  8234.56 | USD    0.00 | Total USD:  189.30
Fetching month 2026-02 … 2026-02 →  UYU  6543.21 | USD    0.00 | Total USD:  150.42
Fetching month 2026-03 … 2026-03 →  UYU  5432.10 | USD    0.00 | Total USD:  124.88
Fetching month 2026-04 … 2026-04 →  UYU  4321.09 | USD    0.00 | Total USD:   99.34
Fetching month 2026-05 … 2026-05 →  UYU  3210.87 | USD    0.00 | Total USD:   73.81
Fetching month 2026-06 … 2026-06 →  UYU  2109.76 | USD    0.00 | Total USD:   48.51
Fetching month 2026-07 … 2026-07 →  UYU  1098.65 | USD    0.00 | Total USD:   25.25
Fetching month 2026-08 … 2026-08 →  UYU   987.54 | USD    0.00 | Total USD:   22.70
Fetching month 2026-09 … ---------------------------------------------------------
TOTAL   → UYU 69616.13 | USD    0.00
GRAND   → USD 1600.37 (includes UYU→USD @ 43.5000)

╔════════════════════════════════════════╗
║  ✨  All done! Have a great day! ✨   ║
╚════════════════════════════════════════╝
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## ⚠️ Disclaimer

**Disclaimer**: This tool is not affiliated with Banco Itau. Use responsibly and in accordance with Itau's Terms of Service.

**Security Notice**: This tool stores session cookies locally. Never share your cookie files or commit them to version control.
