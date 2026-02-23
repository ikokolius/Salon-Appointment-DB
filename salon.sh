#! /bin/bash
# -t / --tuples-only Turns off printing of column names and result row count footers
# -X / --no-psqlrc Do not read the start-up file (neither the system-wide psqlrc file nor the user's ~/.psqlrc file).
# When you write a bash script to automate a database task, you need predictable output.
# The .psqlrc file often contains "beautification" settings
# -A / --no-align  Switches to unaligned output mode (The default output mode is aligned.)
PSQL="psql -XA --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

MENU() {
    AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    echo "$AVAILABLE_SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
    do
        echo "$SERVICE_ID) $SERVICE_NAME"
    done
    echo -e "\n"
}

MENU

echo -e "For which one would you like to book an appointment? Please choose a number\n"

read SERVICE_ID_SELECTED

while true
do
    # get service name
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if service doesn't exist
    if [[ -z $SERVICE_NAME ]]
    then
        echo -e "\nI could not find that service. What would you like today?\n"
        MENU
        read -p "Please choose a number " SERVICE_ID_SELECTED
    else
        break
    fi
done

# get customer info
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# if customer doesn't exist
if [[ -z $CUSTOMER ]]; then
    # get new customer name
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    # insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    if [[ $INSERT_CUSTOMER_RESULT != "INSERT 0 1" ]]; then
        echo "Problems saving your information. Let's try again."
    else
        CUSTOMER=$($PSQL "SELECT customer_id, name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    fi
fi
IFS="|" read CUSTOMER_ID CUSTOMER_NAME <<< "$CUSTOMER"
echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
read SERVICE_TIME
if [[ -z $SERVICE_TIME ]]; then
    # If the user just pressed Enter without typing
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME
else
    # insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID,  $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]; then
        echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
    else
        echo "Problems saving your information. Let's try again."
    fi
fi






