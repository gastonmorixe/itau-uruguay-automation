#!/usr/bin/env fish
# itau_accounts.fish — fetch & display your Itau bank-account balances

if test (count $argv) -lt 1
    echo "Usage: itau_accounts.fish <currency_code>:<account_id> [<currency_code>:<account_id> ...]"
    exit 1
end

# Load exchange rate from file
set SCRIPT_DIR (dirname (status -f))
source "$SCRIPT_DIR/load_rate.fish"
or begin
    read -P "Enter current USD→UYU exchange rate (UYU per 1 USD): " ITAU_RATE
end
set rate $ITAU_RATE

# Load cookies from file
source "$SCRIPT_DIR/load_cookies.fish"
or begin
    echo "⚠️  Cookie auto-loading failed. Exiting."
    exit 1
end
set cookie $ITAU_COOKIE

set totalUYU 0
set totalUSD 0
for pair in $argv
    # split into code vs. id
    set parts (string split ":" $pair)
    set code $parts[1]
    set id $parts[2]

    # map Itau code → display currency
    switch $code
        case URGP
            set curr UYU
            set realRate $rate
        case 'US.D'
            set curr USD
            set realRate 1
        case '*'
            set curr $code
    end

    # fetch JSON for this account
    echo -n "→ $curr account ($id) balance: "
    set resp (curl -s -X POST \
        "https://www.itaulink.com.uy/trx/cuentas/1/$id/mesActual" \
-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
-H 'Pragma: no-cache' \
-H 'Accept: application/json, text/javascript, */*; q=0.01' \
-H 'Sec-Fetch-Site: same-origin' \
-H 'Accept-Language: en-US,en;q=0.9' \
-H 'Cache-Control: no-cache' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Origin: https://www.itaulink.com.uy' \
-H 'Content-Length: 63' \
-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15' \
-H 'Referer: https://www.itaulink.com.uy/trx/cuentas/1/abc123def456789' \
-H 'Connection: keep-alive' \
-H 'Sec-Fetch-Dest: empty' \
-H "Cookie: $cookie" \
-H 'X-Requested-With: XMLHttpRequest' \
-H 'Priority: u=3, i' \
-H 'X-CSRF-TOKEN: ef4f5586-3e33-408c-b582-b70b31b6e7e0' \
        --data "0:$code:$id")

    # extract saldoFinal (or 0 if missing)
    set bal (echo $resp | jq -r '.itaulink_msg.data.movimientosMesActual.saldoFinal // 0')

    # Ensure bal is numeric
    if test -z "$bal" -o "$bal" = "null"
        set bal 0
    end

    set tt (math $bal "/" $realRate)

    # accumulate
    switch $code
        case URGP
            set totalUYU (math $totalUYU + $bal)
        case 'US.D'
            set totalUSD (math $totalUSD + $bal)
        case '*'
            set curr $code
    end

    # print with two decimals
    printf "%10.2f %s | in USD %7.2f\n" $bal $curr $tt
end

# report per-currency totals
printf "TOTAL   → UYU %7.2f | USD %7.2f\n" $totalUYU $totalUSD

# convert UYU→USD and grand-total
set converted (math $totalUYU / $rate)
set grand (math $totalUSD + $converted)
printf "GRAND   → USD %7.2f (includes UYU→USD @ %.4f)\n" $grand $rate
