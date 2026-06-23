#!/bin/bash

# ==============================================================================
# Script Name  : ERROR MODZ PRO MASTER INSTALLER (V6.0 - COMPLETE DEV SUITE)
# Description  : Auto-Install Git, OpenSSH, NDK, CMake, JDK, and Android SDK
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

# --- Directory & Log Setup ---
install_dir=$HOME
sdk_dir=$install_dir/android-sdk
cmake_dir=$sdk_dir/cmake
ndk_base_dir=$sdk_dir/ndk
jdk_dir=$install_dir/jdk
log_file="$install_dir/error_modz_install.log"

# --- Global Variables ---
ndk_dir=""
ndk_ver=""
ndk_ver_name=""
ndk_file_name=""
is_lzhiyong_ndk=false
is_bionic_ndk=false
start_time=$(date +%s)

# --- Trap Interrupt (Ctrl+C) ---
trap 'echo -e "\n${RED}[✗] Process Interrupted by User! Cleaning up...${NC}"; tput cnorm 2>/dev/null; exit 1' SIGINT SIGTERM

# --- Advanced UI & Spinner Functions ---
get_term_width() {
    tput cols 2>/dev/null || echo 50
}

draw_line() {
    local width=$(get_term_width)
    local char="━"
    echo -e "${BLUE}"
    printf "%0.s${char}" $(seq 1 $width)
    echo -e "${NC}"
}

