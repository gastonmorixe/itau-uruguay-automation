#!/usr/bin/env fish
# load_cookies.fish — Load Itau cookies from ~/.itau_cookies.json
# Usage: source load_cookies.fish
# Exports: ITAU_COOKIE

set COOKIE_FILE "$HOME/.itau_cookies.json"

if not test -f $COOKIE_FILE
    echo "❌ Cookie file not found: $COOKIE_FILE"
    echo "💡 Run 'npm run get-cookies' to fetch cookies first."
    return 1
end

# Extract cookieString from JSON
set -gx ITAU_COOKIE (jq -r '.cookieString' $COOKIE_FILE)

if test -z "$ITAU_COOKIE"
    echo "❌ Failed to read cookies from $COOKIE_FILE"
    return 1
end

# Optional: Check if cookies are older than 24 hours
set cookie_age (math (gdate +%s) - (gdate -d (jq -r '.timestamp' $COOKIE_FILE) +%s))
if test $cookie_age -gt 86400  # 24 hours
    echo "⚠️  Warning: Cookies are older than 24 hours (may be expired)"
    echo "💡 Run 'npm run get-cookies' to refresh cookies."
end
