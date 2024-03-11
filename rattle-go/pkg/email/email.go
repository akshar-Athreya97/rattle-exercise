package email

import (
	"fmt"
	"net/mail"
	"net/smtp"
)

func SendEmail(email, password, recepient, subject, body string) error {
	from := mail.Address{"", email}
	to := mail.Address{"", recepient}
	msg := fmt.Sprintf("From: %s\r\nTo: %s\r\nSubject: %s\r\n\r\n%s", from.String(), to.String(), subject, body)

	auth := smtp.PlainAuth("", email, password, "smtp.gmail.com")

	err := smtp.SendMail("smtp.gmail.com:587", auth, email, []string{recepient}, []byte(msg))

	if err != nil {
		return err
	}

	return nil
}
