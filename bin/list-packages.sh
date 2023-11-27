#!/bin/bash

echo "Packages installed via APT:"
dpkg-query -W -f='${binary:Package} (installed via apt)\n'

echo ""
echo "Packages installed via SNAP:"
snap list | awk 'NR>1 {print $1 " (installed via snap)"}'

echo ""
echo "Packages installed via PIP:"
pip list | awk 'NR>2 {print $1 " (installed via pip)"}'

echo ""
echo "Packages installed via PIPX:"
pipx list | grep 'package ' | sed 's/.*package //' | awk '{print $1 " (installed via pipx)"}'

echo ""
echo "Packages installed via NPM:"
npm list -g --depth 0 | awk 'NR>1 {print $1 " (installed via npm)"}'

echo ""
echo "Executable files in ~/.local/bin (installed manually):"
find ~/.local/bin -type f -executable | sed 's_.*/__' | awk '{print $1 " (installed manually)"}'
