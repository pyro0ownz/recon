#!/bin/bash

# List of dependencies to check and install if necessary
dependencies=("gobuster" "nmap" "ffuf")

# Function to check each dependency
check_and_install_dependency() {
    if dpkg -l | grep "^ii" | grep -qw $1; then
        echo "Dependency $1 is already installed."
    else
        echo "Dependency $1 is NOT installed. Attempting to install..."
        sudo apt-get install -y $1

        # Check if installation was successful
        if dpkg -l | grep "^ii" | grep -qw $1; then
            echo "Successfully installed $1."
        else
            echo "Failed to install $1."
        fi
    fi
}

# Update package lists before starting
echo "Updating package lists..."
sudo apt-get update

# Loop through dependencies and check each one
for dep in "${dependencies[@]}"; do
    check_and_install_dependency $dep
done
SetVars() {
    export ip="$ip"
    export box="$box"
    echo "$ip $box.htb" | sudo tee --append /etc/hosts
    if [ -d "~/htb/$box" ]; then
        echo "$box exists on your filesystem."
    else
        echo "$box Does not exist. Creating Directory."
        mkdir -p "~/htb/$box" && cd "~/htb/$box" || exit
    fi
}

Recon() {
    echo "Opening them terms nmap commin up"
    lxterminal -e "bash -c 'nmap $ip -Pn -sV -sT -A -p 1-65535 -oA $box; exec bash'" &
    echo "opening the fuffs directory search"
    lxterminal -e "bash -c 'ffuf -w /usr/share/seclists/Discovery/Web-Content/raft-small-directories.txt -u http://$box.htb/FUZZ -o ${box}_directories.csv -of csv; exec bash'" &
    echo "da fuffs dns"
    lxterminal -e "bash -c 'ffuf -w /usr/share/seclists/Discovery/DNS/namelist.txt -u http://$box.htb/ -H \"Host: FUZZ.$box.htb\" -o ${box}_dns.csv -of csv; exec bash'" &
}

echo "what is the box ip?"
read -r ip
echo "what is the box name"
read -r box

SetVars
Recon
