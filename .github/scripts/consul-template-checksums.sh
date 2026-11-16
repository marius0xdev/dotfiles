#!/usr/bin/env bash
# Rewrites consul-template's per-platform URLs and SHA-256 checksums in the mise
# config to match its `version`, using HashiCorp's GPG-signed SHA256SUMS.
# Run on Renovate PRs by .github/workflows/consul-template-checksums.yml;
# works locally too (needs curl and gpg). Usage: $0 [path/to/config.toml]
set -euo pipefail

config="${1:-mise/.config/mise/config.toml}"
# HashiCorp's release signing key, published at
# https://www.hashicorp.com/trust/security
fingerprint="C874011F0AB405110D02105534365D9472D7468F"

version="$(awk '/^\[tools\."http:consul-template"\]$/ { f = 1; next }
  f && /^version = / { gsub(/"/, "", $3); print $3; exit }' "$config")"
if [ -z "$version" ]; then
  echo "consul-template version not found in $config" >&2
  exit 1
fi
base="https://releases.hashicorp.com/consul-template/$version/consul-template_$version"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/consul-template.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
export GNUPGHOME="$tmp/gnupg"
mkdir -m 700 "$GNUPGHOME"

curl -fsSL -o "$tmp/key.asc" https://www.hashicorp.com/.well-known/pgp-key.txt
curl -fsSL -o "$tmp/SHA256SUMS" "${base}_SHA256SUMS"
curl -fsSL -o "$tmp/SHA256SUMS.sig" "${base}_SHA256SUMS.sig"

# The key is downloaded, so trust only a signature by the pinned fingerprint.
# VALIDSIG's last field is the primary key's fingerprint, also when a subkey signed.
gpg --batch --quiet --import "$tmp/key.asc" 2>/dev/null
gpg --batch --status-file "$tmp/status" --verify "$tmp/SHA256SUMS.sig" "$tmp/SHA256SUMS" 2>/dev/null || true
if ! grep -Eq "^\[GNUPG:\] VALIDSIG .* $fingerprint\$" "$tmp/status"; then
  echo "SHA256SUMS for consul-template $version is not signed by $fingerprint" >&2
  exit 1
fi

line() { # $1 = mise platform, $2 = HashiCorp platform
  local file="consul-template_${version}_$2.zip" sum
  sum="$(awk -v f="$file" '$2 == f { print $1 }' "$tmp/SHA256SUMS")"
  if ! printf '%s\n' "$sum" | grep -Eqx '[0-9a-f]{64}'; then
    echo "no checksum for $file in SHA256SUMS" >&2
    exit 1
  fi
  printf '%s = { url = "%s_%s.zip", checksum = "sha256:%s" }' "$1" "$base" "$2" "$sum"
}
arm64="$(line macos-arm64 darwin_arm64)"
x64="$(line macos-x64 darwin_amd64)"

prefix='{ url = "https://releases.hashicorp.com/consul-template/'
awk -v arm64="$arm64" -v x64="$x64" -v prefix="$prefix" '
  index($0, "macos-arm64 = " prefix) == 1 { print arm64; n++; next }
  index($0, "macos-x64 = " prefix) == 1 { print x64; n++; next }
  { print }
  END { if (n != 2) exit 1 }
' "$config" > "$tmp/config.toml" || {
  echo "expected one macos-arm64 and one macos-x64 consul-template line in $config" >&2
  exit 1
}
cat "$tmp/config.toml" > "$config"
echo "consul-template $version: URLs and checksums updated from signed SHA256SUMS"