center_text() {
    local text="$1"
    local color="$2"
    local width=$(get_term_width)
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g")
    local text_len=${#plain_text}
    local pad=$(( (width - text_len) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    printf "%${pad}s" ""
    echo -e "${color}${text}${NC}"
}

# Advanced Animated Spinner (No Emojis)
spin_loader() {
    local pid=$1
    local msg=$2
    local spinstr='|/-\'
    
    if command -v tput &> /dev/null; then tput civis; fi # Hide cursor
    
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN} [%c] ${YELLOW}${msg}${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done
    printf "\r${GREEN} [✓] ${msg} - Completed!    ${NC}\n"
    
    if command -v tput &> /dev/null; then tput cnorm; fi # Show cursor
}

show_banner() {
    clear
    draw_line
    echo ""
    center_text "╔════════════════════════════════════╗" "${RED}"
    center_text "║          ★ ERROR MODZ ★          ║" "${RED}"
    center_text "║   COMPLETE DEVELOPER SUITE V6.0    ║" "${RED}"
    center_text "╚════════════════════════════════════╝" "${RED}"
    echo ""
    center_text "► AUTO GIT | SSH | JDK | SDK | NDK ◄" "${CYAN}"
    center_text "► DEVELOPED BY ERROR MODZ ◄" "${PURPLE}"
    echo ""
    draw_line
    echo ""
}

# --- Logging & UI Output ---
write_log() { echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" >> "$log_file"; }
log_info() { echo -e "${CYAN}[i] $1${NC}"; write_log "[INFO] $1"; }
log_success() { echo -e "${GREEN}[✓] $1${NC}"; write_log "[SUCCESS] $1"; }
log_warn() { echo -e "${YELLOW}[!] $1${NC}"; write_log "[WARN] $1"; }
log_error() { echo -e "${RED}[✗] $1${NC}"; write_log "[ERROR] $1"; }

# --- System Intelligence Checks ---
check_system() {
    log_info "Initializing System Checks..."
    echo "--- ERROR MODZ INSTALL LOG ---" > "$log_file"

    local arch=$(uname -m)
    if [[ "$arch" != "aarch64" ]]; then
        log_warn "Architecture: '$arch'. Tool is optimized for 'aarch64'."
        sleep 2
    else
        log_success "Architecture: aarch64 (Compatible)"
    fi

    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No Internet Connection detected!"
        exit 1
    else
        log_success "Network: Online"
    fi

    local free_space=$(df -k "$HOME" | tail -n 1 | awk '{print $4}')
    if [[ "$free_space" -lt 2000000 ]]; then
        log_warn "Low Storage Space! Minimum 2GB+ recommended."
        sleep 2
    else
        log_success "Storage Space: Sufficient"
    fi
}

# --- Auto Dependency & Core Tools Installer ---
check_dependencies() {
    log_info "Checking & Auto-Installing Core Dependencies..."
    for cmd in wget unzip tar tput ncurses-utils bc default-jre; do
        if ! command -v $cmd &> /dev/null; then
            ( pkg install $cmd ncurses-utils -y &> /dev/null || apt-get install $cmd ncurses-bin -y &> /dev/null ) &
            spin_loader $! "Installing Base Package: $cmd"
        fi
    done
}

auto_install_dev_tools() {
    log_info "Checking Developer Tools (Git & OpenSSH)..."
    
    # Check and Auto-Install Git
    if ! command -v git &> /dev/null; then
        ( pkg install git -y &> /dev/null || apt-get install git -y &> /dev/null ) &
        spin_loader $! "Auto-Installing Git"
        write_log "Git installed automatically."
    else
        log_success "Git is already installed."
    fi

    # Check and Auto-Install OpenSSH
    if ! command -v ssh &> /dev/null; then
        ( pkg install openssh -y &> /dev/null || apt-get install openssh -y &> /dev/null ) &
        spin_loader $! "Auto-Installing OpenSSH"
        write_log "OpenSSH installed automatically."
    else
        log_success "OpenSSH is already installed."
    fi
    echo ""
}

# --- Advanced Download Styling (No Emojis) ---
download_file() {
    local file_name=$1
    local download_url=$2
    local title=$3
    
    echo ""
    echo -e "${CYAN} ╔═════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN} ║ ${GREEN}▶ INITIATING SECURE DOWNLOAD${NC}                                ║"
    echo -e "${CYAN} ╠═════════════════════════════════════════════════════════════╣${NC}"
    echo -e "${CYAN} ║ ${YELLOW}◎ TARGET : ${NC}${title}"
    echo -e "${CYAN} ║ ${YELLOW}▣ FILE   : ${NC}${file_name}"
    echo -e "${CYAN} ╚═════════════════════════════════════════════════════════════╝${NC}"
    echo -e "${PURPLE} ▼ LIVE PROGRESS: ${NC}"
    echo ""
    
    wget -q --show-progress "$download_url" -O "$file_name"
    
    echo ""
    echo -e "${GREEN} ╰─➤ [✓] Asset Downloaded Successfully!${NC}"
    write_log "Downloaded: $file_name"
    echo ""
}

# ==============================================================================
# MODULE 1: NDK & CMAKE INSTALLATION
# ==============================================================================
run_install_cmake() {
    log_info "Initializing CMake installations..."
    for cv in "3.10.2" "3.18.1" "3.22.1" "3.25.1"; do
        local url="https://github.com/MrIkso/AndroidIDE-NDK/releases/download/cmake/cmake-${cv}-android-aarch64.zip"
        download_file "cmake-${cv}.zip" "$url" "CMake v${cv}"
        
        (
            unzip -qq "cmake-${cv}.zip" -d "$cmake_dir"
            rm "cmake-${cv}.zip"
            chmod -R +x "$cmake_dir/$cv/bin"
        ) & spin_loader $! "Extracting CMake ${cv}"
    done
}

fix_ndk_links() {
    local target_dir="$1"
    local link_from="$2"
    local link_to="$3"
    (
        cd "$target_dir"/toolchains/llvm/prebuilt || exit
        ln -sf "$link_from" "$link_to"
        cd "$target_dir"/prebuilt || exit
        ln -sf "$link_from" "$link_to"
        if [ -d "$target_dir/shader-tools" ]; then
            cd "$target_dir/shader-tools" || exit
            ln -sf "$link_from" "$link_to"
        fi
        cd "$install_dir" || exit
    ) & spin_loader $! "Creating System Symlinks"
}

module_ndk() {
    echo -e "${CYAN}Select NDK version to install:${NC}"
    PS3=$(echo -e "\n${RED}➜ ${YELLOW}ERROR MODZ > Select NDK: ${NC}")
    options=("r17c" "r18b" "r19c" "r20b" "r21e" "r22b" "r23b" "r24" "r26b" "r27b" "r27d" "r28c" "r29" "Cancel")
    
    select item in "${options[@]}"; do
        case $item in
            "r17c"|"r18b"|"r19c"|"r20b"|"r21e"|"r22b"|"r23b"|"r24")
                ndk_ver_name=$item; is_lzhiyong_ndk=false; break ;;
            "r26b"|"r27b") 
                ndk_ver_name=$item; is_lzhiyong_ndk=true; break ;;
            "r27d"|"r28c"|"r29") 
                ndk_ver_name=$item; is_bionic_ndk=true; break ;;
            "Cancel") return ;;
            *) log_error "Invalid selection." ;;
        esac
    done

    # File naming and URL logic
    if [[ $is_bionic_ndk == true ]]; then
        ndk_file_name="android-ndk-$ndk_ver_name-aarch64-linux-android.tar.xz"
        tag_name="${ndk_ver_name:0:3}" # e.g., r27d -> r27
        url="https://github.com/HomuHomu833/android-ndk-custom/releases/download/$tag_name/$ndk_file_name"
    elif [[ $is_lzhiyong_ndk == true ]]; then
        ndk_file_name="android-ndk-$ndk_ver_name-aarch64.zip"
        url="https://github.com/MrIkso/AndroidIDE-NDK/releases/download/ndk/$ndk_file_name"
    else
        ndk_file_name="android-ndk-$ndk_ver_name-aarch64.zip"
        url="https://github.com/jzinferno2/termux-ndk/releases/download/v1/$ndk_file_name"
    fi

    # Cleanup Old
    ndk_dir="$ndk_base_dir/android-ndk-$ndk_ver_name"
    if [ -d "$ndk_dir" ]; then
        ( rm -rf "$ndk_dir" ) & spin_loader $! "Removing old NDK files"
    fi

    # Download & Extract
    download_file "$ndk_file_name" "$url" "Android NDK ($ndk_ver_name)"
    
    if [ -f "$ndk_file_name" ]; then
        mkdir -p "$ndk_base_dir"
        if [[ $is_bionic_ndk == true ]]; then
            ( tar --no-same-owner -xf "$ndk_file_name" -C "$ndk_base_dir" --warning=no-unknown-keyword ) & spin_loader $! "Extracting NDK (Tar)"
            fix_ndk_links "$ndk_dir" "linux-arm64" "linux-aarch64"
        else
            ( unzip -qq "$ndk_file_name" -d "$ndk_base_dir" ) & spin_loader $! "Extracting NDK (Zip)"
            if [[ $is_lzhiyong_ndk == false ]]; then
                fix_ndk_links "$ndk_dir" "linux-aarch64" "linux-x86_64"
                sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android-legacy.toolchain.cmake
                sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android.toolchain.cmake
            fi
        fi
        rm "$ndk_file_name"
    fi

    if [ ! -d "$cmake_dir" ]; then mkdir -p "$cmake_dir"; fi
    cd "$cmake_dir" || exit
    run_install_cmake
    cd "$install_dir" || exit

    log_success "NDK & CMake Installation Finished."
}

