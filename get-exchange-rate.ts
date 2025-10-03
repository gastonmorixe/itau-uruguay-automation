#!/usr/bin/env tsx
import { writeFileSync } from 'fs';
import { homedir } from 'os';
import { join } from 'path';

const RATE_FILE = join(homedir(), '.itau_usd_rate.json');

async function getExchangeRate() {
  console.log('💱 Fetching USD → UYU exchange rate...');

  try {
    // Using exchangerate-api.com (free tier: 1500 requests/month)
    const response = await fetch('https://api.exchangerate-api.com/v4/latest/USD');

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    const rate = data.rates.UYU;

    if (!rate) {
      throw new Error('UYU rate not found in response');
    }

    const rateData = {
      timestamp: new Date().toISOString(),
      rate,
      source: 'exchangerate-api.com',
    };

    writeFileSync(RATE_FILE, JSON.stringify(rateData, null, 2));

    console.log(`✅ Current rate: 1 USD = ${rate.toFixed(4)} UYU`);
    console.log(`💾 Rate saved to: ${RATE_FILE}\n`);

    return rate;
  } catch (error) {
    console.error('❌ Error fetching exchange rate:', error);
    console.error('💡 You will need to enter the rate manually.\n');
    process.exit(1);
  }
}

getExchangeRate();
