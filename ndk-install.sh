#!/bin/bash

# ==============================================================================
# Script Name  : ERROR MODZ PRO NDK INSTALLER
# Description  : Advanced script to install NDK & CMake into AndroidIDE
# Author       : ERROR MODZ
# ==============================================================================

# --- Color Variables ---
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
PURPLE='\033[1;35m'
CYAN='\033[1;36m'
NC='\033[0m' # No Color

# --- Directory Setup ---
install_dir=$HOME
sdk_dir=$install_dir/android-sdk
cmake_dir=$sdk_dir/cmake
ndk_base_dir=$sdk_dir/ndk

# --- Global Variables ---
ndk_dir=""
ndk_ver=""
ndk_ver_name=""
ndk_file_name=""
ndk_installed=false
cmake_installed=false
is_lzhiyong_ndk=false
is_bionic_ndk=false

# --- Logging Functions ---
log_info() { echo -e "${CYAN}[*] $1${NC}"; }
log_success() { echo -e "${GREEN}[+] $1${NC}"; }
log_warn() { echo -e "${YELLOW}[!] $1${NC}"; }
log_error() { echo -e "${RED}[x] $1${NC}"; }

# --- Banner ---
show_banner() {
    clear
    echo -e "${RED}"
    echo "███████╗██████╗ ██████╗  ██████╗ ██████╗     ███╗   ███╗██████╗ ██████╗ ███████╗"
    echo "██╔════╝██╔══██╗██╔══██╗██╔═══██╗██╔══██╗    ████╗ ████║██╔══██╗██╔══██╗╚══███╔╝"
    echo "█████╗  ██████╔╝██████╔╝██║   ██║██████╔╝    ██╔████╔██║██║  ██║██║  ██║  ███╔╝ "
    echo "██╔══╝  ██╔══██╗██╔══██╗██║   ██║██╔══██╗    ██║╚██╔╝██║██║  ██║██║  ██║ ███╔╝  "
    echo "███████╗██║  ██║██║  ██║╚██████╔╝██║  ██║    ██║ ╚═╝ ██║██████╔╝██████╔╝███████╗"
    echo "╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝    ╚═╝     ╚═╝╚═════╝ ╚═════╝ ╚══════╝"
    echo -e "${CYAN}                  ► PRO LEVEL NDK INSTALLER ◄${NC}"
    echo -e "${PURPLE}                  ► DEVELOPED BY ERROR MODZ ◄${NC}"
    echo -e "${YELLOW}========================================================================${NC}\n"
}

# --- Dependency Check ---
check_dependencies() {
    log_info "Checking required packages..."
    for cmd in wget unzip tar; do
        if ! command -v $cmd &> /dev/null; then
            log_warn "$cmd is not installed. Installing..."
            pkg install $cmd -y &> /dev/null || apt-get install $cmd -y &> /dev/null
        fi
    done
    log_success "All dependencies are ready!\n"
}

run_install_cmake() {
    log_info "Initializing CMake installations..."
    download_cmake 3.10.2
    download_cmake 3.18.1
    download_cmake 3.22.1
    download_cmake 3.25.1
}

download_cmake() {
    local cmake_version=$1
    log_info "Downloading CMake version ${cmake_version}..."
    wget -q --show-progress "https://github.com/MrIkso/AndroidIDE-NDK/releases/download/cmake/cmake-${cmake_version}-android-aarch64.zip" -N
    installing_cmake "$cmake_version"
}

download_ndk() {
    log_info "Downloading NDK $1..."
    wget -q --show-progress "$2" -N
}

fix_ndk() {
    if [ -d "$ndk_dir" ]; then
        log_info "Creating missing system links..."
        cd "$ndk_dir"/toolchains/llvm/prebuilt || exit
        ln -sf linux-aarch64 linux-x86_64
        cd "$ndk_dir"/prebuilt || exit
        ln -sf linux-aarch64 linux-x86_64
        cd "$install_dir" || exit

        log_info "Patching CMake configurations for aarch64..."
        sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android-legacy.toolchain.cmake
        sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android.toolchain.cmake
        
        log_success "NDK patch applied successfully!"
        ndk_installed=true
    else
        log_error "NDK directory does not exist. Patching failed."
    fi
}

fix_ndk_bionic() {
    if [ -d "$ndk_dir" ]; then
        log_info "Creating missing Bionic system links..."
        cd "$ndk_dir"/toolchains/llvm/prebuilt || exit
        ln -sf linux-arm64 linux-aarch64
        cd "$ndk_dir"/prebuilt || exit
        ln -sf linux-arm64 linux-aarch64
        cd "$ndk_dir"/shader-tools || exit
        ln -sf linux-arm64 linux-aarch64 
        
        log_success "Bionic NDK patch applied successfully!"
        ndk_installed=true
    else
        log_error "NDK directory does not exist. Patching failed."
    fi
}

installing_cmake() {
    local cmake_version=$1
    local cmake_file=cmake-"$cmake_version"-android-aarch64.zip
    
    if [ -f "$cmake_file" ]; then
        log_info "Extracting CMake ${cmake_version}..."
        unzip -qq "$cmake_file" -d "$cmake_dir"
        rm "$cmake_file"
        
        log_info "Setting executable permissions..."
        chmod -R +x "$cmake_dir"/"$cmake_version"/bin
        log_success "CMake ${cmake_version} installed!"
        cmake_installed=true
    else
        log_error "$cmake_file not found."
    fi
}

# --- Main Execution ---
show_banner
check_dependencies

echo -e "${CYAN}Please select the NDK version you want to install:${NC}"
PS3=$(echo -e "\n${YELLOW}ERROR MODZ > Select an option (1-14): ${NC}")

