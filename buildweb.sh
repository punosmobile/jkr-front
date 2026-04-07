#!/usr/bin/env bash
set -e

echo "[1/2] Builtataan Flutter web..."
flutter build web --no-wasm-dry-run

if [ ! -f "build/web/index.html" ]; then
    echo "Flutter build epäonnistui."
    exit 1
fi

echo "[2/2] Builtataan Docker-image jkr-front..."
docker build -f Dockerfile.local -t jkr-front .

echo ""
echo "Valmis. Käynnistä sovellus: ./rundocker.sh"
echo ""
echo "Vihje: Flutter-muutokset eivät vaadi imagen uudelleenrakennusta."
echo "Aja muutosten jälkeen vain:"
echo "  flutter build web --dart-define-from-file=.env.local"