# ==============================================================================
# MODULE 2: JDK INSTALLATION (Adoptium API)
# ==============================================================================
module_jdk() {
    echo -e "${CYAN}Select Original OpenJDK Version:${NC}"
    PS3=$(echo -e "\n${RED}➜ ${YELLOW}ERROR MODZ > Select JDK: ${NC}")
    jdk_opts=("JDK 11 (LTS)" "JDK 17 (LTS)" "JDK 21 (LTS)" "Cancel")
    
    local j_ver=""
    select opt in "${jdk_opts[@]}"; do
        case $opt in
            "JDK 11 (LTS)") j_ver="11"; break ;;
            "JDK 17 (LTS)") j_ver="17"; break ;;
            "JDK 21 (LTS)") j_ver="21"; break ;;
            "Cancel") return ;;
            *) log_error "Invalid selection." ;;
        esac
    done

    local jdk_url="https://api.adoptium.net/v3/binary/latest/${j_ver}/ga/linux/aarch64/jdk/hotspot/normal/eclipse?project=jdk"
    local jdk_file="jdk-${j_ver}.tar.gz"
    
    # Cleanup old JDK folder if exists to prevent mixups
    if [ -d "$jdk_dir" ]; then
        ( rm -rf "$jdk_dir" ) & spin_loader $! "Cleaning old JDK configuration"
    fi

    download_file "$jdk_file" "$jdk_url" "Official OpenJDK ${j_ver}"
    
    mkdir -p "$jdk_dir"
    ( tar -xf "$jdk_file" -C "$jdk_dir" --strip-components=1 ) & spin_loader $! "Extracting Java Runtime"
    rm "$jdk_file"

    log_success "JDK $j_ver Installation Finished at $jdk_dir"
}

