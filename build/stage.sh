#!/bin/bash
cd "/Users/pablo/Desktop/SINCRETISMO/Sincretismo"

echo "Staging modificados..."
git add -u

echo "Staging nuevos assets (repo anidado, requiere -f)..."
BASE="sincretismo-game_beta/sincretismo(beta)"
git add -f "$BASE/assets/sprites/veladora/"
git add -f "$BASE/assets/sprites/mayordomo/"
git add -f "$BASE/assets/sprites/procesional/"
git add -f "$BASE/assets/sprites/promesero/"
git add -f "$BASE/assets/sprites/env/"
git add -f "$BASE/assets/sprites/ui/"
git add -f "$BASE/assets/bg_layer0.png"
git add -f "$BASE/assets/bg_layer1.png"
git add -f "$BASE/export_presets.cfg"

echo "Staging docs y build..."
git add docs/ build/ .gitignore

echo ""
echo "=== STAGED ==="
git status -uno --short
echo ""
echo "Si ves lineas con A o M al inicio → listo para commit."
