#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only --no-align -c"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo Which service would you like to choose?
  SERVICE_SELECTION=$($PSQL "Select * From services")

  SERVICE_NUMBER=$($PSQL "Select Count(service_id) From services")
 
  echo "$SERVICE_SELECTION" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo Please Select a service.
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED > $SERVICE_NUMBER ]]
  then
    MAIN_MENU "Please select an existing service"
  else
    SERVICE_NAME=$($PSQL "Select name From services Where service_id='$SERVICE_ID_SELECTED'")
    SERVICE_MENU
  fi
}

SERVICE_MENU () {
  echo Please enter your phone number.
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "Select name From customers Where phone='$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo Please enter your name.
    read CUSTOMER_NAME
    CUSTOMER_INSERT_RESULT=$($PSQL "Insert Into customers(phone, name) Values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  echo Please enter the time you want your appointment.
  read SERVICE_TIME

  CUSTOMER_ID=$($PSQL "Select customer_id From customers Where phone='$CUSTOMER_PHONE'")

  APPOINTMENT_RESULT=$($PSQL "Insert Into appointments(time, customer_id, service_id) Values('$SERVICE_TIME', '$CUSTOMER_ID', '$SERVICE_ID_SELECTED')")

  if [[ $APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU