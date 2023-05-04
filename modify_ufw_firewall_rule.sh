#!/bin/bash

# Checking for sudo or root privileges
if [[ $(id -u) -ne 0 ]]; then
  echo "Error: This script requires sudo or root privileges to run."
  echo "Please run the script again with sudo or as root."
  exit 1
fi

# Function to perform the firewall action
perform_firewall_action() {
    action=$1

    if [ "$action" = "add" ]; then
        # Prompt for firewall rule details
        read -p "Enter the source address or subnet (leave blank for 'any'): " source_address
        if [ -z "$source_address" ]; then
            source_address="any"
        fi

        read -p "Enter the destination port ('any' for all ports): " destination_port
        if [ "$destination_port" = "any" ]; then
            destination_port="any"
        else
            # Validate if the destination port is a number
            if ! [[ "$destination_port" =~ ^[0-9]+$ ]]; then
                echo "Invalid destination port. Exiting script."
                exit 1
            fi
        fi

        read -p "Enter the protocol (tcp/udp): " protocol

        # Add the firewall rule
        ufw_rule="ufw allow from $source_address to any port $destination_port proto $protocol"
        sudo $ufw_rule

        echo "Firewall rule added successfully!"
    elif [ "$action" = "delete" ]; then
        # Display numbered UFW rules
        ufw status numbered

        # Prompt for rule number to delete
        read -p "Enter the rule number to delete: " rule_number

        # Delete the firewall rule
        ufw delete $rule_number

        echo "Firewall rule deleted successfully!"
    elif [ "$action" = "list" ]; then
        # Display numbered UFW rules
        ufw status numbered
    else
        echo "Invalid action. Exiting script."
        exit 1
    fi
}

# Check UFW status
ufw_status=$(ufw status | awk '/Status:/{print $2}')

if [ "$ufw_status" = "inactive" ]; then
    echo "UFW is currently disabled."
    read -p "Do you want to enable UFW and allow SSH from anywhere? (y/n): " enable_ufw

    if [ "$enable_ufw" = "y" ]; then
        # Allow SSH from anywhere
        ufw allow ssh

        # Enable UFW
        ufw enable
        echo "UFW has been enabled and SSH is allowed from anywhere."
    else
        echo "UFW remains disabled. Exiting script."
        exit 0
    fi
fi

# Initial action
read -p "Do you want to add a rule, delete a rule, or list the existing rules? (add/delete/list): " action
perform_firewall_action "$action"

# Prompt for another action
read -p "Do you want to perform another action? (y/n): " perform_again

if [ "$perform_again" = "n" ] && [ "$action" != "list" ]; then
    ufw status numbered
    exit 0
fi

while [ "$perform_again" = "y" ]; do
    read -p "Do you want to add a rule, delete a rule, or list the existing rules? (add/delete/list): " action
    perform_firewall_action "$action"

    if [ "$action" = "list" ]; then
        read -p "Do you want to perform another action? (y/n): " perform_again
        if [ "$perform_again" = "n" ]; then
            exit 0
        fi
    else
        read -p "Do you want to perform another action? (y/n): " perform_again
    fi
done

if [ "$perform_again" = "n" ] && [ "$action" != "list" ]; then
    ufw status numbered
fi
