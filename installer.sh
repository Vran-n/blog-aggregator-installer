#!/bin/bash

# INPUTS
CONFIRMATION=:
IS_GO_INSTALLED=:
IS_POSTGRESQL_INSTALLED=:
DATABASE_NAME=:
DATABASE_PASSWORD="postgres"



input()
{
    echo $1
    read $2
}

yesNo()
{   
    if [ "$1" = "y" ] || [ "$1" = "N" ]; then
        $3
    else
        echo Please enter y or N
        $2
    fi
}

yesNoReturn()
{   
    if [ "$1" = "y" ] || [ "$1" = "N" ]; then
        echo 1
    else
        echo 0
    fi
}

go_valid()
{
    if [ "$IS_GO_INSTALLED" = "N" ]; then
        echo Installing Go...
        curl.exe https://webi.ms/golang | powershell
    fi 
}

go_install_input()
{   
    input "Is Go (golang) installed? (y/N)" IS_GO_INSTALLED
    yesNo $IS_GO_INSTALLED go_install_input go_valid
}

postgres_valid()
{
    if [ "$IS_POSTGRESQL_INSTALLED" = "N" ]; then
        echo Installing PostgreSQL...
        sudo apt update
        sudo apt install postgresql postgresql-contrib
    fi
}

postgres_install_input()
{
    input "Is PostgreSQL installed? (y/N)" IS_POSTGRESQL_INSTALLED
    yesNo $IS_POSTGRESQL_INSTALLED postgres_install_input postgres_valid
}



go_install_input
postgres_install_input

# start the server
sudo service postgresql start

input "Enter your database name:" DATABASE_NAME
echo "You entered: \"$DATABASE_NAME\""
database_confirm_input()
{
    input "Confirm? (y/N)" CONFIRMATION

    result=$(yesNoReturn $CONFIRMATION)
    if [ $result -eq 0 ]; then
        echo Please enter y or N
        database_confirm_input
    elif [ $result -eq 1 ]; then
        if [ "$CONFIRMATION" = "N" ]; then
            input "Enter your database name:" DATABASE_NAME
            echo "You entered: \"$DATABASE_NAME\""
            database_confirm_input
        fi
        CONFIRMATION=:
    fi
}

database_confirm_input
#sudo -u postgres psql -c "CREATE DATABASE $DATABASE_NAME;"


#sudo -u postgres psql -d $DATABASE_NAME -c "ALTER USER postgres PASSWORD '$DATABASE_PASSWORD';"




#sudo -u postgres psql -c "DROP DATABASE $DATABASE_NAME;"