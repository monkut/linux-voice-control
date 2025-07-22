#!/bin/sh

echo "====================================="
echo "Linux Voice Control (LVC) Installer"
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

# Check for system dependencies
echo "Checking system dependencies..."
missing_deps=""

if ! command -v cmake &> /dev/null; then
    missing_deps="$missing_deps cmake"
fi

if ! pkg-config --exists portaudio-2.0 2>/dev/null; then
    missing_deps="$missing_deps portaudio19-dev"
fi

if ! pkg-config --exists mpv 2>/dev/null; then
    missing_deps="$missing_deps libmpv-dev"
fi

if [ -n "$missing_deps" ]; then
    echo "Error: Missing system dependencies:$missing_deps"
    echo
    echo "Please install them first:"
    echo "  Ubuntu/Debian: sudo apt install -y$missing_deps"
    echo "  Fedora: sudo dnf install -y portaudio-devel mpv-devel cmake"
    exit 1
fi

echo "System dependencies OK ✓"
echo

# Install Python dependencies
echo "Installing Python dependencies with uv..."
$UV_CMD sync

if [ $? -ne 0 ]; then
    echo "Error: Failed to install dependencies. Please check the error messages above."
    exit 1
fi

echo "Python dependencies installed ✓"
echo

# Create directories
echo "Setting up Linux-Voice-Control (lvc) directories..."
mkdir -p ~/lvc-bin/misc
mkdir -p ~/lvc-bin/gui

# Copy configuration files
echo "Copying configuration files..."
cp -n lvc-commands.json ~/lvc-bin/lvc-commands.json 2>/dev/null || echo "Config files already exist, skipping..."
cp -n lvc-config.json ~/lvc-bin/lvc-config.json 2>/dev/null || echo "Config files already exist, skipping..."

# Copy resources
echo "Copying resources..."
cp images/lvc-icon.png ~/lvc-bin/ 2>/dev/null || true
cp -r misc/* ~/lvc-bin/misc/ 2>/dev/null || true
cp -r gui/* ~/lvc-bin/gui/ 2>/dev/null || true

# Create launcher scripts
echo "Creating launcher scripts..."

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

# Install launchers
if [ -t 0 ]; then
    # Terminal is available, try sudo
    echo "Installing launchers (requires root access)..."
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
echo "Installation Complete! ✓"
echo "====================================="
echo
echo "Configuration files location: ~/lvc-bin/"
echo
echo "Usage:"
echo "  - Run CLI version:  linux-voice-control"
echo "  - Run GUI version:  linux-voice-control-gui"
echo "  - Run directly:     uv run lvc"
echo
echo "Development commands:"
echo "  - Run checks:       uv run poe check"
echo "  - Format code:      uv run poe format"
echo "  - Run tests:        uv run poe test"
echo
echo "To set up master control mode:"
echo "  uv run python lvc/master_control_mode_setup.py"
echo
echo "Tip: Add linux-voice-control-gui to your startup scripts for always-ready assistance!"
echo