#!/usr/bin/env bash
# Builds the Flutter web app and deploys it to the environment's Azure Static
# Web App. runtime_config.js and the IP restriction come from the environment's
# Key Vault. Based on deploy-swa-with-ip.ps1 (Tero Andelin, 11.9.2026).
#
# The IP restriction is mandatory: in SWA the allowed IP ranges are part of the
# deployed content (staticwebapp.config.json), so a deploy without them would
# open the site to the whole internet. Without an IP list the deploy stops.
#
# Usage: deploy/deploy-frontend.sh <dev|test|prod>
#   Deploys only from the environment's own branch (develop, test, main) with a
#   clean working tree. ALLOW_DIRTY=1 deploys the working tree as is from any
#   branch (dev and test only), e.g. to try uncommitted changes in dev.
#   ALLOWED_IP_RANGES  overrides the Key Vault list: a JSON array or addresses
#                      separated by comma, semicolon, space or newline
#
# The script makes no changes to Azure resources. The SWA must already be on the
# Standard tier, which the IP restriction requires.
# Output contains no addresses or identifiers, because pipeline logs are public.
# Must also work on macOS bash 3.2.

# Run the script directly, do not source it (. or source): an exit on error would
# close the caller's terminal, and zsh cannot parse this file.
if [ -n "${ZSH_VERSION:-}" ] || { [ -n "${BASH_VERSION:-}" ] && [ "${BASH_SOURCE[0]}" != "$0" ]; }; then
  echo 'Run the script directly, without . or source, e.g. deploy/deploy-frontend.sh dev' >&2
  return 1
fi

set -euo pipefail
cd "$(dirname "$0")/.."

SWA_CLI='@azure/static-web-apps-cli@2.1.0'

# Colours only on a terminal or in GitHub Actions (which renders them), never with NO_COLOR.
if [ -z "${NO_COLOR:-}" ] && { [ -t 2 ] || [ "${GITHUB_ACTIONS:-}" = true ]; }; then
  C_RED=$'\033[1;31m'; C_GREEN=$'\033[1;32m'; C_YELLOW=$'\033[1;33m'; C_BLUE=$'\033[1;34m'; C_OFF=$'\033[0m'
else
  C_RED=''; C_GREEN=''; C_YELLOW=''; C_BLUE=''; C_OFF=''
fi
info()    { printf '%s==>%s %s\n' "$C_BLUE" "$C_OFF" "$*"; }
ok()      { printf '    %s\n' "$*"; }
success() { printf '%s==> %s%s\n' "$C_GREEN" "$*" "$C_OFF"; }
warn()    { printf '    %sWARNING:%s %s\n' "$C_YELLOW" "$C_OFF" "$*" >&2; }
fail()    { printf '%sERROR:%s %s\n' "$C_RED" "$C_OFF" "$*" >&2; exit 1; }

# Values read from Azure are not GitHub secrets, so they are masked here.
mask() { [ "${GITHUB_ACTIONS:-}" != true ] || [ -z "$1" ] || echo "::add-mask::$1"; }

# --- Environment -----------------------------------------------------------------
ENVIRONMENT=${1:-}
case "$ENVIRONMENT" in
  dev)  BRANCH='develop' ;;
  test) BRANCH='test' ;;
  prod) BRANCH='main' ;;
  *) fail "Unknown environment '$ENVIRONMENT'. Use dev, test or prod." ;;
esac

# Resource names are not in the repo because it is public. Locally they come from
# deploy/deploy.<env>.env (template: deploy/deploy.example.env); in GitHub Actions
# from the environment's secrets. Locally the file is required so that variables
# left in the shell from another environment are never used.
env_file=${JKR_ENV_FILE:-deploy/deploy.$ENVIRONMENT.env}
if [ -f "$env_file" ]; then
  # shellcheck source=/dev/null
  source "$env_file"
elif [ "${GITHUB_ACTIONS:-}" != true ]; then
  fail "Settings file $env_file is missing. Copy deploy/deploy.example.env and fill in the values from the password manager."
