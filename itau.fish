#!/usr/bin/env fish
# itau.fish — Interactive launcher for Itau bank automation
# Saves account/card IDs and chains all scripts together

set CONFIG_FILE "$HOME/.itau_config.json"
set SCRIPT_DIR (dirname (status -f))

# Color codes
set -l GREEN '\033[0;32m'
set -l YELLOW '\033[1;33m'
set -l BLUE '\033[0;34m'
set -l RED '\033[0;31m'
set -l NC '\033[0m' # No Color

# Dynamic header with perfect alignment
set header_text "🏦  Itau Bank Uruguay Automation"
# Emoji takes 2 visual columns but counts as 1 character
# Visual width = string length + 1 (for emoji) = 31 + 1 = 32
set text_visual_width (math (string length "$header_text") + 1)
# Total inner width (text + padding on both sides)
set inner_width (math $text_visual_width + 4)  # 4 for "║  " and "  ║"
# Border width (inner + 2 for ║ on each side)
set total_width (math $inner_width + 2)

set border_line (string repeat -n $inner_width "═")

echo -e "\n$BLUE╔$border_line╗$NC"
echo -e "$BLUE║  $header_text  ║$NC"
echo -e "$BLUE╚$border_line╝$NC\n"

# Check if config exists
if test -f $CONFIG_FILE
    echo -e "$GREEN✓ Found saved configuration:$NC\n"

    # Display saved config
    set accounts (jq -r '.accounts[]' $CONFIG_FILE 2>/dev/null)
    set cards (jq -r '.cards[]' $CONFIG_FILE 2>/dev/null)

    if test -n "$accounts"
        echo -e "$BLUE📊 Bank Accounts:$NC"
        for acc in $accounts
            set parts (string split ":" $acc)
            echo "   • $parts[1]: $parts[2]"
        end
        echo ""
    end

    if test -n "$cards"
        echo -e "$BLUE💳 Credit Cards:$NC"
        for card in $cards
            echo "   • $card"
        end
        echo ""
    end

    # Ask to continue or reconfigure
    read -P "Continue with saved config? [Y/n] " continue

    if test "$continue" = "n" -o "$continue" = "N"
        echo -e "\n$YELLOW⚙️  Reconfiguring...$NC\n"
        set reconfigure 1
    else
        set reconfigure 0
    end
else
    echo -e "$YELLOW⚙️  First time setup - let's configure your accounts$NC\n"
    set reconfigure 1
end

