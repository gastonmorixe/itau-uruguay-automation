#!/usr/bin/env tsx
import { webkit } from 'playwright';
import { writeFileSync } from 'fs';
import { homedir } from 'os';
import { join } from 'path';

const COOKIE_FILE = join(homedir(), '.itau_cookies.json');
const LOGIN_URL = 'https://www.itau.com.uy/';
const TARGET_DOMAIN = 'itaulink.com.uy';

async function getCookies() {
  console.log('🚀 Launching WebKit browser...');

  const browser = await webkit.launch({
    headless: false, // User needs to see the browser to log in
  });

  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.1 Safari/605.1.15',
  });

  const page = await context.newPage();

  console.log('🔐 Opening Itau login page...');
  console.log('👤 Please log in manually in the browser window.');
  console.log('⏳ Waiting for redirect to itaulink.com.uy...\n');

  await page.goto(LOGIN_URL, { waitUntil: 'networkidle' });

  // Wait for successful login (redirect to itaulink domain)
  await page.waitForURL(`**://*.${TARGET_DOMAIN}/**`, {
    timeout: 300000, // 5 minutes for user to log in
  });

  console.log('✅ Login successful! Extracting cookies...');

  // Get all cookies from the target domain
  const cookies = await context.cookies();
  const itauCookies = cookies.filter(cookie =>
    cookie.domain.includes(TARGET_DOMAIN)
  );

  // Format cookies for curl (name=value; name=value)
  const cookieString = itauCookies
    .map(c => `${c.name}=${c.value}`)
    .join('; ');

  // Save to file
  const cookieData = {
    timestamp: new Date().toISOString(),
    cookieString,
    cookies: itauCookies,
  };

  writeFileSync(COOKIE_FILE, JSON.stringify(cookieData, null, 2));

  console.log(`💾 Cookies saved to: ${COOKIE_FILE}`);
  console.log(`🍪 Cookie string: ${cookieString.substring(0, 80)}...`);
  console.log('\n✨ Done! You can now run your Fish scripts without entering cookies.\n');

  await browser.close();
}

getCookies().catch(error => {
  console.error('❌ Error:', error.message);
  process.exit(1);
});
