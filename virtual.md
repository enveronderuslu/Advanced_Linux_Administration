**KVM SANAL MAKİNE KLONLAMA SÜRECİ**
---
 
Adım 1: Sanal Makineyi Hazırlama ve Kapatma

```bash
virsh shutdown kaynak_vm_adi # Kaynak VM'yi Kapat
virsh list --all # VM'nin Durumunu Kontrol
```
Adım 2: Disk İmajını Kopyalama

```bash 
 kaynak_vm_adi # Kaynak Disk Konumunu Bulun:
sudo cp /var/lib/libvirt/images/kaynak.qcow2 /var/lib/libvirt/images/yeni_vm.qcow2 # Diski Yeni Bir İsimle Kopyalayın:
```
Adım 3: hostname, MAC adresi, SSH anahtarları vb.Temizleme (Sysprep)

```bash
sudo virt-sysprep -d yeni_vm.qcow2 --hostname yeni_hostname
# -d yeni_vm.qcow2: İşlem yapılacak disk imajını belirtir.

```

Adım 4: Yeni Sanal Makineyi Tanımlama Kaynak VM Tanımını Dışa Aktarın:

```bash
virsh dumpxml kaynak_vm_adi > yeni_vm.xml 
```
Yeni XML Tanımını Düzenleyin: yeni_vm.xml dosyasını açın ve aşağıdaki temel alanları benzersiz olacak şekilde değiştirin:
<name>: Yeni VM'nin adı (örn. yeni_vm).

<uuid> (<mac address='...'/>:): UUID'yi (MAC adresini) sil. virsh içe aktarma sırasında yeni bir tane oluşturacaktır.

<source file='...'/>: Disk yolunu yeni .qcow2 dosyasıyla değiştir (örn. /var/lib/libvirt/images/yeni_vm.qcow2).

Yeni VM Tanımını İçe Aktarın:

```bash
virsh define yeni_vm.xml
```
