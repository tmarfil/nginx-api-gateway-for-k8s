#!/bin/bash

# Directory to store jwk.json, private_key.pem, and public_key.pem
JWK_DIRECTORY='/var/tmp/jwk/'

# File paths
PRIVATE_KEY_FILE="${JWK_DIRECTORY}private_key.pem"
PUBLIC_KEY_FILE="${JWK_DIRECTORY}public_key.pem"
JWK_FILE="${JWK_DIRECTORY}jwk.json"

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
WHITE='\033[1;37m'
LIGHT_GREY='\033[0;37m'
NO_COLOR='\033[0m' # No color

# Explanation of JWT payload properties
# iss: Issuer - Identifies principal that issued the JWT
# sub: Subject - Identifies the subject of the JWT
# aud: Audience - Identifies the recipients that the JWT is intended for
# exp: Expiration Time - Identifies the expiration time on or after which the JWT must not be accepted for processing
# nbf: Not Before - Identifies the time before which the JWT must not be accepted for processing
# iat: Issued At - Identifies the time at which the JWT was issued
# jti: JWT ID - Provides a unique identifier for the JWT

# To make the JWT below a valid OIDC ID token, add the following claims to the payload:
# 
# 1. "auth_time": <timestamp>          # The time the end-user was authenticated
# 2. "nonce": "<unique-string>"        # A unique value to prevent replay attacks
# 3. "name": "<user-full-name>"        # Optional profile claim for the user's full name
# 4. "email": "<user-email-address>"   # Optional profile claim for the user's email
# 5. "given_name": "<user-first-name>" # Optional profile claim for the user's first name
# 6. "family_name": "<user-last-name>" # Optional profile claim for the user's last name
# 
# Note: The "iss", "sub", "aud", "exp", and "iat" claims are already required for OIDC.
# Ensure the JWT is signed and that the "nonce" is included in the authentication request.

# JWT payload
#
# "exp": 1893456000,                    # "exp": January 1, 2030, 00:00:00 UTC (expiration time)
# "nbf": 1664710022,                    # "nbf": October 2, 2022, 11:27:02 UTC (not before time)
# "iat": 1664710022,                    # "iat": October 2, 2022, 11:27:02 UTC (issued at time)

read -r -d '' jwt_payload << EOM
{
  "iss": "issuer",
  "sub": "subject",
  "aud": "audience",
  "exp": 1893456000,
  "nbf": 1664710022,
  "iat": 1664710022,
  "jti": "id123456"
}
EOM

# Create JWK_DIRECTORY if it does not exist
if [ ! -d "$JWK_DIRECTORY" ]; then
    mkdir -p "$JWK_DIRECTORY"
fi

# Check if private_key.pem and public_key.pem already exist
if [[ ! -f "$PRIVATE_KEY_FILE" || ! -f "$PUBLIC_KEY_FILE" ]]; then
  echo "Generating new RSA key pair..."
  # Generate RSA Private Key
  openssl genpkey -algorithm RSA -out "$PRIVATE_KEY_FILE"

  # Extract Public Key from Private Key
  openssl rsa -pubout -in "$PRIVATE_KEY_FILE" -out "$PUBLIC_KEY_FILE"
fi

# Extract the modulus from the public key
modulus=$(openssl rsa -in "$PUBLIC_KEY_FILE" -pubin -modulus -noout | cut -d'=' -f2)

# Base64-url encode the modulus
modulus=$(echo -n "$modulus" | xxd -r -p | base64 | tr -d '\n' | tr '/+' '_-' | tr -d '=')

# Create JWK_FILE if it does not exist
if [[ ! -f "$JWK_FILE" ]]; then
  echo "Creating $JWK_FILE file..."
  # JSON Web Key Set content with modulus
  cat > "$JWK_FILE" << EOF
{
"keys": [
  {
    "kty": "RSA",
    "alg": "RS256",
    "use": "sig",
    "n": "$modulus",
    "e": "AQAB"
  }
]
}
EOF
else
  echo "Using existing key pair and JWK file..."
fi

# Encode JWT Header
encoded_header=$(echo -n '{"alg":"RS256","typ":"JWT"}' | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Encode JWT Payload
encoded_payload=$(echo -n "$jwt_payload" | jq -c . | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Create Signature
signature=$(echo -n "$encoded_header.$encoded_payload" | openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" | openssl base64 -e -A | tr '+/' '-_' | tr -d '=')

# Construct the JWT
jwt="${RED}$encoded_header${NO_COLOR}.${WHITE}$encoded_payload${NO_COLOR}.${GREEN}$signature${NO_COLOR}"

# Output Authorization Header
echo -e "Authorization Header:\nAuthorization: Bearer $jwt\n"

# Decode and Format JWT
decoded_header=$(echo "$encoded_header" | openssl base64 -d -A | jq .)
decoded_payload=$(echo "$encoded_payload" | openssl base64 -d -A | jq .)

# Output Decoded JWT
echo -e "${LIGHT_GREY}Header:${NO_COLOR}\n${RED}$decoded_header${NO_COLOR}\n"
echo -e "${LIGHT_GREY}Payload:${NO_COLOR}\n${WHITE}$decoded_payload${NO_COLOR}\n"

# Output JWT Signature
echo -e "${LIGHT_GREY}JWT Signature:${NO_COLOR}\n${GREEN}$signature${NO_COLOR}\n"