# Configure accounts and cards if needed
if test $reconfigure -eq 1
    set new_accounts
    set new_cards

    # Offer auto-discovery
    echo -e "$BLUE🔍 Account Discovery$NC"
    echo "Would you like to automatically discover your accounts and cards?"
    echo "(This will use your saved cookies to extract all account info)"
    echo ""
    read -P "Auto-discover? [Y/n] " auto_discover

    if test "$auto_discover" != "n" -a "$auto_discover" != "N"
        echo ""
        echo -e "$YELLOW🚀 Running auto-discovery...$NC\n"

        npm run discover

        if test $status -eq 0
            # Discovery succeeded, load the config and use it
            set new_accounts (jq -r '.accounts[]' $CONFIG_FILE 2>/dev/null)
            set new_cards (jq -r '.cards[]' $CONFIG_FILE 2>/dev/null)

            echo -e "\n$GREEN✓ Auto-discovery complete!$NC\n"
        else
            echo -e "\n$YELLOW⚠️  Auto-discovery failed.$NC"
            echo ""
            read -P "Would you like to login now to get fresh cookies? [Y/n] " login_now

            if test "$login_now" != "n" -a "$login_now" != "N"
                echo ""
                echo -e "$BLUE🔐 Opening browser for login...$NC\n"

                npm run get-cookies

                if test $status -eq 0
                    echo ""
                    echo -e "$GREEN✓ Cookies saved! Retrying auto-discovery...$NC\n"

                    npm run discover

                    if test $status -eq 0
                        set new_accounts (jq -r '.accounts[]' $CONFIG_FILE 2>/dev/null)
                        set new_cards (jq -r '.cards[]' $CONFIG_FILE 2>/dev/null)
                        echo -e "\n$GREEN✓ Auto-discovery successful!$NC\n"
                    else
                        echo -e "\n$YELLOW⚠️  Auto-discovery still failed. Falling back to manual entry.$NC\n"
                    end
                else
                    echo -e "\n$RED❌ Login failed. Falling back to manual entry.$NC\n"
                end
            else
                echo -e "$YELLOW⚠️  Falling back to manual entry.$NC\n"
            end
        end
    end

    # Manual entry if auto-discovery was skipped or failed
    if test (count $new_accounts) -eq 0 -a (count $new_cards) -eq 0
        # Ask for bank accounts
        echo -e "$BLUE📊 Bank Accounts$NC"
        echo "Enter your bank accounts in format: CURRENCY:ACCOUNT_ID"
        echo "Currency codes: URGP (UYU), US.D (USD)"
        echo "Press Enter with no input when done.\n"

        set account_num 1
        while true
            read -P "Account #$account_num (or press Enter to finish): " account

            if test -z "$account"
                break
            end

            # Validate format
            if not string match -q "*:*" $account
                echo -e "$RED❌ Invalid format. Use: CURRENCY:ACCOUNT_ID$NC"
                continue
            end

            set new_accounts $new_accounts $account
            set account_num (math $account_num + 1)
        end

        echo ""

        # Ask for credit cards
        echo -e "$BLUE💳 Credit Cards$NC"
        echo "Enter your credit card IDs"
        echo "Press Enter with no input when done.\n"

        set card_num 1
        while true
            read -P "Card #$card_num (or press Enter to finish): " card

            if test -z "$card"
                break
            end

            set new_cards $new_cards $card
            set card_num (math $card_num + 1)
        end

        # Validate we have at least one account or card
        if test (count $new_accounts) -eq 0 -a (count $new_cards) -eq 0
            echo -e "\n$RED❌ No accounts or cards entered. Exiting.$NC\n"
            exit 1
        end

        # Save to config file (only for manual entry)
        set json_accounts (printf '%s\n' $new_accounts | jq -R . | jq -s .)
        set json_cards (printf '%s\n' $new_cards | jq -R . | jq -s .)

        echo "{\"accounts\": $json_accounts, \"cards\": $json_cards}" | jq '.' > $CONFIG_FILE

        echo -e "\n$GREEN✓ Configuration saved to $CONFIG_FILE$NC\n"
    end

    # Set variables for execution
    set accounts $new_accounts
    set cards $new_cards
else
    # Load from config
    set accounts (jq -r '.accounts[]' $CONFIG_FILE 2>/dev/null)
    set cards (jq -r '.cards[]' $CONFIG_FILE 2>/dev/null)
end

# Start execution
echo -e "$BLUE════════════════════════════════════════$NC\n"
echo -e "$YELLOW🚀 Starting automation sequence...$NC\n"

# Step 1: Validate cookies (load_cookies.fish will handle expiry check)
echo -e "$BLUE"'[1/4]'" 🍪 Checking authentication...$NC"
if not test -f "$HOME/.itau_cookies.json"
    echo "No cookies found. Opening browser for login..."
    npm run get-cookies
    if test $status -ne 0
        echo -e "\n$RED❌ Failed to get cookies. Exiting.$NC\n"
        exit 1
    end
else
    echo -e "$GREEN✓ Cookies found$NC"
end

echo ""

# Step 2: Get exchange rate
echo -e "$BLUE"'[2/4]'" 💱 Fetching exchange rate...$NC"
npm run get-rate
if test $status -ne 0
    echo -e "$YELLOW⚠️  Failed to fetch rate automatically. You may need to enter manually.$NC"
end

echo ""

# Step 3: Fetch account balances
if test (count $accounts) -gt 0
    echo -e "$BLUE"'[3/4]'" 📊 Fetching bank account balances...$NC"
    echo -e "$BLUE════════════════════════════════════════$NC\n"

    $SCRIPT_DIR/itau_accounts.fish $accounts

    echo ""
else
    echo -e "$BLUE"'[3/4]'" 📊 No bank accounts configured - skipping$NC\n"
end

# Step 4: Fetch credit card balances
if test (count $cards) -gt 0
    echo -e "$BLUE"'[4/4]'" 💳 Fetching credit card balances...$NC"
    echo -e "$BLUE════════════════════════════════════════$NC\n"

    for card in $cards
        $SCRIPT_DIR/itau_balance.fish $card
        echo ""
    end
else
    echo -e "$BLUE"'[4/4]'" 💳 No credit cards configured - skipping$NC\n"
end

# Summary
echo -e "$GREEN╔════════════════════════════════════════╗$NC"
echo -e "$GREEN║  ✨  All done! Have a great day! ✨   ║$NC"
echo -e "$GREEN╚════════════════════════════════════════╝$NC\n"
