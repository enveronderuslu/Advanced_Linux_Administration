$ORIGIN example.local.
$TTL    1w
example.local.     IN      SOA     mgmt-dns.example.local. hostmaster.example.local. (
                       4               ; Serial (ARTIRILDI)
                       1w              ; Refresh
                       1d              ; Retry
                       28d             ; Expire
                       1w)     ; Negative Cache TTL

; name servers - NS records
                IN      NS      mgmt-dns.example.local.

; Ana domain kaydı (EKSİK OLAN BUYDU)
@               IN      A       10.0.10.5

; name servers - A records
mgmt-dns        IN      A       10.0.10.5
mgmt-iam        IN      A       10.0.10.6
mgmt-bastion    IN      A       10.0.10.7
mgmt-ans        IN      A       10.0.10.8


