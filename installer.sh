#!/bin/bash

# INPUTS
CONFIRMATION=:
IS_GIT_INSTALLED=:
IS_GO_INSTALLED=:
IS_POSTGRESQL_INSTALLED=:
IS_DEFAULT_PASSWORD=:
DATABASE_NAME=:
DATABASE_PASSWORD="postgres"

output_find_sql=$(mktemp)
output_sql_up=$(mktemp)
output_sql_down=$(mktemp)
declare -A sorted_sql_files
declare -A up_migrations
declare -A down_migrations



input()
{
    echo $1
    read $2
    echo
}

count_args()
{
    echo $#
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



git_valid()
{
    if [ "$IS_GO_INSTALLED" = "N" ]; then
        echo Installing Git...
        sudo apt update
        sudo apt install software-properties-common
        sudo add-apt-repository ppa:git-core/ppa
        sudo apt update
        sudo apt install git
        echo
    fi 
}

git_install_input()
{   
    input "Is Git installed? (y/N)" IS_GIT_INSTALLED
    yesNo $IS_GIT_INSTALLED git_install_input git_valid
}



go_valid()
{
    if [ "$IS_GO_INSTALLED" = "N" ]; then
        echo Installing Go...
        curl.exe https://webi.ms/golang | powershell
        echo
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
        echo
    fi
}

postgres_install_input()
{
    input "Is PostgreSQL installed? (y/N)" IS_POSTGRESQL_INSTALLED
    yesNo $IS_POSTGRESQL_INSTALLED postgres_install_input postgres_valid
}

git_install_input
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
sudo -u postgres psql -c "CREATE DATABASE $DATABASE_NAME;"



before_exit()
{     
    echo Getting the "https://github.com/Vran-n/blog-aggregator" repository...
    git clone https://github.com/Vran-n/blog-aggregator
    echo



    count=$(count_args $(find ./blog-aggregator/sql/schema -name "*.sql"))
    find ./blog-aggregator/sql/schema -name "*.sql" > "$output_find_sql"

    i=1
    while [ $i -le $count ]; do
        file=$(grep "00${i}" "$output_find_sql")
        sorted_sql_files[$i]=$file
        ((i++))
    done

    # what this does is is puts them in two different associative arrays
    # based on what type of migration it is
    i=1
    while [ $i -le $count ]; do
        migration="up"
        echo > "$output_sql_up"
        echo > "$output_sql_down"

        line_count=$(wc -l < ${sorted_sql_files[$i]}); ((line_count++))
        # scans the file line by line and saves them 
        j=2
        until [ $j -gt $line_count ]; do
            line=$(head "-${j}" ${sorted_sql_files[$i]} | tail -1)

            if [ "$migration" == "up" ]; then
                echo "$line" >> "$output_sql_up"
            else
                echo "$line" >> "$output_sql_down"
            fi

            # if semi-colon found. skip two lines
            end_of_block=$(echo $line | grep ';')
            if [ "$end_of_block" != "" ]; then migration="down"; ((j++)); ((j++)); fi

            ((j++))
        done

        up_migrations[$i]=$(cat $output_sql_up)
        down_migrations[$i]=$(cat $output_sql_down)
        ((i++))
    done
    rm "$output_find_sql"
    rm "$output_sql_up"
    rm "$output_sql_down"

    i=1; full_up_str=""
    while [ $i -le $count ]; do
        full_up_str="${full_up_str}up_migrations[$i]='$(echo ${up_migrations[$i]})'; "
        ((i++))
    done


    i=1; full_down_str=""
    while [ $i -le $count ]; do
        full_down_str="${full_down_str}down_migrations[$i]='$(echo ${down_migrations[$i]})'; "
        ((i++))
    done

    echo "
    declare -A up_migrations
    $full_up_str
    $(echo '
    i=1
    while [ $i -le' "$count" ']; do
        sudo -u postgres psql -d' "$DATABASE_NAME" '-c "${up_migrations[$i]}"
        ((i++))
    done
    ')
    " > full_migration.sh
    sudo chmod 744 full_migration.sh
    ./full_migration.sh


    echo "
    declare -A down_migrations
    $full_down_str
    $(echo '
    i=5
    while [ $i -gt' 0 ']; do
        sudo -u postgres psql -d' "$DATABASE_NAME" '-c "${down_migrations[$i]}"
        ((i--))
    done
    ')
    " > reset_migration.sh
    sudo chmod 744 reset_migration.sh




    local database_url="postgres://postgres:${DATABASE_PASSWORD}@localhost:5432/${DATABASE_NAME}"
    echo "=============Configuration Finished=============="
    echo Your password is: "$DATABASE_PASSWORD"
    echo "Generated URL: $database_url"
    echo
    echo "To gain access to the database, simply enter:"
    echo "psql '$database_url'"
    sudo -u postgres psql -c "DROP DATABASE $DATABASE_NAME;"
}





















































































database_prompt_password_valid()
{
    if [ "$IS_DEFAULT_PASSWORD" = "N" ]; then
        sudo -u postgres psql -d $DATABASE_NAME -c "ALTER USER postgres PASSWORD '$DATABASE_PASSWORD';"
        before_exit
        exit
    fi
}

database_prompt_password_default()
{   
    input "Set the password? Default is \"postgres\" (y/N)" IS_DEFAULT_PASSWORD
    yesNo $IS_DEFAULT_PASSWORD database_prompt_password_default database_prompt_password_valid
}

database_prompt_password_default



input "Enter your database password:" DATABASE_PASSWORD
echo "You entered: \"$DATABASE_PASSWORD\""
database_password_confirm_input()
{
    input "Confirm? (y/N)" CONFIRMATION

    result=$(yesNoReturn $CONFIRMATION)
    if [ $result -eq 0 ]; then
        echo Please enter y or N
        database_password_confirm_input
    elif [ $result -eq 1 ]; then
        if [ "$CONFIRMATION" = "N" ]; then
            input "Enter your database name:" DATABASE_PASSWORD
            echo "You entered: \"$DATABASE_PASSWORD\""
            database_password_confirm_input
        fi
        CONFIRMATION=:
    fi
}

database_password_confirm_input
sudo -u postgres psql -d $DATABASE_NAME -c "ALTER USER postgres PASSWORD '$DATABASE_PASSWORD';"
before_exit