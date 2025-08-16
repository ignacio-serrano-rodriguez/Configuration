# -- USER --

# Colors - Expandida con más colores
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
ORANGE=$(tput setaf 202)

# Modifiers
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
DIM=$(tput dim)

# Función para mostrar estado de Git
git_status() {
    local git_status=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null || echo "detached")
        local status=""
        
        # Verificar cambios
        if ! git diff --quiet 2>/dev/null; then
            status="${status}${YELLOW}●${NORMAL}" # Archivos modificados
        fi
        if ! git diff --cached --quiet 2>/dev/null; then
            status="${status}${GREEN}●${NORMAL}" # Archivos en stage
        fi
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            status="${status}${RED}●${NORMAL}" # Archivos sin seguimiento
        fi
        
        git_status=" ${BRIGHT}${MAGENTA}[${branch}${status}${BRIGHT}${MAGENTA}]${NORMAL}"
    fi
    echo "$git_status"
}

# Función para mostrar código de salida del último comando
last_command_status() {
    if [ $? -eq 0 ]; then
        echo "${BRIGHT}${GREEN}✓${NORMAL}"
    else
        echo "${BRIGHT}${RED}✗${NORMAL}"
    fi
}

# Función para mostrar carga del sistema
system_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local load_int=$(echo "$load" | cut -d'.' -f1)
    
    if [ "$load_int" -lt 2 ]; then
        echo "${BRIGHT}${GREEN}⚡${NORMAL}"
    elif [ "$load_int" -lt 5 ]; then
        echo "${BRIGHT}${YELLOW}⚡${NORMAL}"
    else
        echo "${BRIGHT}${RED}⚡${NORMAL}"
    fi
}

# Función para mostrar tiempo
show_time() {
    echo "${DIM}${WHITE}$(date +'%H:%M:%S')${NORMAL}"
}

