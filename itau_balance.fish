#!/usr/bin/env fish
# itau_balance.fish — sum & show your Itau credit‐card future balances month by month

if test (count $argv) -ne 1
    echo "Usage: itau_balance.fish <card_id>"
    exit 1
end
set CARD_ID $argv[1]

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
    echo "⚠️  Cookie auto-loading failed. Please enter manually or run 'npm run get-cookies'"
    exit 1
end
set cookie $ITAU_COOKIE

set totalUYU 0
set totalUSD 0
set month_offset 0

echo ""
echo "Fetching future balances for card $CARD_ID …"
echo ---------------------------------------------------------

while true
    # build the period string YYYYMM00 for `month_offset` months out
    set base (gdate +%Y-%m-01)
    set period (gdate -d "$base +$month_offset months" +%Y%m00)

    # extract year & month for display
    set year (string sub -s 1 -l 4 $period)
    set mon (string sub -s 5 -l 2 $period)

    printf "Fetching month %s-%s … " $year $mon

    # fetch the JSON totals
    set resp (curl -s -X POST \
        "https://www.itaulink.com.uy/trx/tarjetas/credito/$CARD_ID/movimientos_actuales/$period" \
-H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
-H 'Pragma: no-cache' \
-H 'Accept: application/json, text/javascript, */*; q=0.01' \
-H 'Sec-Fetch-Site: same-origin' \
-H 'Accept-Language: en-US,en;q=0.9' \
-H 'Cache-Control: no-cache' \
-H 'Sec-Fetch-Mode: cors' \
-H 'Accept-Encoding: gzip, deflate, br' \
-H 'Origin: https://www.itaulink.com.uy' \
-H 'Content-Length: 2' \
-H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Safari/605.1.15' \
-H 'Referer: https://www.itaulink.com.uy/trx/tarjetas/credito/card456def789abc012345' \
-H 'Connection: keep-alive' \
-H 'Sec-Fetch-Dest: empty' \
-H "Cookie: $cookie" \
-H 'X-Requested-With: XMLHttpRequest' \
-H 'Priority: u=3, i' \
-H 'X-CSRF-TOKEN: ef4f5586-3e33-408c-b582-b70b31b6e7e0' \
        --data '{}')

    # parse out the two totals with jq (fallback to 0 if missing)
    set u (echo $resp | jq '.itaulink_msg.data.datos.datosMovimientos.totalesPesos.totalGeneral // 0')
    set d (echo $resp | jq '.itaulink_msg.data.datos.datosMovimientos.totalesDolares.totalGeneral // 0')

    # stop if both zero
    if test $u = 0 -a $d = 0
        break
    end

    set tt (math $d + $u / $rate)

    # print this month’s balances
    printf "%s-%s →  UYU %7.2f | USD %7.2f | Total USD: %7.2f\n" $year $mon $u $d $tt

    # accumulate
    set totalUYU (math $totalUYU + $u)
    set totalUSD (math $totalUSD + $d)
    set month_offset (math $month_offset + 1)
end

echo ---------------------------------------------------------
# report per-currency totals
printf "TOTAL   → UYU %7.2f | USD %7.2f\n" $totalUYU $totalUSD

# convert UYU→USD and grand-total
set converted (math $totalUYU / $rate)
set grand (math $totalUSD + $converted)
printf "GRAND   → USD %7.2f (includes UYU→USD @ %.4f)\n" $grand $rate
