SELinux (Security Enhanced Linux )
Linux mit verbesserter Sicherheit
A subjeckt wants to perform an action on an object 
Traditional system security: Owner determines access priviliges (DAC)
SELinux: everthing is labelled. Labels have to match (MAC)

Erişim izni verilmesi için hem klasik izinlerin hem de SELinux'un "EVET" demesi gerekir. Biri hayır derse → erişim reddedilir.

When a subject (z.B. an application) tries to access an object (z-B- a file), the SELinux part of the Linux kernel queries its policy database. Depending on the mode of operation (enforcing, permissive, disabled), SELinux authorizes access to the object in case of success, otherwise it records the failure in the file /var/log/messages.


Örnek: Diyelim ki Apache web sunucusu (program) /data/private/info.html adlı bir dosyaya erişmek istiyor. Bu durumda: Apache = subject (uygulama), data/private/info.html = object (dosya). Apache (subject) → dosyaya ulaşmaya çalışır (object). SELinux kontrol eder → izin varsa ✔, yoksa ✖ + log dosyasına yazar.
 
Eğer erişim reddedilirse, sistem bu olayı /var/log/messages dosyasına şöyle kaydeder:  type=AVC msg=audit(XXX): denied { read } for pid=1234 comm="httpd" name="info.html"
1. AVC – Access Vector Cache: SELinux’un, erişim izinlerini daha hızlı kontrol edebilmesi için kullandığı bir önbellektir.

Buradaki log türü type=AVC olduğunda, bu log’un bir erişim denetimi (izin verildi/verilmedi) olayıyla ilgili olduğunu gösterir. AVC logları, SELinux’un bir erişimi neden reddettiğini veya kabul ettiğini gösteren kayıt türüdür.

2. comm="httpd" – Command Name. comm, "command" yani çalışan programın adı demektir. 

Generalities¶
SELinux (Security Enhanced Linux) is a Mandatory Access Control system. Standard access management security was based on DAC (Discretionary Access Control) systems. An application operated with UID or SUID (Set Owner User Id) rights, which made it possible to evaluate permissions (on files, sockets, and other processes...) according to this user. 

A MAC system reinforces the separation of confidentiality and integrity information to achieve a containment system. The containment system is independent of the traditional rights system and there is no notion of a superuser.

![alt text](image.png)

SELinux uses a set of rules (policies) for this. A set of two standard rule sets (targeted and strict) is provided and each application usually provides its own rules. 
-----------------------------------------------------
The SELinux context¶
The operation of SELinux is totally different from traditional Unix rights. The SELinux security context is defined by the trio: 
identity+role+domain

Identity → Sen kimsin? (alice, bob)
Role → Ne iş yapıyorsun? (student, teacher)
Domain → Hangi sınıftasın, hangi alanlarda gezebilirsin? (user_t, admin_t, httpd_t)

SELinux Context Nedir?
SELinux, dosyaları ve işlemleri şu şekilde etiketler:
user_u:role_r:type_t
Bu üçlüye SELinux security context denir.

Örnek:
system_u:object_r:httpd_sys_content_t

system_u	               Kim? (Identity – sistem kullanıcısı)
object_r	               Hangi görevle? (Role – bir nesne rolü)
httpd_sys_content_t	   Nerede, ne tür işlemleri yapabilir? (Domain veya type)

Örnek 2: Web Sunucusu (httpd)
Apache hizmeti çalışıyor:

system_u:system_r:httpd_t   4567 ? 00:00:00 httpd

identity = system_u
role = system_r
domain/type = httpd_t 
sadece web içeriğine (mesela httpd_sys_content_t) erişebilir. Başka dosyalara erişemez.

Özetle:
Kavram	      Anlamı	                        Örnek Değer
Identity	      Kullanıcının SELinux kimliği	   bob_u, system_u
Role	         Ne tür görev yapabilir?	         user_r, staff_r, system_r
Domain	      Hangi alanlarda çalışır?	      user_t, httpd_t, admin_t

The identity of a user depends directly on his Linux account. An identity is assigned one or more roles, but to each role corresponds to one domain, and only one.
The naming convention is: user_u:role_r:type_t.

Örnek 1 — Normal Kullanıcı
alice_u:user_r:user_t   1234 pts/0 00:00:00 bash
Identity → alice_u      Role → user_r     Domain (type) → user_t

Bu demektir ki alice kullanıcısı, şu anda user rolünde ve sadece user_t domain’ine göre işlem yapabilir."alice adlı kullanıcı, sıradan bir kullanıcı rolünde (user_r) ve kullanıcı domain'inde (user_t) bir terminal penceresi (pts/0) üzerinden bir bash kabuğu başlatmış. Bu işlem sistemde 1234 ID’siyle çalışıyor ve şu ana kadar işlemci zamanı kullanmamış."

