#!/bin/sh

ZSHRC="$HOME/.zshrc"

echo "📄 Updating $ZSHRC..."

# Function marker
RANGER_FUNC_MARKER="ranger() {"

# Alias definitions
ALIAS_NAN="alias nan='gnome-text-editor'"
ALIAS_RAN="alias ran='ranger'"

# 1. Add ranger function if not already there
if ! grep -q "$RANGER_FUNC_MARKER" "$ZSHRC"; then
  echo "➕ Adding ranger function..."
  cat << 'EOF' >> "$ZSHRC"

# Ranger wrapper to stay in last visited directory on exit
ranger() {
    tempfile=$(mktemp)
    command ranger --choosedir="$tempfile" "$@"
    if [ -f "$tempfile" ]; then
        target=$(cat "$tempfile")
        rm -f "$tempfile"
        if [ -d "$target" ]; then
            cd "$target"
        fi
    fi
}
EOF
else
  echo "✅ Ranger function already exists."
fi

# 2. Add alias nan → gnome-text-editor
if ! grep -qF "$ALIAS_NAN" "$ZSHRC"; then
  echo "➕ Adding alias: nan -> gnome-text-editor"
  echo "$ALIAS_NAN" >> "$ZSHRC"
else
  echo "✅ Alias for nan already exists."
fi

# 3. Add alias ran → ranger
if ! grep -qF "$ALIAS_RAN" "$ZSHRC"; then
  echo "➕ Adding alias: ran -> ranger"
  echo "$ALIAS_RAN" >> "$ZSHRC"
else
  echo "✅ Alias for ran already exists."
fi

# Final reminder
echo ""
echo "✅ Setup complete."
echo "⚠️  Please run: source ~/.zshrc"

