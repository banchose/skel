aws acm import-certificate \
  --certificate fileb:///home/una/temp/xaax.dev-ssl-bundle/domain.cert.pem \
  --private-key fileb:///home/una/temp/xaax.dev-ssl-bundle/private.key.pem \
  --profile net

# aws acm list-certificates --profile test
#
# chmod 600 star_healthresearch_org.key
#
# aws acm list-certificates --profile test
