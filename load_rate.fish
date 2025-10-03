#!/usr/bin/env fish
# load_rate.fish — Load USD→UYU exchange rate from ~/.itau_usd_rate.json
# Usage: source load_rate.fish
# Exports: ITAU_RATE

set RATE_FILE "$HOME/.itau_usd_rate.json"

if not test -f $RATE_FILE
    echo "❌ Exchange rate file not found: $RATE_FILE"
    echo "💡 Run 'npm run get-rate' to fetch the current rate."
    return 1
end

# Extract rate from JSON
set -gx ITAU_RATE (jq -r '.rate' $RATE_FILE)

if test -z "$ITAU_RATE"
    echo "❌ Failed to read exchange rate from $RATE_FILE"
    return 1
end

# Optional: Check if rate is older than 24 hours
set rate_age (math (gdate +%s) - (gdate -d (jq -r '.timestamp' $RATE_FILE) +%s))
if test $rate_age -gt 86400  # 24 hours
    echo "⚠️  Warning: Exchange rate is older than 24 hours"
    echo "💡 Run 'npm run get-rate' to refresh the rate."
end

echo "💱 Using exchange rate: 1 USD = $ITAU_RATE UYU"
