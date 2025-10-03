#!/usr/bin/env tsx
import { webkit } from 'playwright';
import { readFileSync, writeFileSync } from 'fs';
import { homedir } from 'os';
import { join } from 'path';

const COOKIE_FILE = join(homedir(), '.itau_cookies.json');
const CONFIG_FILE = join(homedir(), '.itau_config.json');
const HOME_URL = 'https://www.itaulink.com.uy/trx/';

interface Account {
  moneda: string;
  hash: string;
  saldo: number;
  nombreTitular?: string;
  idCuenta?: string;
}

interface CreditCard {
  hash: string;
  lastFourDigits: string;
}

async function discoverAccounts() {
  console.log('🔍 Auto-discovering Itau accounts and credit cards...\n');

  // Check for cookies
  if (!readFileSync(COOKIE_FILE, 'utf-8')) {
    console.error('❌ No cookies found. Please run: npm run get-cookies');
    process.exit(1);
  }

  const cookieData = JSON.parse(readFileSync(COOKIE_FILE, 'utf-8'));

  console.log('🌐 Opening Itau homepage with saved cookies...');

  const browser = await webkit.launch({
    headless: true,
  });

  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15',
  });

  // Load cookies
  await context.addCookies(cookieData.cookies);

  const page = await context.newPage();

  try {
    await page.goto(HOME_URL, { waitUntil: 'networkidle', timeout: 30000 });

    // Extract bank accounts from JavaScript variable
    console.log('📊 Extracting bank accounts...');

    const accounts = await page.evaluate(() => {
      try {
        // @ts-ignore - mensajeUsuario is a global variable in the page
        const data = mensajeUsuario?.cuentas;
        if (!data) return [];

        const allAccounts: Account[] = [];

        // Iterate through all account types
        for (const accountType in data) {
          if (Array.isArray(data[accountType])) {
            allAccounts.push(...data[accountType]);
          }
        }

        return allAccounts;
      } catch (error) {
        console.error('Error extracting accounts:', error);
        return [];
      }
    });

    // Extract credit cards from select options
    console.log('💳 Extracting credit cards...');

    // Credit cards are loaded via AJAX in section#tarjetasCredito
    // We need to click/expand the section or wait for it to load
    try {
      // Wait for the credit card section to be present
      await page.waitForSelector('#tarjetasCredito', { timeout: 5000 });

      // Check if section needs to be expanded (has 'cerrado' class)
      const needsExpansion = await page.evaluate(() => {
        const section = document.querySelector('#tarjetasCredito');
        return section?.classList.contains('cerrado');
      });

      if (needsExpansion) {
        // Click the header to expand
        await page.click('#tarjetasCredito h2');
        // Wait a bit for AJAX to load
        await page.waitForTimeout(2000);
      }

      // Now wait for the select element
      await page.waitForSelector('select[name="tarjetaCredito"]', { timeout: 5000 });
    } catch (error) {
      console.log('   ⚠️  Credit card section not found (you may not have any credit cards)');
    }

    const cards = await page.evaluate(() => {
      const cardOptions = document.querySelectorAll('select[name="tarjetaCredito"] option[data-hash]');
      const creditCards: CreditCard[] = [];

      cardOptions.forEach((option) => {
        const hash = option.getAttribute('data-hash');
        const text = option.textContent?.trim() || '';
        const lastFourMatch = text.match(/\*{4}\s*(\d{4})/);

        if (hash && lastFourMatch) {
          creditCards.push({
            hash,
            lastFourDigits: lastFourMatch[1],
          });
        }
      });

      return creditCards;
    });

    await browser.close();

    // Display results
    console.log('\n✅ Discovery complete!\n');

    if (accounts.length === 0 && cards.length === 0) {
      console.error('⚠️  No accounts or cards found. You may need to log in again.');
      console.error('   Run: npm run get-cookies\n');
      process.exit(1);
    }

    // Format accounts
    const formattedAccounts: string[] = [];

    if (accounts.length > 0) {
      console.log('📊 Bank Accounts Found:');
      accounts.forEach((acc) => {
        const formatted = `${acc.moneda}:${acc.hash}`;
        formattedAccounts.push(formatted);
        console.log(`   • ${acc.moneda} - Balance: ${acc.saldo.toFixed(2)} (${acc.nombreTitular || 'Unknown'})`);
        console.log(`     ID: ${formatted.substring(0, 20)}...`);
      });
      console.log();
    }

    // Format cards
    const formattedCards: string[] = [];

    if (cards.length > 0) {
      console.log('💳 Credit Cards Found:');
      cards.forEach((card) => {
        formattedCards.push(card.hash);
        console.log(`   • **** ${card.lastFourDigits}`);
        console.log(`     ID: ${card.hash.substring(0, 20)}...`);
      });
      console.log();
    }

    // Save configuration
    const config = {
      accounts: formattedAccounts,
      cards: formattedCards,
      discoveredAt: new Date().toISOString(),
    };

    writeFileSync(CONFIG_FILE, JSON.stringify(config, null, 2));

    console.log(`💾 Configuration saved to: ${CONFIG_FILE}`);
    console.log('\n✨ You can now run: npm start\n');

  } catch (error) {
    await browser.close();
    console.error('\n❌ Error during discovery:', error);
    console.error('\n💡 Try refreshing your cookies: npm run get-cookies\n');
    process.exit(1);
  }
}

discoverAccounts();
