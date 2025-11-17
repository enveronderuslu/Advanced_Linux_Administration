PAM Authentication Modules¶

PAM is a library suite that allows a Linux system administrator to configure methods to authenticate users. It provides a flexible and centralized way to switch authentication methods for secured applications using configuration files instead of changing application code.

Generalities¶ 
Authentication is the phase during which it is verified that you are the person you claim to be. 
z.B. password, but other forms of authentication exist.

![alt text](image.png)

Implementing a new authentication method should not require changes in source code for service configuration. This is why applications rely on PAM

Each application or service supporting PAM will have a corresponding configuration file in the /etc/pam.d/ directory. For example, the process login assigns the name /etc/pam.d/login to its configuration file.

Directives¶
A directive is used to set up an application for usage with PAM. 
Directives will follow this format:


A directive (a complete line) is composed of a mechanism (auth, account, password or session), a success check (include, optional, required, ...), the path to the module and possibly arguments 

Each PAM configuration file contains a set of directives. The order in which the modules are 
listed is very important to the authentication process.

For example, here's the config file /etc/pam.d/sudo:

#%PAM-1.0
auth       include      system-auth
account    include      system-auth
password   include      system-auth
session    include      system-auth

Mechanisms¶
AUTH - Authentication¶
This handles the authentication of the requester and establishes the rights of the account:

"auth" bölümü, kullanıcının kim olduğunu anlamak ve sisteme giriş izni verip vermemekle ilgilenir.

ACCOUNT - Account management¶
Checks if requested account is available:Relates to the availability of the account for 
reasons other than authentication (e.g. for time restrictions).

Analoji: Kapıdaki güvenlik önce: Şifreyi kontrol eder (bu authentication kısmıdır)
Sonra der ki: "Bu öğrenci bugün okula girebilir mi?" Tatilde mi? Saat çok mu geç? 
Bu sınıf artık kapandı mı?

SESSION - Session management¶
Performs tasks associated with session setup (e.g. logging)/termination.

"Session management", bilgisayara giriş cikis hazırlık ve temizlik işlerini yapan  
görevlidir. Giriş yaparken (Session Setup) görevli: Senin geldiğini bir deftere yazıyor (log), 
bazı ışıkları açıyor (kaynakları başlatıyor), Sana özel ortamı hazırlıyor (klasörleri, ayarları),
Çıkarken (Session Termination): “Tamam bu kişi gitti” diye not alıyor.
Böylece her kullanıcının giriş ve çıkışı düzgün şekilde yönetilir. 

PASSWORD - Password management¶
Changes the authentication token and possibly verifies that it is robust enough or has not already been used.
Diyelim ki bilgisayarın sana diyor ki: "şifre çok eski, yenisini yap!"
İşte burada PAM devreye giriyor. PAM, sisteme “bu şifre değiştirilecek” diyor ve bazı sifre politikalariyla ilgili  kontroller yapıyor:

******************************************************

Control Indicators¶
The PAM mechanisms (auth, account, session and password) indicate success or failure. The control flags (required, requisite, sufficient, optional) tell PAM how to handle this result.

REQUIRED¶
Successful completion ist benötigt. If the module fails: The rest of the chain is executed. Finally the request is rejected.
required bir zorunlu kapıdır. Başarısız olsan bile diğer kontroller yapılmaya devam eder. 
Ama sonunda başarısız olduysan girişe izin verilmez.

REQUISTE ¶
Successful completion of all requisite modules is necessary.If the module fails: The request is immediately rejected.

SUFFICIENT¶
Modules marked sufficient can be used to let a user in "early" under certain conditions:

If the module succeeds: The authentication request is immediately allowed if none of the previous modules failed.

If the module fails: The module is ignored. The rest of the chain is executed.


Eve girmek için birkaç kapıdan geçmen gerekiyor. Ama bu kez bir kapıda yazıyor ki: “Eğer buradan geçersen, diğer kapılara gerek yok.” Eğer başaramazsan (örneğin şifre hatalıysa): “Tamam, sorun yok. Ama diğer kapılardan da geçmen gerekecek.”

