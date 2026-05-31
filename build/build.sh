#!/bin/bash
set -e

GODOT="/Users/pablo/Downloads/Godot.app/Contents/MacOS/Godot"
PROJECT="$(cd "$(dirname "$0")/../sincretismo-game_beta/sincretismo(beta)" && pwd)"
BUILD_DIR="$(cd "$(dirname "$0")" && pwd)"
OUT_EXE="$BUILD_DIR/Sincretismo.exe"

GODOT_VERSION="4.6.1.stable"
TEMPLATES_DIR="$HOME/Library/Application Support/Godot/export_templates/$GODOT_VERSION"
TPZ_URL="https://github.com/godotengine/godot/releases/download/4.6.1-stable/Godot_v4.6.1-stable_export_templates.tpz"
TPZ_CACHE="$BUILD_DIR/export_templates.tpz"

echo "=== Sincretismo — Build Script ==="
echo "Godot:   $GODOT"
echo "Project: $PROJECT"
echo "Output:  $OUT_EXE"
echo ""

# ── Install Windows export templates if missing ──────────────────────────────
WIN_DEBUG="$TEMPLATES_DIR/windows_debug_x86_64.exe"
WIN_RELEASE="$TEMPLATES_DIR/windows_release_x86_64.exe"

if [ ! -f "$WIN_RELEASE" ]; then
    echo "Faltan templates de Windows. Descargando (~900 MB)..."
    mkdir -p "$TEMPLATES_DIR"

    if [ ! -f "$TPZ_CACHE" ]; then
        curl -L --progress-bar -o "$TPZ_CACHE" "$TPZ_URL"
    else
        echo "  (usando caché: $TPZ_CACHE)"
    fi

    echo "Extrayendo templates de Windows..."
    # .tpz = zip. Extract only windows files directly into templates dir
    unzip -jo "$TPZ_CACHE" \
        "templates/windows_debug_x86_64.exe" \
        "templates/windows_release_x86_64.exe" \
        -d "$TEMPLATES_DIR"

    # Write version file (Godot requires this)
    echo "$GODOT_VERSION" > "$TEMPLATES_DIR/version.txt"

    echo "Templates instalados en: $TEMPLATES_DIR"
    echo ""
fi

# ── Export ───────────────────────────────────────────────────────────────────
echo "Exportando Windows Desktop..."
cd "$PROJECT"
"$GODOT" --headless --export-release "Windows Desktop" "$OUT_EXE"

if [ -f "$OUT_EXE" ]; then
    SIZE=$(du -sh "$OUT_EXE" | cut -f1)
    echo ""
    echo "✓ $OUT_EXE ($SIZE)"
    echo ""
    echo "Siguiente paso — crear instalador:"
    echo "  Copia build/Sincretismo.exe y build/Sincretismo.iss a Windows"
    echo "  Abre Sincretismo.iss con Inno Setup 6  →  genera SincretismoSetup.exe"
else
    echo "FALLO: no se generó el .exe"
    exit 1
fi
