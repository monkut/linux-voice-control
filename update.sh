#!/bin/sh

echo "====================================="
echo "Linux Voice Control (LVC) Updater"
echo "====================================="
echo

# Check if uv is installed
UV_CMD=""
if command -v uv &> /dev/null; then
    UV_CMD="uv"
elif [ -x "$HOME/.local/bin/uv" ]; then
    UV_CMD="$HOME/.local/bin/uv"
elif [ -x "$HOME/.cargo/bin/uv" ]; then
    UV_CMD="$HOME/.cargo/bin/uv"
else
    echo "Error: uv is not installed. Please install it first:"
    echo "  curl -LsSf https://astral.sh/uv/install.sh | sh"
    exit 1
fi

echo "Found uv at: $UV_CMD"

# Pull latest changes
echo "Pulling latest changes from repository..."
# Check if we're in a git repository
if [ -d .git ]; then
    # Try to pull, but don't fail if branch is not set up
    git pull origin main 2>/dev/null || git pull 2>/dev/null || echo "Note: Could not pull latest changes (local development branch?)"
else
    echo "Note: Not in a git repository, skipping pull"
fi

# Update Python dependencies
echo "Updating Python dependencies with uv..."
echo "(This may take a while if downloading large ML models like PyTorch...)"

# Check if --quick flag is passed
if [ "$1" = "--quick" ]; then
    echo "Quick mode: Skipping dependency update"
else
    $UV_CMD sync --upgrade
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to update dependencies. Please check the error messages above."
        echo "Tip: Use './update.sh --quick' to skip dependency updates"
        exit 1
    fi
    
    echo "Python dependencies updated ✓"
fi
echo

# Update resources
echo "Updating resources..."
cp images/lvc-icon.png ~/lvc-bin/ 2>/dev/null || true
cp -r misc/* ~/lvc-bin/misc/ 2>/dev/null || true
cp -r gui/* ~/lvc-bin/gui/ 2>/dev/null || true

# Update launcher scripts
echo "Updating launcher scripts..."

# Create main launcher
cat > linux-voice-control << EOF
#!/bin/bash
# Find uv command
if command -v uv &> /dev/null; then
    UV_CMD="uv"
elif [ -x "\$HOME/.local/bin/uv" ]; then
    UV_CMD="\$HOME/.local/bin/uv"
elif [ -x "\$HOME/.cargo/bin/uv" ]; then
    UV_CMD="\$HOME/.cargo/bin/uv"
else
    echo "Error: uv not found. Please install it first."
    exit 1
fi

cd "\$(dirname "\$0")"
exec \$UV_CMD run lvc "\$@"
EOF

# Create GUI launcher
cat > linux-voice-control-gui << EOF
#!/bin/bash
# Find uv command
if command -v uv &> /dev/null; then
    UV_CMD="uv"
elif [ -x "\$HOME/.local/bin/uv" ]; then
    UV_CMD="\$HOME/.local/bin/uv"
elif [ -x "\$HOME/.cargo/bin/uv" ]; then
    UV_CMD="\$HOME/.cargo/bin/uv"
else
    echo "Error: uv not found. Please install it first."
    exit 1
fi

cd "\$(dirname "\$0")"
exec \$UV_CMD run lvc-gui "\$@"
EOF

chmod +x linux-voice-control linux-voice-control-gui

# Update launchers
if [ -t 0 ]; then
    # Terminal is available, try sudo
    echo "Updating launchers (requires root access)..."
    if sudo cp linux-voice-control /usr/local/bin/ 2>/dev/null && \
       sudo cp linux-voice-control-gui /usr/local/bin/ 2>/dev/null && \
       sudo chmod 0755 /usr/local/bin/linux-voice-control /usr/local/bin/linux-voice-control-gui 2>/dev/null; then
        echo "Launchers installed to /usr/local/bin/ ✓"
    else
        echo "Note: Could not install launchers to /usr/local/bin/ (sudo required)"
        echo "You can run the launchers from the current directory instead"
    fi
else
    echo "Note: Skipping system-wide launcher installation (no terminal available)"
    echo "You can run './linux-voice-control' from this directory"
fi

echo
echo "====================================="
echo "Update Complete! ✓"
echo "====================================="
echo
echo "Configuration files preserved at: ~/lvc-bin/"
echo
echo "Run 'linux-voice-control' or 'uv run lvc' to start!"
echo