Gerçek hayat örneği: Eğer bir kullanıcı LDAP’ta varsa (örneğin şirket ağı), Ya şirket ağı üzerinden tanınan bir kullanıcısındır (bu LDAP olur). Ya da bilgisayarda yerel olarak kayıtlı bir kullanıcısındır (örneğin "admin", "backup" gibi).

OPTIONAL¶
The module is executed but the result of the request is ignored. If all modules in the chain were marked optional, all requests would always be accepted.

Diyelim sistemde şöyle bir PAM kuralı var:
session optional pam_motd.so

Giriş yaptıktan sonra sana bir "Message of the Day" gösterir:
"Have a great day, $USER!". Ama: Bu mesaj çıkmazsa, sistem girişini engellemez. 
Yani bu işlem sadece isteğe bağlıdır.

Durum	Etkisi
Başarıyla geçti	       Sistem devam eder
Başarısız oldu	          Yine sistem devam eder
Giriş etkilenir mi?	    ❌ Hayır

![alt text](image-1.png)

Örnek Satırlar

auth       required     pam_unix.so
Kullanıcının kimliğini doğrular. Başarısızsa giriş başarısız olur.

account    required     pam_nologin.so
/etc/nologin dosyası varsa kullanıcıların girişini engeller.
session    optional     pam_motd.so
Kullanıcıya giriş sırasında bilgi mesajı (Message of the Day) gösterir.
password   include      system-auth
system-auth dosyasındaki password satırlarını dahil eder. 

Resmi ve Online Kaynaklar:
https://www.linux-pam.org/


PAM MODULES¶
the most common modules for PAM are:
pam_unix, pam_ldap, pam_wheel. pam_cracklib      
pam_console, pam_tally2, pam_securetty, pam_nologin    
pam_limits, pam_time, pam_access     

////////////////****************////////////////////////////

pam_unix¶

pam_unix /etc/passwd ve /etc/shadow defterlerini okur.
pam_unix modülü şu alanlarda görev alabilir:

PAM Aşaması	      Ne işe yarar?
auth	            Şifre doğru mu diye bakar
account	         Kullanıcının hesabı aktif mi kontrol eder
password	         Şifre değişikliği işlemini yapar
session	         Giriş-çıkış zamanı gibi işlemleri yönetir

In /etc/pam.d/system-auth you might add:

password sufficient pam_unix.so sha512 nullok
Arguments are possible for this module:

nullok: in the auth mechanism allows an empty login password.
sha512: in the password mechanism, defines the encryption algorithm.
debug: sends information to syslog.
remember=n: Use this to remember the last n passwords used 
(works in conjunction with the /etc/security/opasswd file).
---------------------------------------------------------------------
pam_cracklib¶
The pam_cracklib module allows you to test passwords. Yani kullanıcıları, daha güçlü ve karmaşık şifreler kullanmaya zorlar.
----------------------------------------------------
pam_tally¶

pam_tally bir sayacı gibidir. Her başarısız giriş denemesini sayar.
The pam_tally module allows you to lock an account based on a number of unsuccessful login attempts.

The default config file for this module might look like: /etc/pam.d/system-auth:
The auth mechanism accepts or denies authentication and resets the counter.
--------------------------------------------------------------------
pam_time¶
The pam_time module allows you to limit the access times to services managed by PAM.

To activate it, edit /etc/pam.d/system-auth and add:
account required /lib/security/pam_time.so
The configuration is done in the /etc/security/time.conf file:
--------------------------------------------------------------
pam_nologin¶
The pam_nologin module disables all accounts except root:

In /etc/pam.d/login you'd put:


auth required pam_nologin.so
Only root can connect if the file /etc/nologin exists and is readable.
-------------------------------------------------------------------
pam_wheel¶
The pam_wheel module allows you to limit the access to the su command to the members of the wheel group. In /etc/pam.d/su you'd put:

auth required pam_wheel.so
The argument group=my_group limits the use of the su command to 
members of the group my_group
----------------------------------------------------------------
pam_mount¶
The pam_mount module allows you to mount a volume for a user session.

In /etc/pam.d/system-auth you'd put:
