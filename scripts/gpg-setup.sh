#!/usr/bin/env bash
set -euo pipefail

# Default values
KEY_NAME=""
KEY_EMAIL=""
KEY_COMMENT="GitHub Signing Key"
KEY_LENGTH="4096"
KEY_EXPIRE="1y"
KEY_BACKUP_DIR="$HOME/gpg_backup"
ENCRYPT_BACKUP=true
KEYSERVER="hkps://keys.openpgp.org"

usage() {
  cat <<EOF
Usage: $0 -n "Your Name" -e "your-email@github.com" [options]

Required:
  -n  GPG user name
  -e  GPG email

Optional:
  -c  Comment (default: "$KEY_COMMENT")
  -l  Key length (default: $KEY_LENGTH)
  -x  Expiry (default: $KEY_EXPIRE)
  -d  Backup directory (default: $KEY_BACKUP_DIR)
  -s  Keyserver (default: $KEYSERVER)
  -u  Unencrypted private key backup (default: false)
  -h  Show help
EOF
}

while getopts "n:e:c:l:x:d:s:uh" opt; do
  case "$opt" in
    n) KEY_NAME="$OPTARG" ;;
    e) KEY_EMAIL="$OPTARG" ;;
    c) KEY_COMMENT="$OPTARG" ;;
    l) KEY_LENGTH="$OPTARG" ;;
    x) KEY_EXPIRE="$OPTARG" ;;
    d) KEY_BACKUP_DIR="$OPTARG" ;;
    s) KEYSERVER="$OPTARG" ;;
    u) ENCRYPT_BACKUP=false ;;
    h) usage; exit 0 ;;
    *) usage; exit 1 ;;
  esac
done

if [[ -z "$KEY_NAME" || -z "$KEY_EMAIL" ]]; then
  echo "❌ Error: -n (name) and -e (email) are required."
  usage
  exit 1
fi

# Ensure backup directory
mkdir -p "$KEY_BACKUP_DIR"
chmod 700 "$KEY_BACKUP_DIR"

# Generate GPG batch config
KEY_GEN_FILE=$(mktemp)
cat > "$KEY_GEN_FILE" <<EOF
%no-protection
Key-Type: RSA
Key-Length: $KEY_LENGTH
Name-Real: $KEY_NAME
Name-Email: $KEY_EMAIL
Name-Comment: $KEY_COMMENT
Expire-Date: $KEY_EXPIRE
%commit
EOF

echo "[*] Generating GPG key..."
gpg --batch --generate-key "$KEY_GEN_FILE"
rm "$KEY_GEN_FILE"

# Extract key ID
KEY_ID=$(gpg --list-secret-keys --with-colons "$KEY_EMAIL" | awk -F: '/^sec/ {print $5}')
echo "[+] Generated GPG key ID: $KEY_ID"

# Export keys
PUB_KEY_FILE="$KEY_BACKUP_DIR/gpg-public-$KEY_ID.asc"
gpg --armor --export "$KEY_ID" > "$PUB_KEY_FILE"
echo "[+] Public key exported to $PUB_KEY_FILE"

PRIV_KEY_FILE="$KEY_BACKUP_DIR/gpg-private-$KEY_ID.asc"
gpg --armor --export-secret-keys "$KEY_ID" > "$PRIV_KEY_FILE"
echo "[+] Private key exported to $PRIV_KEY_FILE"

# Optionally encrypt
if [ "$ENCRYPT_BACKUP" = true ]; then
  echo "[*] Encrypting private key..."
  gpg --symmetric --cipher-algo AES256 "$PRIV_KEY_FILE"
  shred -u "$PRIV_KEY_FILE"
  PRIV_KEY_FILE="$PRIV_KEY_FILE.gpg"
  echo "[+] Encrypted private key saved to $PRIV_KEY_FILE"
fi

# Export ownertrust
gpg --export-ownertrust > "$KEY_BACKUP_DIR/gpg-ownertrust.txt"
echo "[+] Ownertrust exported."

# Write metadata
cat > "$KEY_BACKUP_DIR/gpg-key-info.txt" <<EOF
Key ID: $KEY_ID
Created: $(date)
Expires: $KEY_EXPIRE
Name: $KEY_NAME
Email: $KEY_EMAIL
Comment: $KEY_COMMENT
Encrypted: $ENCRYPT_BACKUP
Backup Dir: $KEY_BACKUP_DIR
Keyserver: $KEYSERVER
EOF
echo "[+] Metadata written to gpg-key-info.txt"

# Upload public key
echo "[*] Uploading public key to $KEYSERVER..."
gpg --keyserver "$KEYSERVER" --send-keys "$KEY_ID"
echo "[!] Remember to confirm your key via email ($KEY_EMAIL)"

echo "[✔] GPG key setup and backup complete."
