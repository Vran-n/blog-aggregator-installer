# INPUTS
DATABASE_NAME=""

user_input()
{
    echo
    echo $1
    read $2
    echo
}

# install postgres and start the server
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo service postgresql start

user_input "Enter your database name:" DATABASE_NAME

sudo -u postgres psql -c "CREATE DATABASE $DATABASE_NAME;"





sudo -u postgres psql -c "DROP DATABASE $DATABASE_NAME;"