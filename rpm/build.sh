#!/bin/bash
#
# Build Fedora RPM for patched thermald.
#
# Prerequisites:
#   sudo dnf install rpm-build rpmdevtools gcc-c++ make autoconf automake \
#     autoconf-archive glib2-devel libxml2-devel systemd-rpm-macros \
#     upower-devel libevdev-devel gtk-doc desktop-file-utils
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Extract version from spec file.
VERSION=$(grep '^Version:' "$SCRIPT_DIR/thermald.spec" | awk '{print $2}')
echo "Building thermald $VERSION RPM..."

# Set up rpmbuild tree.
rpmdev-setuptree

# Generate source tarball from git tag.
echo "Generating source tarball from tag v$VERSION..."
git -C "$REPO_DIR" archive --format=tar.gz --prefix="thermal_daemon-$VERSION/" \
    "v$VERSION" -o "$HOME/rpmbuild/SOURCES/thermald-$VERSION.tar.gz"

# Copy spec and patches into rpmbuild dirs.
cp "$SCRIPT_DIR/thermald.spec" "$HOME/rpmbuild/SPECS/"
cp "$SCRIPT_DIR"/*.patch "$HOME/rpmbuild/SOURCES/"

# Build binary and source RPMs.
echo "Running rpmbuild..."
rpmbuild -ba "$HOME/rpmbuild/SPECS/thermald.spec"

echo ""
echo "Done. RPMs are in:"
ls -1 "$HOME/rpmbuild/RPMS/x86_64"/thermald-*.rpm 2>/dev/null
ls -1 "$HOME/rpmbuild/SRPMS"/thermald-*.rpm 2>/dev/null
