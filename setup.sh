#!/bin/sh

ZSHRC="$HOME/.zshrc"

echo "📄 Updating $ZSHRC..."

# Function markers
RANGER_FUNC_MARKER="ranger() {"
TS_FUNC_MARKER="tsc42() {"

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

# 4. Add tsc42() only on a 42 computer
#    (we detect a 42 machine by the sudo group being exactly "sudo:x:<gid>:bocal")
if getent group sudo | grep -qE '^sudo:[^:]*:[0-9]+:bocal$'; then
  if ! grep -q "$TS_FUNC_MARKER" "$ZSHRC"; then
    echo "➕ Adding tsc42() wrapper for TypeScript → JS"
    cat << 'EOF' >> "$ZSHRC"

# 42-specific tsc+node wrapper
tsc42() {
    ./node_modules/.bin/tsc "$1" && node "${1%.ts}.js"
}
EOF
  else
    echo "✅ tsc42() wrapper already exists."
  fi
else
  echo "ℹ️ Not a 42 computer, skipping tsc42() wrapper."
fi

# Final reminder
echo ""
echo "✅ Setup complete."
echo "⚠️  Please run: source ~/.zshrc"

