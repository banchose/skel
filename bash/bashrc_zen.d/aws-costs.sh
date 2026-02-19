awlcost() {
  aws ce get-cost-and-usage \
    --profile man \
    --region us-east-1 \
    --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --group-by '[{"Type": "DIMENSION", "Key": "SERVICE"}]'
}
awlcostj() {
  local START=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d)
  local END=$(date +%Y-%m-%d)
  aws ce get-cost-and-usage \
    --profile man \
    --region us-east-1 \
    --time-period Start=${START},End=${END} \
    --granularity MONTHLY \
    --metrics "UnblendedCost" \
    --group-by '[{"Type": "DIMENSION", "Key": "SERVICE"}]' |
    jq -r --arg start "$START" --arg end "$END" '
        "Cost: \($start) to \($end)\n",
        (.ResultsByTime[0].Groups
        | map({service: .Keys[0], cost: (.Metrics.UnblendedCost.Amount | tonumber)})
        | sort_by(-.cost)
        | .[] | select(.cost > 0)
        | "\(.cost)  \(.service)"),
        "--------",
        "TOTAL: \([.ResultsByTime[0].Groups[].Metrics.UnblendedCost.Amount | tonumber] | add | . * 100 | round / 100)"
      '
}
