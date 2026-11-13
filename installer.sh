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

go_install_input()
{   
    input "Is Go (golang) installed? (y/N)" IS_GO_INSTALLED
    yesNo $IS_GO_INSTALLED go_install_input $(
        if [ "$IS_GO_INSTALLED" = "N" ]; then
            echo Installing Go...
            curl.exe https://webi.ms/golang | powershell
        fi 
    )
}

postgres_install_input()
{
    input "Is PostgreSQL installed? (y/N)" IS_POSTGRESQL_INSTALLED
    yesNo $IS_POSTGRESQL_INSTALLED postgres_install_input $(
        if [ "$IS_POSTGRESQL_INSTALLED" = "N" ]; then
            echo Installing PostgreSQL...
            sudo apt update
            sudo apt install postgresql postgresql-contrib
        fi
    )
}



go_install_input
postgres_install_input

# start the server
sudo service postgresql start

#database_valid_input()
#{
#    input "Enter your database name:" DATABASE_NAME
#    input "You entered: $DATABASE_NAME Confirm? (y/n)" CONFIRMATION
#    yesNo $CONFIRMATION database_valid_input database_valid_input
#    echo HERE
#    CONFIRMATION=:
#}
#
#database_valid_input
#sudo -u postgres psql -c "CREATE DATABASE $DATABASE_NAME;"


#sudo -u postgres psql -d $DATABASE_NAME -c "ALTER USER postgres PASSWORD '$DATABASE_PASSWORD';"




#sudo -u postgres psql -c "DROP DATABASE $DATABASE_NAME;"