# ==============================================================================
# MODULE 3: ANDROID SDK INSTALLATION
# ==============================================================================
module_sdk() {
    echo -e "${CYAN}Select Android API Level to Install/Update:${NC}"
    PS3=$(echo -e "\n${RED}➜ ${YELLOW}ERROR MODZ > Select API: ${NC}")
    sdk_opts=("API 30 (Android 11)" "API 31 (Android 12)" "API 33 (Android 13)" "API 34 (Android 14)" "API 35 (Android 15)" "Cancel")
    
    local api_ver=""
    select opt in "${sdk_opts[@]}"; do
        case $opt in
            "API 30"*) api_ver="30"; break ;;
            "API 31"*) api_ver="31"; break ;;
            "API 33"*) api_ver="33"; break ;;
            "API 34"*) api_ver="34"; break ;;
            "API 35"*) api_ver="35"; break ;;
            "Cancel") return ;;
            *) log_error "Invalid selection." ;;
        esac
    done

    # Ensure cmdline-tools exists
    local cmdline_dir="$sdk_dir/cmdline-tools/latest/bin"
    if [ ! -f "$cmdline_dir/sdkmanager" ]; then
        log_info "Android SDK Command Line Tools missing. Fetching..."
        local sdk_url="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
        download_file "cmdline-tools.zip" "$sdk_url" "Android SDK Base Tools"
        
        mkdir -p "$sdk_dir/cmdline-tools"
        ( unzip -qq cmdline-tools.zip -d "$sdk_dir/cmdline-tools" ) & spin_loader $! "Extracting SDK Tools"
        rm cmdline-tools.zip
        
        # Structure adjustment for sdkmanager to work properly
        mv "$sdk_dir/cmdline-tools/cmdline-tools" "$sdk_dir/cmdline-tools/latest"
    fi

    log_info "Accepting SDK Licenses..."
    yes | "$cmdline_dir/sdkmanager" --licenses > /dev/null 2>&1

    log_info "Downloading Platforms & Build-Tools for API $api_ver (Please wait)..."
    "$cmdline_dir/sdkmanager" "platforms;android-$api_ver" "build-tools;$api_ver.0.0" "platform-tools" | grep -v "="

    log_success "Android SDK API $api_ver Setup Finished."
}

# ==============================================================================
# MAIN EXECUTION MENU
# ==============================================================================
show_banner
check_system
echo ""
check_dependencies
auto_install_dev_tools

while true; do
    echo -e "${CYAN} ╔════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN} ║        ${YELLOW}◈ MASTER INSTALLATION MENU ◈${CYAN}        ║${NC}"
    echo -e "${CYAN} ╚════════════════════════════════════════════╝${NC}"
    
    PS3=$(echo -e "\n${RED}➜ ${YELLOW}ERROR MODZ > Select Module (1-4): ${NC}")
    master_opts=("Install NDK & CMake" "Install Java JDK (Official)" "Install Android SDK & API" "Exit Installer")
    
    select m_opt in "${master_opts[@]}"; do
        case $m_opt in
            "Install NDK & CMake")
                module_ndk; break ;;
            "Install Java JDK (Official)")
                module_jdk; break ;;
            "Install Android SDK & API")
                module_sdk; break ;;
            "Exit Installer")
                echo ""
                draw_line
                center_text "[✓] ALL TASKS COMPLETED [✓]" "${GREEN}"
                echo -e "${CYAN} ◈ Log File Saved : ${YELLOW}${log_file}${NC}"
                echo -e "${CYAN} ◈ Developer      : ${YELLOW}ERROR MODZ${NC}"
                echo ""
                center_text "Please RESTART AndroidIDE to apply changes." "${PURPLE}"
                draw_line
                
                # Auto Exit Feature
                echo -e "\n${CYAN}[i] Auto-exiting in 3 seconds...${NC}"
                sleep 1; echo -e "${CYAN}[i] Auto-exiting in 2 seconds...${NC}"
                sleep 1; echo -e "${CYAN}[i] Auto-exiting in 1 second...${NC}"
                sleep 1; echo -e "${GREEN}[✓] Goodbye!${NC}"
                exit 0
                ;;
            *)
                log_error "Invalid selection. Please enter 1-4." ;;
        esac
    done
    echo ""
