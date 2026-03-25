#!/bin/bash
set -e

# Install script for Tesseract OCR dependencies in Docker
# This script installs all dependencies needed for Tesseract build with CMake

echo "=========================================="
echo "Tesseract Dependencies Installation Script"
echo "=========================================="

# Detect the Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_VERSION=$VERSION_ID
else
    echo "Cannot detect OS. /etc/os-release not found."
    exit 1
fi

echo "Detected OS: $OS $OS_VERSION"

# Function to install dependencies on Debian/Ubuntu
install_debian_ubuntu() {
    echo "Installing dependencies for Debian/Ubuntu..."

    # Update package lists
    sudo apt-get update

    # Install build essentials and CMake
    sudo apt-get install -y \
        build-essential \
        cmake \
        pkg-config \
        git \
        wget \
        ca-certificates

    # Install Leptonica and its dependencies
    sudo apt-get install -y \
        libleptonica-dev \
        zlib1g-dev \
        libpng-dev \
        libjpeg-dev

    # Install optional dependencies (TIFF, archive, curl)
    sudo apt-get install -y \
        libtiff-dev \
        libarchive-dev \
        libcurl4-openssl-dev

    # Install training tools dependencies
    sudo apt-get install -y \
        libpango1.0-dev \
        libcairo2-dev \
        libicu-dev

    # Clean up
    sudo apt-get clean
    rm -rf /var/lib/apt/lists/*

    echo "Dependencies installed successfully on Debian/Ubuntu!"
}

# Function to install dependencies on Alpine
install_alpine() {
    echo "Installing dependencies for Alpine..."

    # Update package lists
    apk update

    # Install build essentials and CMake
    apk add --no-cache \
        build-base \
        cmake \
        pkgconfig \
        git \
        wget \
        ca-certificates

    # Install Leptonica and its dependencies
    apk add --no-cache \
        leptonica-dev \
        zlib-dev \
        libpng-dev \
        jpeg-dev

    # Install optional dependencies (TIFF, archive, curl)
    apk add --no-cache \
        tiff-dev \
        libarchive-dev \
        curl-dev

    # Install training tools dependencies
    apk add --no-cache \
        pango-dev \
        cairo-dev \
        icu-dev

    echo "Dependencies installed successfully on Alpine!"
}

# Function to install dependencies on RHEL/CentOS/Fedora/Rocky
install_rhel_centos_fedora() {
    echo "Installing dependencies for RHEL/CentOS/Fedora/Rocky..."

    # Determine package manager
    if command -v dnf &> /dev/null; then
        PKG_MGR="dnf"
    else
        PKG_MGR="yum"
    fi

    # Install EPEL repository if on RHEL/CentOS (for leptonica)
    if [[ "$OS" == "centos" ]] || [[ "$OS" == "rhel" ]] || [[ "$OS" == "rocky" ]]; then
        if [[ "${OS_VERSION%%.*}" -ge 8 ]]; then
            $PKG_MGR install -y epel-release
        else
            $PKG_MGR install -y epel-release
        fi
    fi

    # Update package lists
    $PKG_MGR update -y

    # Install build essentials and CMake
    $PKG_MGR install -y \
        gcc \
        gcc-c++ \
        make \
        cmake \
        pkgconfig \
        git \
        wget \
        ca-certificates

    # Install Leptonica and its dependencies
    $PKG_MGR install -y \
        leptonica-devel \
        zlib-devel \
        libpng-devel \
        libjpeg-devel

    # Install optional dependencies (TIFF, archive, curl)
    $PKG_MGR install -y \
        libtiff-devel \
        libarchive-devel \
        libcurl-devel

    # Install training tools dependencies
    $PKG_MGR install -y \
        pango-devel \
        cairo-devel \
        libicu-devel

    # Clean up
    $PKG_MGR clean all

    echo "Dependencies installed successfully on RHEL/CentOS/Fedora/Rocky!"
}

# Function to install dependencies on Arch
install_arch() {
    echo "Installing dependencies for Arch..."

    # Update package lists
    pacman -Sy

    # Install dependencies
    pacman -S --noconfirm \
        base-devel \
        cmake \
        pkg-config \
        git \
        wget \
        ca-certificates \
        leptonica \
        zlib \
        libpng \
        libjpeg-turbo \
        libtiff \
        libarchive \
        curl \
        pango \
        cairo \
        icu

    echo "Dependencies installed successfully on Arch!"
}

# Install based on detected OS
case "$OS" in
    ubuntu|debian)
        install_debian_ubuntu
        ;;
    alpine)
        install_alpine
        ;;
    centos|rhel|fedora|rocky)
        install_rhel_centos_fedora
        ;;
    arch|manjaro)
        install_arch
        ;;
    *)
        echo "Unsupported OS: $OS"
        echo "Supported distributions: Ubuntu, Debian, Alpine, CentOS, RHEL, Fedora, Rocky, Arch"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "You can now build Tesseract with:"
echo "  cmake -S . -B build"
echo "  cmake --build build"
echo ""
echo "To install Tesseract after building:"
echo "  cmake --install build"
echo ""
