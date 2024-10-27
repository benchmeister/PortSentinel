#!/bin/bash

# Automated Vulnerability Assessment Script (Prototype)

# Function to check for root privileges
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo "This script must be run as root. Exiting..."
        exit 1
    fi
}

# Function to perform an nmap scan
scan_ports() {
    echo "Starting nmap scan on target: $1"
    nmap -Pn -p- $1 > nmap_scan.txt
    echo "Nmap scan complete. Results saved in nmap_scan.txt"
}

# Function to scan specific ports and run tools accordingly
analyze_ports() {
    echo "Analyzing open ports..."
    
    # Check for HTTP (port 80)
    if grep -q "80/tcp open" nmap_scan.txt; then
        echo "Port 80 (HTTP) is open. Running Nikto scan..."
        nikto -h $1 > nikto_scan.txt
        echo "Nikto scan complete. Results saved in nikto_scan.txt"
    fi
    
    # Check for FTP (port 21)
    if grep -q "21/tcp open" nmap_scan.txt; then
        echo "Port 21 (FTP) is open. Checking for vulnerabilities..."
        searchsploit ftp
    fi
    
    # Check for SSH (port 22)
    if grep -q "22/tcp open" nmap_scan.txt; then
        echo "Port 22 (SSH) is open. Verifying SSH version..."
        ssh_version=$(grep "22/tcp open" nmap_scan.txt | awk '{print $3}')
        echo "SSH version detected: $ssh_version"
        echo "Checking for exploits with Searchsploit..."
        searchsploit $ssh_version
    fi
}

# Main execution block
main() {
    check_root
    
    # Get the target IP from user input
    echo "Enter the target IP address:"
    read target_ip
    
    # Run port scanning
    scan_ports $target_ip
    
    # Analyze the open ports and decide which tools to run
    analyze_ports $target_ip
}

# Call the main function
main