done
}

draw_line() {
    local width=$(get_term_width)
    local char="━"
    echo -e "${BLUE}"
    printf "%0.s${char}" $(seq 1 $width)
    echo -e "${NC}"
}

center_text() {
    local text="$1"
    local color="$2"
    local width=$(get_term_width)
    
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g")
    local text_len=${#plain_text}
    
    local pad=$(( (width - text_len) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    
    printf "%${pad}s" ""
    echo -e "${color}${text}${NC}"
}

# Advanced Animated Spinner
spin_loader() {
    local pid=$1
    local msg=$2
    local spinstr='⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏'
    tput civis # Hide cursor
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r${CYAN} [%c] ${YELLOW}${msg}${NC}" "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep 0.1
    done
    printf "\r${GREEN} [✔] ${msg} - Completed!    ${NC}\n"
    tput cnorm # Show cursor
}

show_banner() {
    clear
    draw_line
    echo ""
    center_text "╔════════════════════════════════════╗" "${RED}"
    center_text "║          🔥 ERROR MODZ 🔥          ║" "${RED}"
    center_text "║    ULTRA PRO NDK INSTALLER V2.0    ║" "${RED}"
    center_text "╚════════════════════════════════════╝" "${RED}"
    echo ""
    center_text "► ADVANCED DOWNLOAD ENGINE ◄" "${CYAN}"
    center_text "► DEVELOPED BY ERROR MODZ ◄" "${PURPLE}"
    echo ""
    draw_line
    echo ""
}

# --- Logging Functions ---
log_info() { echo -e "${CYAN}[*] $1${NC}"; }
log_success() { echo -e "${GREEN}[+] $1${NC}"; }
log_warn() { echo -e "${YELLOW}[!] $1${NC}"; }
log_error() { echo -e "${RED}[x] $1${NC}"; }

# --- Dependency Check ---
check_dependencies() {
    log_info "Checking required packages..."
    for cmd in wget unzip tar tput ncurses-utils; do
        if ! command -v $cmd &> /dev/null; then
            log_warn "$cmd is missing. Installing in background..."
            (pkg install $cmd -y &> /dev/null || apt-get install $cmd -y &> /dev/null) &
            spin_loader $! "Installing $cmd"
        fi
    done
    log_success "System is ready!\n"
}

run_install_cmake() {
    log_info "Initializing CMake installations..."
    download_cmake 3.10.2
    download_cmake 3.18.1
    download_cmake 3.22.1
    download_cmake 3.25.1
}

# --- Advanced Download Styling ---
download_file() {
    local file_name=$1
    local download_url=$2
    local title=$3
    
    echo ""
    echo -e "${PURPLE} ╭───────────────────────────────────────────────────╮${NC}"
    echo -e "${PURPLE} │ ${CYAN}⬇️  DOWNLOADING: ${YELLOW}${title}${NC}"
    echo -e "${PURPLE} │ ${CYAN}📦 FILE: ${YELLOW}${file_name}${NC}"
    echo -e "${PURPLE} ╰───────────────────────────────────────────────────╯${NC}"
    
    # Using wget with custom progress bar layout
    wget -q --show-progress "$download_url" -N
    echo ""
}

download_cmake() {
    local cmake_version=$1
    local file="cmake-${cmake_version}-android-aarch64.zip"
    local url="https://github.com/MrIkso/AndroidIDE-NDK/releases/download/cmake/${file}"
    
    download_file "$file" "$url" "CMake v${cmake_version}"
    installing_cmake "$cmake_version"
}

download_ndk() {
    local file=$1
    local url=$2
    download_file "$file" "$url" "Android NDK ($ndk_ver_name)"
}

fix_ndk() {
    if [ -d "$ndk_dir" ]; then
        log_info "Creating missing system links & Patching CMake configs..."
        (
            cd "$ndk_dir"/toolchains/llvm/prebuilt || exit
            ln -sf linux-aarch64 linux-x86_64
            cd "$ndk_dir"/prebuilt || exit
            ln -sf linux-aarch64 linux-x86_64
            cd "$install_dir" || exit

            sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android-legacy.toolchain.cmake
            sed -i 's/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/if(CMAKE_HOST_SYSTEM_NAME STREQUAL Android)\nset(ANDROID_HOST_TAG linux-aarch64)\nelseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux)/g' "$ndk_dir"/build/cmake/android.toolchain.cmake
        ) &
        spin_loader $! "Applying ERROR MODZ Patches"
        
        ndk_installed=true
    else
        log_error "NDK directory does not exist. Patching failed."
    fi
}

fix_ndk_bionic() {
    if [ -d "$ndk_dir" ]; then
        log_info "Applying Bionic System patches..."
        (
            cd "$ndk_dir"/toolchains/llvm/prebuilt || exit
            ln -sf linux-arm64 linux-aarch64
            cd "$ndk_dir"/prebuilt || exit
            ln -sf linux-arm64 linux-aarch64
            cd "$ndk_dir"/shader-tools || exit
            ln -sf linux-arm64 linux-aarch64 
        ) &
        spin_loader $! "Creating Bionic Symlinks"
        
        ndk_installed=true
    else
        log_error "NDK directory does not exist. Patching failed."
    fi
}

installing_cmake() {
    local cmake_version=$1
    local cmake_file=cmake-"$cmake_version"-android-aarch64.zip
    
    if [ -f "$cmake_file" ]; then
        (
            unzip -qq "$cmake_file" -d "$cmake_dir"
            rm "$cmake_file"
            chmod -R +x "$cmake_dir"/"$cmake_version"/bin
        ) &
        spin_loader $! "Extracting CMake ${cmake_version}"
        
        cmake_installed=true
    else
        log_error "$cmake_file not found."
    fi
}

# --- Main Execution ---
show_banner
check_dependencies

echo -e "${CYAN}Please select the NDK version you want to install:${NC}"
PS3=$(echo -e "\n${RED}➜ ${YELLOW}ERROR MODZ > Select an option: ${NC}")

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
        "Quit") log_warn "Exiting ERROR MODZ Installer..."; exit 0 ;;
        *) log_error "Invalid selection. Please try again." ;;
    esac
done

echo ""
log_success "Target Version : $ndk_ver_name ($ndk_ver)"
log_warn "Optimized strictly for AARCH64 architectures."
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
    ( rm -rf "$ndk_dir" ) &
    spin_loader $! "Removing old NDK $ndk_ver files"
fi

# Cleanup old CMake
for cmake_v in "3.10.2" "3.18.1" "3.22.1" "3.25.1"; do
    if [ -d "$cmake_dir/$cmake_v" ]; then
        ( rm -rf "$cmake_dir/$cmake_v" ) &
        spin_loader $! "Cleaning old CMake $cmake_v"
    fi
done

# Download logic
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
    if [[ $is_bionic_ndk == true ]]; then
        ( tar --no-same-owner -xf "$ndk_file_name" --warning=no-unknown-keyword ) &
        spin_loader $! "Extracting NDK $ndk_ver_name (Tar Archive)"
    else
        ( unzip -qq "$ndk_file_name" ) &
        spin_loader $! "Extracting NDK $ndk_ver_name (Zip Archive)"
    fi
    rm "$ndk_file_name"

    # Moving NDK to SDK Directory
    if [ ! -d "$ndk_base_dir" ]; then
        mkdir -p "$sdk_dir"/ndk
    fi
    
    ( mv android-ndk-"$ndk_ver_name" "$ndk_dir" ) &
    spin_loader $! "Moving NDK files to system directory"

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
draw_line
if [[ $ndk_installed == true && $cmake_installed == true ]]; then
    center_text "🎉 INSTALLATION COMPLETED SUCCESSFULLY! 🎉" "${GREEN}"
    echo ""
    echo -e "${CYAN} ➔ NDK Version    : ${YELLOW}${ndk_ver_name}${NC}"
    echo -e "${CYAN} ➔ CMake Versions : ${YELLOW}3.10.2, 3.18.1, 3.22.1, 3.25.1${NC}"
    echo -e "${CYAN} ➔ Developer      : ${YELLOW}ERROR MODZ${NC}"
    echo ""
    center_text "Please RESTART AndroidIDE to apply changes." "${PURPLE}"
else
    center_text "❌ INSTALLATION FAILED! ❌" "${RED}"
    echo -e "${YELLOW}[!] An error occurred during the installation process.${NC}"
fi
draw_line
echo ""

# Auto Exit Feature
echo -e "${CYAN}[*] Auto-exiting in 3 seconds...${NC}"
sleep 1
echo -e "${CYAN}[*] Auto-exiting in 2 seconds...${NC}"
sleep 1
echo -e "${CYAN}[*] Auto-exiting in 1 second...${NC}"
sleep 1
echo -e "${GREEN}[✔] Goodbye!${NC}"
exit 0
}

