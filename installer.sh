# install postgres and start the server
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo service postgresql start

# INPUTS
DATABASE_NAME=""

echo ""
echo "Enter your database name:"
read DATABASE_NAME
echo ""

sudo -u postgres psql -c "CREATE DATABASE $DATABASE_NAME;"





sudo -u postgres psql -c "DROP DATABASE $DATABASE_NAME;"