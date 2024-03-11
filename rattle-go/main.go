package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/akshar-Athreya97/rattle-exercise/rattle-go/pkg/email"
	"github.com/akshar-Athreya97/rattle-exercise/rattle-go/pkg/ssl"
)

func main() {
	var (
		domainFlag   string
		portFlag     int
		emailFlag    string
		passFlag     string
		recFlag      string
		emailPresent bool
		passPresent  bool
		recPresent   bool
	)

	flag.StringVar(&domainFlag, "d", "", "Domain to check Cert Expiry")
	flag.IntVar(&portFlag, "p", 443, "Port to connect to (Default: 443)")
	flag.StringVar(&emailFlag, "e", "", "User's email address")
	flag.StringVar(&passFlag, "a", "", "User's password")
	flag.StringVar(&recFlag, "r", "", "Recipient's email")
	flag.Parse()

	if domainFlag == "" || portFlag == 0 {
		fmt.Println("Usage: main -d <domain> -p <port> [-e <email>] [-a <password>] [-r <recipient>]")
		os.Exit(1)
	}

	if emailFlag != "" {
		emailPresent = true
	}
	if recFlag != "" {
		recPresent = true
	}
	if passFlag != "" {
		passPresent = true
	}

	daysLeft, err := ssl.CheckSSLExpiry(domainFlag, portFlag)

	if err != nil {
		fmt.Printf("Error checking SSL cert: %v", err)
		os.Exit(1)
	} else {
		fmt.Printf("Amount of days left for cert expiry for %s: %v days", domainFlag, daysLeft)
	}

	threshold := 15

	if daysLeft < threshold && emailPresent && recPresent && passPresent {
		subject := fmt.Sprintf("SSL Certificate Expiry alert - %s", domainFlag)
		body := fmt.Sprintf("The ssl certificate for %s is expiring in %v days", domainFlag, daysLeft)
		err := email.SendEmail(emailFlag, passFlag, recFlag, subject, body)
		if err != nil {
			fmt.Println("Error Sending email: ", err)
			os.Exit(1)
		} else {
			fmt.Println("Email Sent Successfully")
		}
	}

}
