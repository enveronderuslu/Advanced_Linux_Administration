## SeLinux & AppArmor
AppArmor’da profile; bir uygulamanın hangi dosyalara, dizinlere, ağ kaynaklarına ve sistem çağrılarına erişebileceğini belirleyen güvenlik politikası dosyasıdır. Uygulamanın davranışı bu profile göre kısıtlanır. Var olan profilleri görmek için aa-status komutunu kullanilir. Bir uygulamanın: hangi dizinleri okuyabileceği, hangi dosyalara yazabileceği, hangi binary’leri çalıştırabileceği, hangi ağ işlemlerini yapabileceği tamamen bu profil içinde tanımlanır. 


## SELinux (Security Enhanced Linux)

"A subject" wants to perform "an action" on "an object".  

Traditional system security: Owner determines access privileges (DAC)  
SELinux: everything is labelled. Labels have to match (MAC)

Erişim izni verilmesi için hem klasik izinlerin hem de SELinux'un “EVET” demesi gerekir. Biri hayır derse → erişim reddedilir.

When a subject (z.B. an application) tries to access an object (z-B- a file), the SELinux part of the Linux kernel queries its policy database. Depending on the mode of operation (enforcing, permissive, disabled), SELinux authorizes access to the object in case of success, otherwise it records the failure in the file /var/log/messages.

Örnek: Apache web sunucusu /data/private/info.html dosyasına erişmek ister.  
Apache = subject, info.html = object.  
SELinux kontrol eder → izin varsa erişim gerçekleşir, yoksa reddeder ve log’a yazar. Eğer erişim reddedilirse /var/log/messages içine bir kayıt düşer:
```
type=AVC msg=audit(XXX): denied { read } for pid=1234 comm="httpd" name="info.html"
1. AVC – Access Vector Cache**: SELinux’un erişim kontrol kararlarını hızlandırmak için kullandığı önbellek.  
2. comm="httpd" – İşlemi başlatan komutun adı.
```
---

### Generalities

SELinux, Mandatory Access Control (MAC) sistemidir.  
Geleneksel DAC modeli kullanıcı/SUID haklarına dayanır. MAC ise daha sıkı yalıtım sağlar ve süper kullanıcı kavramı SELinux seviyesinde geçerli değildir.

SELinux, politika (policy) kuralları kullanır. İki temel politika türü vardır:

- **Targeted policy** → çoğu modern dağıtımda varsayılan
- **Strict policy** → daha katı, tüm süreçleri kapsayan model

![alt text](image.png)

---

### The SELinux Context

SELinux güvenlik bağlamı üçlüden oluşur:  
**identity + role + domain(type)**
Örnek biçim:  
`user_u:role_r:type_t`
Örnek bağlam:  
`system_u:object_r:httpd_sys_content_t`

- **identity**: SELinux kullanıcı kimliği  
- **role**: kullanıcının görev kategorisi  
- **domain/type**: süreçlerin veya nesnelerin çalışma alanları

Örnek süreç bağlamı:  
`system_u:system_r:httpd_t 4567 ? 00:00:00 httpd`

Bu demektir ki httpd servisi system_u kimliğiyle, system_r rolüyle ve httpd_t domain’inde çalışmaktadır.

Tablo:

| Kavram      |     Anlamı            |          Örnek           |
|-------------|-----------------------|---------------------------|
| Identity    | SELinux kimliği       |       bob_u, system_u     |
| Role        | Kullanıcının rolü     | user_r, staff_r, system_r |
| Domain/Type | Sürecin/dosyanın tipi | user_t, httpd_t, httpd_sys_content_t |

---

### Örnek Bağlamlar

**Örnek 1 — httpd Servisi**

`system_u:system_r:httpd_t 1512 ? 00:00:03 httpd`

**system_u (Identity)** SELinux kullanıcısını temsil eder. Burada “system_u”, sistem tarafından oluşturulmuş bir kullanıcıdır (root veya servisler için kullanılır).

**system_r (Role)** Kullanıcının rolünü gösterir. “system_r” rolü, sistem servislerini çalıştırmak için atanmış bir roldür.

**httpd_t (Domain/Type)** Sürecin ait olduğu SELinux domain veya tipi. Burada Apache web sunucusu süreci için domain httpd_t olarak belirlenmiş. Süreç yalnızca belirlenen tipteki dosya ve kaynaklara erişebilir.

**1512 (PID)** Sürecin işlem kimliği (Process ID).

**? (TTY)** Terminal bağlantısı yok. “?” genellikle servislerin doğrudan terminale bağlı olmadığını gösterir.

**00:00:03 (CPU Time)** Sürecin şimdiye kadar kullandığı CPU süresi.

**httpd (Command Name / Program)** Çalışan programın veya servis adını gösterir.

**Örnek 2 — Normal Kullanıcı**

`alice_u:user_r:user_t 1234 pts/0 00:00:00 bash`
**pts/0**  açılmış ilk sanal terminaldir. pts/1, pts/2 gibi diğer numaralar, farklı oturumları temsil eder.

**Örnek 3 — Root**

`root:sysadm_r:sysadm_t 2310 pts/1 00:00:01 bash`

**Örnek 4 — sshd Servisi**

`system_u:system_r:sshd_t 2840 ? 00:00:00 sshd`

**Örnek 5 — Alice yönetici rolüyle**

`alice_u:sysadm_r:sysadm_t 2234 pts/0 00:00:00 bash`

---

### Domain – Type İlişkisi

Süreçlerin hakları, domain’e (SELinux type) göre değerlendirilir.  
Örnek:

**Web sunucusu httpd**

- Süreç: `httpd_t`
- Web içerik dosyaları: `httpd_sys_content_t`

SELinux politikası:  
httpd_t domain’i yalnızca httpd_sys_content_t tipindeki dosyaları okuyabilir.

**Süreç tiplerini görmek için:**  
`ps -eZ`

**Dosya tiplerini görmek için:**  
`ls -Z /var/www/html/`

Örnek ls -Z çıktısı:  
`-rw-r--r--. root root system_u:object_r:httpd_sys_content_t:s0 index.html`

---

### SELinux Modları

- **Enforcing:** Politikalar zorunlu uygulanır.
- **Permissive:** İhlaller sadece loglanır.
- **Disabled:** SELinux devre dışıdır.

---

### Policy Oluşturan Ana Bileşenler

SELinux modelleri dört temel unsurla değerlendirilir:

- **Subjects** → süreçler
- **Objects** → dosyalar, soketler vb.
- **Policies** → izin kuralları
- **Mode** → enforcing/permissive/disabled

---

### SELinux’ta Dosya ve Süreç Tiplerinin Kontrolü

Komutlar:

**Dosya tipi öğrenme:**  
`ls -Z /path/file`

**Süreç domain’i öğrenme:**  
`ps -Z $(pidof httpd)`

**Mevcut bağlamı değiştirme:**  
`chcon -t httpd_sys_content_t /var/www/html/index.html`

**Bozulan dosya etiketlerini düzeltme:**  
`restorecon -Rv /var/www/html/`

---

### Basit ve Orta Düzey SELinux Örnekleri

**Örnek 1 — Apache yeni bir dizine erişemiyor**

Semptom:  
Apache /data/web/test.html dosyasını okuyamıyor.

Neden:  
Dizin tipi httpd_sys_content_t değil.

 