options=("r17c" "r18b" "r19c" "r20b" "r21e" "r22b" "r23b" "r24" "r26b" "r27b" "r27d" "r28c" "r29" "Quit")

select item in "${options[@]}"; do
    case $item in
        "r17c") ndk_ver="17.2.4988734"; ndk_ver_name="r17c"; break ;;
        "r18b") ndk_ver="18.1.5063045"; ndk_ver_name="r18b"; break ;;
        "r19c") ndk_ver="19.2.5345600"; ndk_ver_name="r19c"; break ;;
        "r20b") ndk_ver="20.1.5948944"; ndk_ver_name="r20b"; break ;;
        "r21e") ndk_ver="21.4.7075529"; ndk_ver_name="r21e"; break ;;
        "r22b") ndk_ver="22.1.7171670"; ndk_ver_name="r22b"; break ;;
        "r23b") ndk_ver="23.2.8568313"; ndk_ver_name="r23b"; break ;;
        "r24")  ndk_ver="24.0.8215888"; ndk_ver_name="r24"; break ;;
        "r26b") ndk_ver="26.1.10909125"; ndk_ver_name="r26b"; is_lzhiyong_ndk=true; break ;;
        "r27b") ndk_ver="27.1.12297006"; ndk_ver_name="r27b"; is_lzhiyong_ndk=true; break ;;
        "r27d") ndk_ver="27.3.13750724"; ndk_ver_name="r27d"; is_bionic_ndk=true; break ;;
        "r28c") ndk_ver="28.2.13676358"; ndk_ver_name="r28c"; is_bionic_ndk=true; break ;;
        "r29")  ndk_ver="29.0.14206865"; ndk_ver_name="r29"; is_bionic_ndk=true; break ;;
        "Quit") log_warn "Exiting ERROR MODZ Installer..."; exit ;;
        *) log_error "Invalid selection. Please try again." ;;
    esac
done

echo ""
log_success "Target Version : $ndk_ver_name ($ndk_ver)"
log_warn "Warning: This NDK setup is optimized strictly for AARCH64."
echo ""

cd "$install_dir" || exit

ndk_dir="$ndk_base_dir/$ndk_ver"

if [[ $is_bionic_ndk == true ]]; then
    ndk_file_name="android-ndk-$ndk_ver_name-aarch64-linux-android.tar.xz"
else
    ndk_file_name="android-ndk-$ndk_ver_name-aarch64.zip"
fi

# Cleanup old NDK
if [ -d "$ndk_dir" ]; then
    log_warn "Existing NDK $ndk_ver found. Removing old files..."
    rm -rf "$ndk_dir"
fi

# Cleanup old CMake
for cmake_v in "3.10.2" "3.18.1" "3.22.1" "3.25.1"; do
    if [ -d "$cmake_dir/$cmake_v" ]; then
        log_warn "Removing old CMake version $cmake_v..."
        rm -rf "$cmake_dir/$cmake_v"
    fi
done

# Download logic based on type
if [[ $is_bionic_ndk == true ]]; then
    tag_name=""
    case $ndk_ver_name in
        "r27d") tag_name="r27" ;;
        "r28c") tag_name="r28" ;;
        *) tag_name=$ndk_ver_name ;;
    esac
    download_ndk "$ndk_file_name" "https://github.com/HomuHomu833/android-ndk-custom/releases/download/$tag_name/$ndk_file_name"
elif [[ $is_lzhiyong_ndk == true ]]; then
    download_ndk "$ndk_file_name" "https://github.com/MrIkso/AndroidIDE-NDK/releases/download/ndk/$ndk_file_name"
else
    download_ndk "$ndk_file_name" "https://github.com/jzinferno2/termux-ndk/releases/download/v1/$ndk_file_name"
fi

# Extraction and Setup
if [ -f "$ndk_file_name" ]; then
    log_info "Extracting NDK $ndk_ver_name (This might take a while)..."
    if [[ $is_bionic_ndk == true ]]; then
        tar --no-same-owner -xf "$ndk_file_name" --warning=no-unknown-keyword
    else
        unzip -qq "$ndk_file_name"
    fi
    rm "$ndk_file_name"

    # Moving NDK to SDK Directory
    if [ ! -d "$ndk_base_dir" ]; then
        log_info "Creating NDK base directory..."
        mkdir -p "$sdk_dir"/ndk
    fi
    mv android-ndk-"$ndk_ver_name" "$ndk_dir"

    # Fixes & Patches
    if [[ $is_bionic_ndk == true ]]; then
        fix_ndk_bionic
    elif [[ $is_lzhiyong_ndk == false ]]; then
        fix_ndk
    else
        ndk_installed=true
    fi
else
    log_error "Downloaded file $ndk_file_name not found. Download failed."
    exit 1
fi

# Install CMake
if [ ! -d "$cmake_dir" ]; then
    mkdir -p "$cmake_dir"
fi
cd "$cmake_dir" || exit
run_install_cmake

# Final Validation
echo ""
echo -e "${YELLOW}========================================================================${NC}"
if [[ $ndk_installed == true && $cmake_installed == true ]]; then
    echo -e "${GREEN}[✔] ERROR MODZ INSTALLATION SUCCESSFUL!${NC}"
    echo -e "${CYAN}[*] NDK and CMake have been installed properly.${NC}"
    echo -e "${PURPLE}[*] Please RESTART AndroidIDE to apply all changes.${NC}"
else
    echo -e "${RED}[x] INSTALLATION FAILED!${NC}"
    echo -e "${YELLOW}[!] Something went wrong during NDK or CMake installation.${NC}"
fi
echo -e "${YELLOW}========================================================================${NC}"