fi
missing=''
for key in SUBSCRIPTION RG SWA KEYVAULT; do
  [ -n "${!key:-}" ] || missing="$missing $key"
done
[ -z "$missing" ] || fail "Settings for environment $ENVIRONMENT are missing:$missing"

for tool in az jq npx flutter dart curl; do
  command -v "$tool" >/dev/null || fail "$tool is missing."
done
# The SWA CLI's StaticSitesClient is x86_64 only: Apple Silicon needs Rosetta.
if [ "$(uname -s)/$(uname -m)" = Darwin/arm64 ] && ! arch -x86_64 /usr/bin/true 2>/dev/null; then
  fail 'Rosetta 2 is missing (required by the SWA CLI). Install: softwareupdate --install-rosetta --agree-to-license'
fi

azs() { az "$@" --subscription "$SUBSCRIPTION" --only-show-errors; }
kv() { azs keyvault secret show --vault-name "$KEYVAULT" --name "$1" --query value -o tsv; }

# account show only reads the cache, so an expired login is caught only by
# actually fetching a token.
az account get-access-token --subscription "$SUBSCRIPTION" -o none 2>/dev/null \
  || fail "No valid login for subscription '$SUBSCRIPTION'. Run: az login"

# --- Branch and working tree ------------------------------------------------------
# GitHub Actions checks out a detached commit, so there the branch comes from GITHUB_REF_NAME.
branch=${GITHUB_REF_NAME:-$(git rev-parse --abbrev-ref HEAD)}
if [ "${ALLOW_DIRTY:-0}" = 1 ]; then
  [ "$ENVIRONMENT" != prod ] || fail 'ALLOW_DIRTY=1 is not allowed in production.'
  warn "ALLOW_DIRTY=1: deploying the working tree as is from branch $branch."
else
  [ "$branch" = "$BRANCH" ] \
    || fail "Environment $ENVIRONMENT is deployed only from branch $BRANCH (now: $branch). To try something in dev or test: ALLOW_DIRTY=1 deploy/deploy-frontend.sh $ENVIRONMENT"
  [ -z "$(git status --porcelain)" ] \
    || fail "The working tree has uncommitted changes, so the deploy would not match a commit. Commit them, or to try something: ALLOW_DIRTY=1 deploy/deploy-frontend.sh $ENVIRONMENT"
fi

# --- Static Web App -----------------------------------------------------------------
info "Checking the Static Web App ($ENVIRONMENT)"
read -r sku host <<< "$(azs staticwebapp show --name "$SWA" --resource-group "$RG" \
  --query "join(' ', [sku.name, defaultHostname])" -o tsv)"
[ -n "$host" ] || fail "Static Web App not found (environment $ENVIRONMENT). Check deploy/deploy.$ENVIRONMENT.env."
mask "$host"
[ "$sku" = Standard ] \
  || fail "The Static Web App is on the $sku tier, but the IP restriction requires the Standard tier. The script does not change Azure resources: ask the Azure service provider to change it."
ok 'Standard tier'

# --- IP restriction -------------------------------------------------------------------
info 'Fetching the IP restriction'
ip_source='ALLOWED_IP_RANGES'
raw_ips=${ALLOWED_IP_RANGES:-}
if [ -z "$raw_ips" ]; then
  ip_source='Key Vault'
  raw_ips=$(kv allowed-ip-ranges 2>/dev/null || true)
fi
[ -n "$raw_ips" ] \
  || fail "The IP list is missing (ALLOWED_IP_RANGES or the Key Vault secret allowed-ip-ranges). Without it the site would be open to the whole internet, so nothing is deployed."
