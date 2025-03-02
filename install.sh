#!/bin/bash

# Ensure man directory exists
sudo mkdir -p /usr/local/share/man/man1

# Copy the man page and update the manual database
sudo cp MyCPP.1 /usr/local/share/man/man1/
sudo mandb || echo "Warning: mandb update failed."

# Copy MyCPP script to /usr/local/bin and make it executable
sudo cp MyCPP.sh /usr/local/bin/MyCPP.sh
sudo chmod +x /usr/local/bin/MyCPP.sh

# Add source command to bashrc if not already present
if ! grep -q "source /usr/local/bin/MyCPP.sh" /etc/bash.bashrc; then
    echo "source /usr/local/bin/MyCPP.sh" | sudo tee -a /etc/bash.bashrc
fi

# Add source command to zshrc if not already present
if ! grep -q "source /usr/local/bin/MyCPP.sh" /etc/zsh/zshrc; then
    echo "source /usr/local/bin/MyCPP.sh" | sudo tee -a /etc/zsh/zshrc
fi

echo "Installation complete. Restart your terminal or run:"
echo "source /etc/bash.bashrc (for Bash) or source /etc/zsh/zshrc (for Zsh)"

