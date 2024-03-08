#!/bin/bash

function print_usage() {
    echo "Usage: $0 [-e email] [-p password] [-r recepient] [-d domain] [-o port]"
    echo "Options:"
    echo "   -e <email>          Specify the user email address"
    echo "   -p <password>       User's email password"
    echo "   -r <recepient>      Email of recepient"
    echo "   -d <domain>         domain"
    echo "   -o <port>           port"
}

function check_ssl_expiry() {
    domain=$1
    port=$2

    threshold_days=15

    expiry_date=$(echo | openssl s_client -connect "$domain:$port" 2>/dev/null | openssl x509 -noout -enddate | awk -F '=' '{print $2}')
    epoch_of_expiry=$(date -d "$(echo "$expiry_date" | awk '{print $1, $2, $4, $3, $5}')" "+%s")
    now_epoch=$(date +%s)
    actual_days_left=$(( (${epoch_of_expiry} - ${now_epoch}) / 86400))

    echo ${actual_days_left}
}

function send_email() {
    email="$1"
    password="$2"
    recipient="$3"
    subject="$4"
    message="$5"

    echo -e "Subject:$subject\n$message" | \
        sendmail -t -f "$email" "$recipient"
}

while getopts ':e:p:r:d:o:h:' flag; do
    case $flag in
        e) email=$OPTARG;;
        p) password=$OPTARG;;
        r) recipient=$OPTARG;;
        d) domain=$OPTARG;;
        o) port=$OPTARG;;
        h) print_usage; exit 0;;
        *) echo -ne "Unexpected Input: ${flag}\n" ;;
    esac
done

days_left=$(check_ssl_expiry "$domain" "$port")

if [ "$days_left" -lt 15 ]; then
    subject="SSL Certificate Expiry Alert - $domain"
    message="The SSL certificate for $domain is expiring in $days_left days."
    send_email "$email" "$password" "$recipient" "$subject" "$message"
else
    echo -ne "Certificate still has a validity of $days_left days\n"
fi