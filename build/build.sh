#!/bin/bash
set -e

GODOT="/Users/pablo/Downloads/Godot.app/Contents/MacOS/Godot"
PROJECT="$(cd "$(dirname "$0")/../sincretismo-game_beta/sincretismo(beta)" && pwd)"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_EXE="$BUILD_DIR/Sincretismo.exe"

echo "=== Sincretismo — Build Script ==="
echo "Godot:   $GODOT"
echo "Project: $PROJECT"
echo "Output:  $OUT_EXE"
echo ""

# Check export templates
TEMPLATES_DIR="$HOME/Library/Application Support/Godot/export_templates"
if [ -z "$(ls "$TEMPLATES_DIR" 2>/dev/null)" ]; then
    echo "ERROR: No export templates found."
    echo ""
    echo "Instalar templates:"
    echo "1. Abre Godot"
    echo "2. Editor → Manage Export Templates"
    echo "3. Download for 4.6.1.stable"
    echo "   (o descarga manualmente de https://godotengine.org/download/archive/4.6.1-stable/)"
    echo "   Archivo: Godot_v4.6.1-stable_export_templates.tpz"
    echo "   Extrae en: $TEMPLATES_DIR/4.6.1.stable/"
    exit 1
fi

echo "Exportando Windows Desktop..."
cd "$PROJECT"
"$GODOT" --headless --export-release "Windows Desktop" "$OUT_EXE"

if [ -f "$OUT_EXE" ]; then
    SIZE=$(du -sh "$OUT_EXE" | cut -f1)
    echo ""
    echo "OK: $OUT_EXE ($SIZE)"
    echo ""
    echo "Siguiente paso:"
    echo "  - Compila Sincretismo.iss con Inno Setup en Windows"
    echo "  - O ejecuta:  wine 'C:\\Archivos de programa\\Inno Setup 6\\ISCC.exe' Sincretismo.iss"
else
    echo "FALLO: no se generó el .exe"
    exit 1
fi
