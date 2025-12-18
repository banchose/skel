drudge() {
  local max=1000
  for ((count = 1; count < $max; count++)); do
    curl -L -s -A "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:59.0) Gecko/20100101 Firefox/59.0" www.drudgereport.com | grep -oPi --color=always 'color=red>\K[^<]*(?=<)'
    echo "Count $count"
    date "+%a %D %H:%M:%S"
    sleep 300
  done
}
