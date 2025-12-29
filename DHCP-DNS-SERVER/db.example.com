$ORIGIN example.com.
$TTL    1w
example.com.    IN      SOA     dns1.example.com. hostmaster.example.com. (
                        3               ; Serial
                        1w              ; Refresh
                        1d              ; Retry
                        28d             ; Expire
                        1w)     ; Negative Cache TTL
                         
; name servers - NS records
                IN      NS      dns1.example.com.

; name servers - A records
dns1.example.com.               IN      A       10.0.2.5

; 172.21.0.0/16 - A records
dhcp1.example.com.              IN      A       10.0.2.4

id1.example.com.                IN      A       10.0.2.6
