aws acm import-certificate \
  --certificate fileb://home/una/Downloads/star_healthresearch_org.crt \
  --private-key fileb://home/una/Downloads/star_healthresearch_org.key \
  --certificate-chain fileb://home/una/Downloads/combined.pem \
  --profile production

# aws acm list-certificates --profile test
#
# chmod 600 star_healthresearch_org.key
#
# aws acm list-certificates --profile test
