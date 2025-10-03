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

# Check if cookies are older than 1 hour (likely expired)
set cookie_age (math (gdate +%s) - (gdate -d (jq -r '.timestamp' $COOKIE_FILE) +%s))
set cookie_hours (math $cookie_age / 3600)

if test $cookie_age -gt 3600  # 1 hour
    echo ""
    echo "⚠️  Cookies are $cookie_hours hours old and likely expired"
    echo "🔒 Authentication required to continue"
    echo ""
    read -P "Would you like to log in now? [Y/n] " -n 1 response

    if test -z "$response" -o "$response" = "y" -o "$response" = "Y"
        echo ""
        echo "🚀 Opening browser for authentication..."
        npm run get-cookies
        if test $status -eq 0
            # Reload the fresh cookies
            set -gx ITAU_COOKIE (jq -r '.cookieString' $COOKIE_FILE)
            echo "✅ Cookies refreshed successfully!"
            echo ""
        else
            echo "❌ Failed to get cookies"
            return 1
        end
    else
        echo ""
        echo "❌ Cannot continue without valid cookies"
        echo "💡 Run 'npm run get-cookies' when you're ready to authenticate"
        return 1
    end
end