# Función para path abreviado
short_pwd() {
    local pwd_length=30
    local pwd=$(pwd)
    local home_dir="$HOME"
    
    # Reemplazar HOME con ~
    pwd=${pwd/#$home_dir/\~}
    
    # Si es muy largo, abreviar
    if [ ${#pwd} -gt $pwd_length ]; then
        echo "...${pwd: -$((pwd_length-3))}"
    else
        echo "$pwd"
    fi
}

# Prompt personalizado con información avanzada
PS1='$(show_time) $(last_command_status) $(system_load) \[${BRIGHT}\]\[${GREEN}\]\u\[${NORMAL}\]@\[${BRIGHT}\]\[${CYAN}\]\H\[${NORMAL}\] \[${BRIGHT}\]\[${BLUE}\]$(short_pwd)\[${NORMAL}\]$(git_status)\n\[${BRIGHT}\]\[${WHITE}\]❯\[${NORMAL}\] '

info() {
    # Script que combina varios comandos para información completa
    echo -e "\033[1;35m=== DISTRIBUCIÓN Y KERNEL ===\033[0m" && \
    echo -e "\033[1;32mDistribución:\033[0m" && lsb_release -d 2>/dev/null || grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d "\"" && \
    echo -e "\033[1;32mUbuntu Release:\033[0m" && lsb_release -r 2>/dev/null | cut -f2 && \
    echo -e "\033[1;32mCodename:\033[0m" && lsb_release -c 2>/dev/null | cut -f2 && \
    echo -e "\033[1;32mDebian Base:\033[0m" && \
    ubuntu_version=$(lsb_release -r 2>/dev/null | cut -f2) && \
    case "$ubuntu_version" in \
        "24.04") echo "Debian 12 (Bookworm)" ;; \
        "23.10") echo "Debian 12 (Bookworm)" ;; \
        "23.04") echo "Debian 12 (Bookworm)" ;; \
        "22.10") echo "Debian 11 (Bullseye)" ;; \
        "22.04") echo "Debian 11 (Bullseye)" ;; \
        "21.10") echo "Debian 11 (Bullseye)" ;; \
        "21.04") echo "Debian 11 (Bullseye)" ;; \
        "20.10") echo "Debian 10 (Buster)" ;; \
        "20.04") echo "Debian 10 (Buster)" ;; \
        "19.10") echo "Debian 10 (Buster)" ;; \
        "19.04") echo "Debian 10 (Buster)" ;; \
        "18.10") echo "Debian 9 (Stretch)" ;; \
        "18.04") echo "Debian 9 (Stretch)" ;; \
        "17.10") echo "Debian 9 (Stretch)" ;; \
        "17.04") echo "Debian 9 (Stretch)" ;; \
        "16.10") echo "Debian 8 (Jessie)" ;; \
        "16.04") echo "Debian 8 (Jessie)" ;; \
        *) echo "Desconocido para Ubuntu $ubuntu_version" ;; \
    esac && \
    echo -e "\033[1;32mKernel:\033[0m" && uname -r && \
    echo -e "\033[1;32mArquitectura:\033[0m" && uname -m && \
    echo -e "\033[1;32mUptime:\033[0m" && uptime -p 2>/dev/null || uptime && echo && \
    echo -e "\033[1;34m=== DISPLAY SERVER ===\033[0m" && \
    echo -e "\033[1;32mDisplay Server:\033[0m" && \
    if [ -n "$WAYLAND_DISPLAY" ]; then echo "Wayland (Session: $XDG_SESSION_TYPE)"; \
    elif [ -n "$DISPLAY" ]; then echo "X11/Xorg (Session: $XDG_SESSION_TYPE)"; \
    else echo "No detectado o TTY"; fi && \
    echo -e "\033[1;32mCompositor/WM:\033[0m" && echo "$XDG_CURRENT_DESKTOP" && \
    echo -e "\033[1;32mSesión:\033[0m" && echo "$XDG_SESSION_DESKTOP" && echo && \
    echo -e "\033[1;36m=== VIRTUALIZACIÓN ===\033[0m" && \
    if command -v systemd-detect-virt >/dev/null 2>&1; then \
      virt=$(systemd-detect-virt 2>/dev/null); \
      if [ "$virt" != "none" ]; then echo "Virtualización: $virt"; else echo "Sistema físico"; fi; \
    else echo "Detección no disponible"; fi && echo && \
    echo -e "\033[1;32m=== BATERÍA ===\033[0m" && \
    if [ -d "/sys/class/power_supply" ]; then \
      for bat in /sys/class/power_supply/BAT*; do \
        if [ -d "$bat" ]; then \
          echo "Batería: $(cat $bat/capacity 2>/dev/null)% - Estado: $(cat $bat/status 2>/dev/null)"; \
        fi; \
      done; \
    else echo "No se detectó batería"; fi && echo && \
    echo -e "\033[1;31m=== TEMPERATURA ===\033[0m" && \
    echo -e "\033[1;33mTemperatura del sistema:\033[0m" && \
    temp_count=0 && \
    for temp_file in /sys/class/thermal/thermal_zone*/temp; do \
      if [ -r "$temp_file" ]; then \
        temp=$(cat "$temp_file" 2>/dev/null) && \
        temp_celsius=$((temp/1000)) && \
        zone_type=$(cat "$(dirname "$temp_file")/type" 2>/dev/null || echo "Zona_$temp_count") && \
        if [ "$temp_celsius" -gt 0 ]; then \
          if [ "$temp_celsius" -lt 60 ]; then color="\033[1;32m"; \
          elif [ "$temp_celsius" -lt 80 ]; then color="\033[1;33m"; \
          else color="\033[1;31m"; fi && \
          echo -e "  $zone_type: ${color}${temp_celsius}°C\033[0m" && \
          temp_count=$((temp_count + 1)); \
        fi; \
      fi; \
      [ "$temp_count" -ge 5 ] && break; \
    done && \
    if command -v sensors >/dev/null 2>&1; then \
      echo -e "\033[1;33mSensores adicionales:\033[0m" && \
      sensors 2>/dev/null | grep -E "Core [0-9]+:|Package id|temp[0-9]+:" | head -6 | sed 's/^/  /'; \
    else echo "  sensors no disponible (sudo apt install lm-sensors)"; \
    fi && echo && \
    echo -e "\033[1;33m=== AUDIO ===\033[0m" && \
    echo "Tarjetas de audio:" && \
    cat /proc/asound/cards 2>/dev/null && echo && \
    echo -e "\033[1;31m=== PUERTOS ABIERTOS ===\033[0m" && \
    echo -e "\033[1;33mPuertos TCP en escucha:\033[0m" && \
    (ss -tlnp 2>/dev/null || netstat -tlnp 2>/dev/null) | head -15 && \
    echo -e "\033[1;33mPuertos UDP en escucha:\033[0m" && \
    (ss -ulnp 2>/dev/null || netstat -ulnp 2>/dev/null) | head -8 && echo && \
    echo -e "\033[1;34m=== CPU ===\033[0m" && lscpu --color=always 2>/dev/null || lscpu && echo && \
    echo -e "\033[1;35m=== GPU ===\033[0m" && \
    echo "Tarjetas gráficas:" && \
    lspci | grep -i "vga\|3d\|display" && \
    echo "Driver en uso:" && \
    lspci -nnk | grep -i "vga\|3d\|display" -A 3 | grep "driver in use" && \
    if command -v nvidia-smi >/dev/null 2>&1; then \
      echo "NVIDIA GPU:" && nvidia-smi --query-gpu=name,memory.total,memory.used,temperature.gpu --format=csv,noheader,nounits 2>/dev/null | head -3; \
    fi && \
    if command -v glxinfo >/dev/null 2>&1; then \
      echo "OpenGL:" && glxinfo | grep -E "OpenGL vendor|OpenGL renderer|OpenGL version" 2>/dev/null; \
    else echo "glxinfo no disponible (instalar: sudo apt install mesa-utils)"; fi && echo && \
    echo -e "\033[1;32m=== MEMORIA ===\033[0m" && free -h --color=always 2>/dev/null || free -h && echo && \
    echo -e "\033[1;33m=== DISCOS ===\033[0m" && lsblk --color=always 2>/dev/null || lsblk && \
    echo "Uso del disco:" && df -h / /home 2>/dev/null && echo && \
    echo -e "\033[1;36m=== RED ===\033[0m" && ip -c addr show && echo && \
    echo -e "\033[1;34m=== MÓDULOS KERNEL ===\033[0m" && \
    echo "Módulos gráficos:" && lsmod | grep -E "nvidia|i915" && \
    echo "Módulos de red:" && lsmod | grep -E "iwlwifi|rtl" && echo && \
    echo -e "\033[1;35m=== PCI ===\033[0m" && lspci -k --color=always 2>/dev/null || lspci && echo && \
    echo -e "\033[1;34m=== USB ===\033[0m" && lsusb --color=always 2>/dev/null || lsusb
}