draw_line() {
    local width=$(get_term_width)
    local char="="
    echo -e "${YELLOW}"
    printf "%0.s${char}" $(seq 1 $width)
    echo -e "${NC}"
}

center_text() {
    local text="$1"
    local color="$2"
    local width=$(get_term_width)
    
    # Strip color codes for length calculation (basic approach)
    local plain_text=$(echo -e "$text" | sed -r "s/\x1B\[[0-9;]*[a-zA-Z]//g")
    local text_len=${#plain_text}
    
    local pad=$(( (width - text_len) / 2 ))
    [[ $pad -lt 0 ]] && pad=0
    
    printf "%${pad}s" ""
    echo -e "${color}${text}${NC}"
}

show_banner() {
    clear
    draw_line
    echo ""
    center_text "╔════════════════════════════════════╗" "${RED}"
    center_text "║            ERROR MODZ              ║" "${RED}"
    center_text "║        PRO NDK INSTALLER           ║" "${RED}"
    center_text "╚════════════════════════════════════╝" "${RED}"
    echo ""
    center_text "► AUTO-FIT RESPONSIVE UI ◄" "${CYAN}"
    center_text "► DEVELOPED BY ERROR MODZ ◄" "${PURPLE}"
    echo ""
    draw_line
    echo ""
}

# --- Logging Functions ---
log_info() { echo -e "${CYAN}[*] $1${NC}"; }
log_success() { echo -e "${GREEN}[+] $1${NC}"; }
log_warn() { echo -e "${YELLOW}[!] $1${NC}"; }
log_error() { echo -e "${RED}[x] $1${NC}"; }

# --- Dependency Check ---
check_dependencies() {
    log_info "Checking required packages..."
    for cmd in wget unzip tar tput; do
        if ! command -v $cmd &> /dev/null; then
            log_warn "$cmd is missing. Installing..."
            pkg install $cmd ncurses-utils -y &> /dev/null || apt-get install $cmd ncurses-bin -y &> /dev/null
        fi
    done
    log_success "System is ready!\n"
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
    log_info "Downloading CMake v${cmake_version}..."
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
PS3=$(echo -e "\n${YELLOW}ERROR MODZ > Select an option: ${NC}")

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

# Download logic
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
draw_line
if [[ $ndk_installed == true && $cmake_installed == true ]]; then
    center_text "[✔] ERROR MODZ INSTALLATION SUCCESSFUL!" "${GREEN}"
    echo -e "${CYAN}[*] NDK and CMake have been installed properly.${NC}"
    echo -e "${PURPLE}[*] Please RESTART AndroidIDE to apply all changes.${NC}"
else
    center_text "[x] INSTALLATION FAILED!" "${RED}"
    echo -e "${YELLOW}[!] Something went wrong during NDK or CMake installation.${NC}"
fi
draw_line
echo ""
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
