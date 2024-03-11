package ssl

import (
	"crypto/tls"
	"fmt"
	"net"
	"time"
)

func CheckSSLExpiry(domain string, port int) (int, error) {
	conn, err := net.DialTimeout("tcp", fmt.Sprintf("%s:%d", domain, port), 10*time.Second)
	if err != nil {
		return 0, err
	}
	defer conn.Close()

	config := tls.Config{ServerName: domain}
	tlsConn := tls.Client(conn, &config)

	defer tlsConn.Close()

	if err := tlsConn.Handshake(); err != nil {
		return 0, err
	}

	cert := tlsConn.ConnectionState().PeerCertificates[0]
	expiresOn := cert.NotAfter
	daysLeft := time.Until(expiresOn)

	return int(daysLeft.Hours() / 24), nil
}
