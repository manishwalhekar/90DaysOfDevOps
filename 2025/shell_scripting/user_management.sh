#!/bin/bash


# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi


# Part 1: Account Creation
# Function to create new user
create_user() {
    read -p "Enter new username: " username

    # Check if username exists
    if id "$username" &> /dev/null ; then
        echo "Error: Username '$username' already exists."
        exit 1
    fi

    read -sp "Enter password: " password
    echo

    # Create user with home directory
    useradd -m "$username" &> /dev/null

    # Set password
    echo "$username:$password" | chpasswd
    echo "Success: User '$username' created."
}


# Part 2: Account Deletion
# Function to delete a user

delete_user() {
    read -p "Enter Username to delete: " del_user

    if ! id "$del_user" &>/dev/null; then
        echo "Error: User '$del_user' does not exist."
        return
    fi

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
# Function to reset password
reset_password() {
    read -p "Enter username: " username

    # Check if username exists
    if ! id "$username" &> /dev/null ; then
        echo "Error: Username '$username' does not exist."
        return 1
    fi

    #Prompts for new password
    read -sp "Enter new password: " password
    echo
    
    read -sp "Confirm new password: " confirm_password
    echo

     # Check if passwords match
    if [ "$password" != "$confirm_password" ]; then
        echo "Error: Passwords do not match."
        return 1
    fi

    # Change password
    echo "$username:$password" | chpasswd
    echo "Success: Password for '$username' changed successfully"
}


# Part 4: List User Accounts
# Function to list users
list_users() {
    echo "User accounts:"
    echo "------------------"
    echo -e "UID\t Username"
    awk -F: '{ if ($3 >= 1000 && $3 != 65534) print $3 "\t " $1 }' /etc/passwd
}


# Part 5: Help and Usage Information
# Help function
show_usage() {
    echo
    echo "User Account Management Script"
    echo "Usage: $0 [OPTION]"
    echo
    echo "Options:"
    echo "  -c, --create              Create new user account"
    echo "  -d, --delete              Delete existing user account"
    echo "  -r, --reset               Reset user password"
    echo "  -l, --list                List all user accounts"
    echo "  -h, --help                Show this help message"
    echo
}

# Handle command line arguments
case "$1" in
    -c|--create) create_user ;;
    -d|--delete) delete_user ;;
    -r|--reset) reset_password ;;
    -l|--list) list_users ;;
    -h|--help) show_usage ;;
    *) echo "Error: Invalid option. Use -h for help."; exit 1 ;;
esac


exit 0
