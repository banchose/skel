# export heliospass

user=api
# user=admin

function getjwt() {
  curl -X POST -s -k -u "${user}:${heliospass}" https://helios.example.net/api/v2/auth/jwt
}
# getjwt  | jq -r '.data.token'