Örnek 2:
root:sysadm_r:sysadm_t   2310 pts/1 00:00:01 bash
"root kullanıcısı, sistem yöneticisi rolünde (sysadm_r) ve sistem yöneticisi domain'inde (sysadm_t) bir terminal (pts/1) üzerinden bir bash kabuğu çalıştırıyor. Bu işlem 2310 PID’siyle çalışıyor ve az miktarda CPU süresi kullanmış."

Örnek 3:
system_u:system_r:httpd_t   1512 ? 00:00:03 httpd
"httpd servisi, sistem tarafından (system_u) bir servis rolünde (system_r) ve httpd_t domain’inde çalıştırılmış. Bu işlem 1512 PID’siyle çalışıyor, herhangi bir terminalden başlatılmamış (?), ve 3 saniyelik CPU süresi kullanmış."

Örnek 4:
system_u:system_r:sshd_t   2840 ? 00:00:00 sshd
"sshd servisi, sistem kullanıcısı (system_u) tarafından, servis rolünde (system_r) ve sshd_t domain’inde çalıştırılmış. Terminal bağlantısı yok (?), işlem ID’si 2840 ve henüz CPU kullanmamış."

Örnek 5:
alice_u:sysadm_r:sysadm_t   2234 pts/0 00:00:00 bash
"alice kullanıcısı, şu anda sistem yöneticisi rolünde (sysadm_r) ve sistem yöneticisi domain’inde (sysadm_t) bir terminal (pts/0) üzerinden bir bash kabuğu çalıştırıyor. Bu işlem sistemde 2234 PID’siyle çalışıyor ve henüz işlemci zamanı kullanmamış."

It is according to the domain of the security context (and thus the role) that user's rights on a resource are evaluated. 

The terms "domain" and "type" are similar. Typically "domain" refers to a process, while "type" refers to an object.

Consider the the SELinux puzzle: The subjects, The objects, The policies, The mode

When a subject (an application for example) tries to access an object (a file for example), the SELinux part of the Linux kernel queries its policy database. Depending on the mode of operation, SELinux authorizes access to the object in case of success, otherwise it records the failure in the file /var/log/messages.
---------------------------------------------------------------------
The SELinux context of standard processes¶

The rights of a process depend on its security context.

By default, the security context of the process is defined by the context of the user (identity + role + domain) who launches it.

A domain is a specific type (in the SELinux sense) linked to a process and inherited (normally) from the user who launched it. Its rights are expressed in terms of authorization or refusal on types linked to objects:

A process whose context has security domain D can access objects of type T.

Domain (D)	Bir süreç için tanımlanmış SELinux güvenlik tipi (örnek: httpd_t)
Type (T)	   Bir dosya/nesne için tanımlanan SELinux tipi (örnek: httpd_sys_content_t)
İzin/Red	   SELinux politikası, D domain’inin T tipindeki nesneye erişimini belirler
Domain bir sandbox veya container da olabilir
Örnek 1 — Web sunucusu httpd
system_u:system_r:httpd_t   1001 ? 00:00:02 httpd
httpd işlemi               → httpd_t domain’inde çalışıyor
Web içerik dosyaları       → httpd_sys_content_t tipiyle etiketlenmiş

SELinux Politikası şunu der: Eğer bir süreç httpd_t domain’indeyse, sadece httpd_sys_content_t tipindeki dosyalara okuma erişimi vardır.

ps -eZ gibi komutların çıktısında sadece süreçlerin SELinux bağlamı (context) görünür. Yani, örneğin şu:

system_u:system_r:httpd_t   1001 ? 00:00:02 httpd
Bu sadece süreç (process) için geçerli olan güvenlik bağlamıdır. httpd_sys_content_t gibi şeyler dosyaların SELinux tipi (type) kısmına aittir. Onlar süreçte değil, dosya sisteminde görünür.

httpd_sys_content_t nerede görünür?
Bunu görmek için şu komutları kullanırız:

ls -Z /var/www/html/
Bu, ls -l komutuna benzer ama fazladan bir sütun olarak SELinux context gösterir.
Örnek çıktı:

-rw-r--r--. root root system_u:object_r:httpd_sys_content_t:s0 index.html
Burada httpd_sys_content_t, bu dosyanın SELinux tipi (type)’dir.
Yani: 
httpd_t → işlem için domain
httpd_sys_content_t → dosya için type

SELinux bu iki bilgiyi eşleştirerek “izin ver” ya da “reddet” kararını verir.
Nerede görünür?	   Ne gösterir?	                  Komut
ps -eZ, ps -Z	      Process'in SELinux domaini	      httpd_t, user_t, vs
ls -Z, stat -Z	      Dosyanın SELinux type’ı	         httpd_sys_content_t, vs