# Accepts a JSON array or a separated list. Octets and prefixes are checked as
# numbers, because the regex alone would accept 999.1.1.1 and /99. A bare address
# gets /32 and duplicates are removed.
IPS=$(printf '%s' "$raw_ips" | jq -Rsc '
  (try fromjson catch null) as $json
  | (if ($json | type) == "array" then $json | map(tostring) else split("[[:space:],;]+"; null) end)
  | map(select(length > 0))
  | if length == 0 then error("empty") else . end
  | map(if test("^([0-9]{1,3}[.]){3}[0-9]{1,3}(/[0-9]{1,2})?$")
            and (split("/") as $p
                 | ($p[0] | split(".") | map(tonumber) | all(. <= 255))
                   and (($p[1] // "32") | tonumber) <= 32)
          then (if test("/") then . else . + "/32" end)
          else error("invalid") end)
  | unique' 2>/dev/null) \
  || fail "The IP list ($ip_source) is empty or contains an invalid address. Accepted formats: [\"192.0.2.10/32\"] or 192.0.2.10/32,198.51.100.25"
ok "$(printf '%s' "$IPS" | jq length) allowed addresses ($ip_source)"

info 'Fetching runtime settings from Key Vault'
api_base_url=$(kv api-base-url) || fail 'Key Vault secret api-base-url is missing.'
tenant_id=$(kv azure-tenant-id) || fail 'Key Vault secret azure-tenant-id is missing.'
client_id=$(kv azure-client-id) || fail 'Key Vault secret azure-client-id is missing.'
for value in "$api_base_url" "$tenant_id" "$client_id"; do mask "$value"; done
ok 'api-base-url, azure-tenant-id, azure-client-id'

# --- Build ----------------------------------------------------------------------------
info 'Building Flutter web (release)'
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter build web --release --no-wasm-dry-run

info 'Writing runtime_config.js and staticwebapp.config.json'
config=$(cat web/runtime_config.js.template)
# shellcheck disable=SC2016  # the ${...} placeholders are literal text
{
  config=${config//'${API_BASE_URL}'/"$api_base_url"}
  config=${config//'${AZURE_CLIENT_ID}'/"$client_id"}
  config=${config//'${AZURE_TENANT_ID}'/"$tenant_id"}
  config=${config//'${AZURE_REDIRECT_URI}'/"https://$host"}
  config=${config//'${ENV}'/"$ENVIRONMENT"}
  case "$config" in
    *'${'*) fail 'runtime_config.js.template contains an unknown variable ${...}.' ;;
  esac
}
printf '%s' "$config" > build/web/runtime_config.js
rm -f build/web/runtime_config.js.template

# The IP list never lives in the repo: a networking block left in the source file
# is replaced by the list from the environment.
jq --argjson ips "$IPS" 'del(.networking) | .networking = {allowedIpRanges: $ips}' \
  web/staticwebapp.config.json > build/web/staticwebapp.config.json
ok 'IP restriction added'

# --- Deploy ---------------------------------------------------------------------------
info "Deploying ($ENVIRONMENT)"
token=$(azs staticwebapp secrets list --name "$SWA" --resource-group "$RG" --query properties.apiKey -o tsv)
[ -n "$token" ] || fail 'Fetching the deployment token failed.'
mask "$token"
# The token goes in an environment variable, so it is not on the command line.
SWA_CLI_DEPLOYMENT_TOKEN=$token npx --yes "$SWA_CLI" deploy build/web --env production

# --- Check ----------------------------------------------------------------------------
expected=$(sed -n 's/^version: *\([^+ ]*\).*/\1/p' pubspec.yaml | head -1)
response=$(curl -s --max-time 15 -w '\n%{http_code}' "https://$host/version.json" || true)
code=${response##*$'\n'}
case "$code" in
  200)
    actual=$(printf '%s' "${response%$'\n'*}" | jq -r '.version // empty' 2>/dev/null || true)
    if [ "$actual" = "$expected" ]; then
      ok "Running version $actual"
    else
      warn "The site shows version ${actual:-?}, expected $expected. The cache may update with a delay."
    fi ;;
  403) ok 'IP restriction is active: this machine is not on the allowed list (403).' ;;
  *) warn "Version check failed (HTTP ${code:-?})." ;;
esac

success "Done: $ENVIRONMENT, version $expected. Addresses not on the list get 403."
