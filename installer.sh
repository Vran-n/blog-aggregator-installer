# INPUTS
IS_GO_INSTALLED=:
IS_POSTGRESQL_INSTALLED=:
DATABASE_NAME=:

user_input()
{
    echo $1
    read $2
    echo
}

go_install_input()
{
    user_input "Is Go (golang) installed? (y/N)" IS_GO_INSTALLED
    if [ "$IS_GO_INSTALLED" = "y" ] || [ "$IS_GO_INSTALLED" = "N" ]; then
        if [ "$IS_GO_INSTALLED" = "N" ]; then
            echo Installing Go...
            curl.exe https://webi.ms/golang | powershell
        fi
    else
        echo Please enter y or N
        go_install_input
    fi
}

go_install_input

user_input "Is Postgresql installed? (y/N)" IS_POSTGRESQL_INSTALLED

# install postgres and start the server
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo service postgresql start

user_input "Enter your database name:" DATABASE_NAME

sudo -u postgres psql -c "CREATE DATABASE $DATABASE_NAME;"





sudo -u postgres psql -c "DROP DATABASE $DATABASE_NAME;"