# -- ROOT --

# Colors - Expandida con más colores para root
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 7)
ORANGE=$(tput setaf 202)

# Modifiers
BRIGHT=$(tput bold)
NORMAL=$(tput sgr0)
DIM=$(tput dim)
BLINK=$(tput blink)

# Función para mostrar estado de Git
git_status() {
    local git_status=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null || echo "detached")
        local status=""
        
        # Verificar cambios
        if ! git diff --quiet 2>/dev/null; then
            status="${status}${YELLOW}●${NORMAL}"
        fi
        if ! git diff --cached --quiet 2>/dev/null; then
            status="${status}${GREEN}●${NORMAL}"
        fi
        if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            status="${status}${RED}●${NORMAL}"
        fi
        
        git_status=" ${BRIGHT}${MAGENTA}[${branch}${status}${BRIGHT}${MAGENTA}]${NORMAL}"
    fi
    echo "$git_status"
}

# Función para mostrar código de salida del último comando
last_command_status() {
    if [ $? -eq 0 ]; then
        echo "${BRIGHT}${GREEN}✓${NORMAL}"
    else
        echo "${BRIGHT}${RED}✗${NORMAL}"
    fi
}

# Función para mostrar carga del sistema con más detalle para root
system_load() {
    local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
    local load_int=$(echo "$load" | cut -d'.' -f1)
    local users=$(who | wc -l)
    
    if [ "$load_int" -lt 2 ]; then
        echo "${BRIGHT}${GREEN}⚡${load}${NORMAL}"
    elif [ "$load_int" -lt 5 ]; then
        echo "${BRIGHT}${YELLOW}⚡${load}${NORMAL}"
    else
        echo "${BRIGHT}${RED}⚡${load}${NORMAL}"
    fi
}

# Función para mostrar tiempo
show_time() {
    echo "${DIM}${WHITE}$(date +'%H:%M:%S')${NORMAL}"
}

# Función para path abreviado
short_pwd() {
    local pwd_length=35
    local pwd=$(pwd)
    
    # Para root, no reemplazamos con ~ ya que /root es importante
    if [ ${#pwd} -gt $pwd_length ]; then
        echo "...${pwd: -$((pwd_length-3))}"
    else
        echo "$pwd"
    fi
}

# Función para mostrar advertencia de root
root_warning() {
    echo "${BRIGHT}${RED}⚠️ ROOT${NORMAL}"
}

# Función para mostrar información del sistema crítica
system_info() {
    local mem_usage=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2 * 100}')
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    local mem_color="${GREEN}"
    local disk_color="${GREEN}"
    
    if [ "$mem_usage" -gt 80 ]; then mem_color="${RED}"; elif [ "$mem_usage" -gt 60 ]; then mem_color="${YELLOW}"; fi
    if [ "$disk_usage" -gt 90 ]; then disk_color="${RED}"; elif [ "$disk_usage" -gt 80 ]; then disk_color="${YELLOW}"; fi
    
    echo "${mem_color}MEM:${mem_usage}%${NORMAL} ${disk_color}DISK:${disk_usage}%${NORMAL}"
}

# Prompt para ROOT con información crítica
PS1='$(show_time) $(last_command_status) $(system_load) $(system_info) $(root_warning)\n\[${BRIGHT}\]\[${RED}\]root\[${NORMAL}\]@\[${BRIGHT}\]\[${CYAN}\]\H\[${NORMAL}\] \[${BRIGHT}\]\[${BLUE}\]$(short_pwd)\[${NORMAL}\]$(git_status)\n\[${BRIGHT}\]\[${RED}\]#\[${NORMAL}\] '
