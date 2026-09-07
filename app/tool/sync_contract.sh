#!/usr/bin/env bash
# Copiaza fixture-urile de contract din modulul Odoo in testele Flutter. Sursa de adevar e modulul.
set -euo pipefail
cd "$(dirname "$0")/.."
rm -rf test/contract && mkdir -p test/contract
cp ../odoo/uportho_app/contract/*.json test/contract/
echo "contract sincronizat: $(ls test/contract | tr '\n' ' ')"
