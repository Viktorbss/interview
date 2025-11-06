#!/bin/bash
set -e

VENV_DIR="$HOME/ansible-env"
ANSIBLE_VERSION="10.3.0"

echo "🧰 Checking Python virtual environment for Ansible..."

if [ ! -d "$VENV_DIR" ]; then
  echo "📦 Creating new venv at $VENV_DIR..."
  python3 -m venv "$VENV_DIR"
fi

echo "🐍 Activating virtual environment..."
source "$VENV_DIR/bin/activate"

echo "⬇️  Installing / updating Ansible..."
pip install --upgrade pip
pip install --no-cache-dir "ansible==${ANSIBLE_VERSION}"

echo
echo "✅ Ansible environment ready!"
ansible --version | head -5

echo
echo "💡 You can now run commands like:"
echo "   ansible -i inventory.ini all -m ping"
echo "   ansible-playbook -i inventory.ini site.yml"

# Keep user inside the venv for convenience
exec $SHELL
