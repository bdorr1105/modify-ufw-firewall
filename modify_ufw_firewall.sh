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
        echo
        read -p "Enter the source address or subnet (leave blank for 'any'): " source_address
        if [ -z "$source_address" ]; then
            source_address="any"
        fi

        echo
        read -p "Enter the destination port ('any' for all ports): " destination_port
        if [ "$destination_port" = "any" ]; then
            destination_port="any"
        else
            # Validate if the destination port is a number
            if ! [[ "$destination_port" =~ ^[0-9]+$ ]]; then
                echo "Invalid destination port. Returning back to the menu."
                return
            fi
        fi

        echo
        read -p "Enter the protocol (tcp/udp): " protocol
        echo
        read -p "Enter the action (allow/deny/reject): " rule_action

        # Add the firewall rule
        ufw_rule="ufw $rule_action from $source_address to any port $destination_port proto $protocol"
        sudo $ufw_rule
        add_status=$?
        if [ $add_status -eq 0 ]; then
            echo "Firewall rule added successfully!"
            echo
            read -p "Do you want to add another firewall rule? (y/n): " add_another
            if [ "$add_another" = "y" ]; then
                perform_firewall_action "add"
            fi
        else
            echo "Failed to add firewall rule. Please check the UFW configuration."
        fi
    elif [ "$action" = "delete" ]; then
        # Display numbered UFW rules
        ufw status numbered

        # Prompt for rule number to delete
        read -p "Enter the rule number to delete: " rule_number
        echo

        # Delete the firewall rule
        ufw delete $rule_number
        delete_status=$?
        if [ $delete_status -eq 0 ]; then
            echo "Firewall rule deleted successfully!"
            
            # Prompt to delete another rule
            echo
            read -p "Do you want to delete another firewall rule? (y/n): " delete_another
            echo
            
            if [ "$delete_another" = "y" ]; then
                perform_firewall_action "delete"
            fi
        else
            echo "Failed to delete firewall rule. Please check the UFW configuration."
        fi
    elif [ "$action" = "list" ]; then
        # Display numbered UFW rules
        ufw status numbered
    else
        echo "Invalid action. Returning back to the menu."
        return
    fi
}

# UFW ASCII art
echo -e "\e[34m
 ,__ __                  _           _        ______ _           
/|  |  |          |  o  | |         (_|    | (_) |  (_|   |   |_/
 |  |  |   __   __|     | |           |    |    _|_   |   |   |  
 |  |  |  /  \_/  |  |  |/  |   |     |    |   / | |  |   |   |  
 |  |  |_/\__/ \_/|_/|_/|__/ \_/|/     \__/\_/(_/      \_/ \_/   
                        |\     /|                                
                        |/     \|                                
\e[0m"

# Set the font color to yellow
tput setaf 3

echo "Simplifying the process"
echo "Author: bdorr1105"
echo "Version Date: 5 May 2023"
echo

# Reset the font color
tput sgr0

# Check UFW status
ufw_status=$(ufw status | awk '/Status:/{print $2}')

if [ "$ufw_status" = "inactive" ]; then
    echo
    echo "UFW is currently disabled."
    echo
    read -p "Do you want to enable UFW and allow SSH from anywhere? (y/n): " enable_ufw

    if [ "$enable_ufw" = "y" ]; then
        # Allow SSH from anywhere
        ufw allow ssh

        # Enable UFW
        ufw enable
        enable_status=$?
        if [ $enable_status -eq 0 ]; then
            echo "UFW has been enabled and SSH is allowed from anywhere."
        else
            echo "Failed to enable UFW. Please check the UFW configuration."
            exit 1
        fi
    else
        echo "UFW remains disabled. Exiting script."
        exit 0
    fi
fi

# Menu
echo
echo "Selection Menu:"
echo
echo "1. Check the status of UFW"
echo "2. Modify firewall rules"
echo "3. Reload UFW"
echo "4. Disable UFW"
echo "5. Enable UFW"
echo
read -p "Enter your selection: " menu_selection
echo

case $menu_selection in
    1)
        # Check UFW status
        ufw status
        ;;
    2)
        # Prompt for action to perform
        read -p "Do you want to add a rule, delete a rule, or list the existing rules? (add/delete/list): " action
        perform_firewall_action "$action"
        ;;
    3)
        # Reload UFW
        ufw reload
        reload_status=$?
        if [ $reload_status -eq 0 ]; then
            echo "UFW reloaded successfully!"
        else
            echo "Failed to reload UFW. Please check the UFW configuration."
        fi
        ;;
    4)
        # Disable UFW
        ufw disable
        disable_status=$?
        if [ $disable_status -eq 0 ]; then
            echo "UFW disabled successfully!"
        else
            echo "Failed to disable UFW. Please check the UFW configuration."
        fi
        ;;
    5)
        # Enable UFW
        ufw enable
        enable_status=$?
        if [ $enable_status -eq 0 ]; then
            echo "UFW enabled successfully!"
        else
            echo "Failed to enable UFW. Please check the UFW configuration."
        fi
        ;;
    *)
        echo "Invalid action. Returning back to the menu."
        return
        ;;
esac

# Prompt for another action
echo
read -p "Do you want to perform another action? (y/n): " perform_again

while [ "$perform_again" = "y" ]; do
    echo
    echo "Selection Menu:"
    echo
    echo "1. Check the status of UFW"
    echo "2. Modify firewall rules"
    echo "3. Reload UFW"
    echo "4. Disable UFW"
    echo "5. Enable UFW"
    echo
    read -p "Enter your selection: " menu_selection

    case $menu_selection in
        1)
            # Check UFW status
            ufw status
            ;;
        2)
            # Prompt for action to perform
            echo
            read -p "Do you want to add a rule, delete a rule, or list the existing rules? (add/delete/list): " action
            perform_firewall_action "$action"
            ;;
        3)
            # Reload UFW
            ufw reload
            reload_status=$?
            if [ $reload_status -eq 0 ]; then
                echo "UFW reloaded successfully!"
            else
                echo "Failed to reload UFW. Please check the UFW configuration."
            fi
            ;;
        4)
            # Disable UFW
            ufw disable
            disable_status=$?
            if [ $disable_status -eq 0 ]; then
                echo "UFW disabled successfully!"
            else
                echo "Failed to disable UFW. Please check the UFW configuration."
            fi
            ;;
        5)
            # Enable UFW
            ufw enable
            enable_status=$?
            if [ $enable_status -eq 0 ]; then
                echo "UFW enabled successfully!"
            else
                echo "Failed to enable UFW. Please check the UFW configuration."
            fi
            ;;
        *)
            echo "Invalid action. Returning back to the menu."
            return
            ;;
    esac

    echo
    read -p "Do you want to perform another action? (y/n): " perform_again
done

# Clear the screen
clear

# List UFW status
ufw status