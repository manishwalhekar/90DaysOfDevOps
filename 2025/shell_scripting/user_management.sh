#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Part 1: User Account Creation
# Function to create a new user account
create_user() {
    read -p "Enter new username: " username

    # Check if the username already exists
    if id "$username" &> /dev/null; then
        echo "Error: Username '$username' already exists."
        exit 1
    fi

    # Prompt for a password (hidden input)
    read -sp "Enter password: " password
    echo

    # Create the user with a home directory
    useradd -m "$username" &> /dev/null

    # Set the user's password
    echo "$username:$password" | chpasswd
    echo "Success: User '$username' has been created."
}

# Part 2: User Account Deletion
# Function to delete a user account
delete_user() {
    read -p "Enter username to delete: " del_user

    # Check if the user exists
    if ! id "$del_user" &>/dev/null; then
        echo "Error: User '$del_user' does not exist."
        return
    fi

    # Prompt for home directory deletion
    read -r -p "Delete home directory? [Y/n]: " choice
    case "$choice" in
        [yY]|[yY][eE][sS]|"") 
            userdel -r "$del_user" &>/dev/null
            echo "Success: User '$del_user' and home directory deleted."
            ;;
        [nN]|[nN][oO]) 
            userdel "$del_user" &>/dev/null
            echo "Success: User '$del_user' deleted (home directory preserved)."
            ;;
        *) 
            echo "Invalid input. Please enter Y or N."
            ;;
    esac
}

# Part 3: Password Reset
# Function to reset a user's password
reset_password() {
    read -p "Enter username: " username

    # Check if the user exists
    if ! id "$username" &> /dev/null; then
        echo "Error: Username '$username' does not exist."
        return 1
    fi

    # Prompt for a new password and confirmation
    read -sp "Enter new password: " password
    echo
    read -sp "Confirm new password: " confirm_password
    echo

    # Verify if the passwords match
    if [ "$password" != "$confirm_password" ]; then
        echo "Error: Passwords do not match. Try again."
        return 1
    fi

    # Update the user's password
    echo "$username:$password" | chpasswd
    echo "Success: Password for '$username' has been changed."
}

# Part 4: List User Accounts
# Function to display a list of user accounts
list_users() {
    echo "User Accounts:"
    echo "----------------------"
    echo -e "UID\tUsername"
    
    # Extract and display users with UID >= 1000 (excluding system accounts)
    awk -F: '{ if ($3 >= 1000 && $3 != 65534) print " " $3 "\t " $1 }' /etc/passwd
}

#Part 5: Help and Usage Information
# Function to display script usage instructions
show_usage() {
    echo
    echo "User Account Management Script"
    echo "--------------------------------------"
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -c, --create     Create a new user account"
    echo "  -d, --delete     Delete an existing user account"
    echo "  -r, --reset      Reset a user's password"
    echo "  -l, --list       List all user accounts"
    echo "  -h, --help       Display this help message"
    echo
}

# Handle command-line arguments
case "$1" in
    -c|--create) create_user ;;
    -d|--delete) delete_user ;;
    -r|--reset) reset_password ;;
    -l|--list) list_users ;;
    -h|--help) show_usage ;;
    *) echo "Error: Invalid option. Use -h for help."; exit 1 ;;
esac

exit 0

