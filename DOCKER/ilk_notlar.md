[Ansible, Teraform, Openshift, OpenStack]
# BASIC DOCKER COMMANDS
------------------------------
```bash
git config --global user.name "Enver Onder Uslu"
git config --global user.email "enveronderuslu@gmail.com"
sudo usermod -aG docker enver && reboot
docker version                  # Show Docker version  
docker info                     # Display system-wide information  
docker images                   # List available images  
docker ps                       # List running containers  
docker ps -a                    # List all containers 
docker pull <image>             # Download an image from a registry  
docker run <image>              # Run a container from an image  
docker run -it ubuntu bash      # Start interactive terminal inside a container  
docker run -d -p 8080:80 nginx  # Run container in background  
docker stop <id>                # Stop a running container  
docker rm <id>                  # Remove a container  
docker rmi <image_id>           # Remove an image  
docker logs <id>                # Show logs from a container  
docker exec -it <id> bash       # Access a running container's shell
docker container (image network volume) inspect <id> # objeyle ilgili detayli bilgiler verilir
docker (container image volume, network) prune   
# Remove stopped containers unused images volumes networks
docker system prune -a          # calisanlar haric herseyi siler
```

```bash 
docker container run --name cont4  -p 8080:8080  -it -v alistirmavol:'/test alpine sh
``` 
Aciklama: alpin den cont4 isimli bir container  olusturup icine sh ile girip alistirmavol isimli volume u test klasörüne bagladik. -it terminal üzerinden interaktif bicimde container ile konus. Özellikle bash veya sh gibi shell komutlarıyla içine girerken çok kullanılır.

```bash
docker container run --rm <container_name> # --rm container kapatilinca otomatik sil denmek

alias drm="docker stop \$(docker ps -aq)"
alias drm="docker rm \$(docker ps -aq)" 
# (ACHTUNG AQ: Burada \ isaretini tirnak icinde kullanirsin . Dolar isaretu düz metin olarak algilanmali. Normal kod olarak calistiracaksan ´)
```
Copy a file into a container:
`docker cp ./file.txt <id>:/target`

Ping another container (in the same Docker network):
docker exec -it <id> ping <other_container_name>

container icine giris cikis zor diye:
```bash
docker container logs <container_name>
docker container top <container_name>
docker container stats # host üzerinde calisan tüm containerlar
docker container stats <con> # host üzeriindeki con containeri 
--memory=limit # ile ram kullanimini sinirlayabilirsin. 
--memory-swap=limit # ram kullanimi asarsa swap icin yer ayarlanabilir
--cpus="1.5" # sadece 1.5  tane cpu kullanacak
```
# WHAT IS DOCKER?
----------------------
Build Once, Run Anywhere

Image: A read-only template. A linux without kernel. A Blueprint. 
Container: A running instance of an image in an isolated environment  
Dockerfile: Script file used to define and build Docker images  
Volume: Persistent storage for data that survives container removal  
Registry: A server to store and share Docker images (e.g., Docker Hub)

# DOCKERFILE
----------------------
Example Dockerfile for a Python Flask app:

```bash
FROM python:3.9-slim  
WORKDIR /app  
COPY requirements.txt .  
RUN pip install -r requirements.txt  
COPY . .  
CMD ["python", "app.py"]
```
Build the image:
```bash
docker build -t myflaskapp
```

## Commands and Entrypoints

docker file `CMD sleep 9`yazarsan cnteynir 5 snye durur sonra sonlanir. Peki bu süreyi kullanicinin belirlemesini istersen  napmalisin-; Bu defa  `Docker File icinde ÈNTRYPOINT sleep` yazarsinn ve kullanici contexniriri run larken mesela sona  5 verine 10 yazar. ve alet bu defa 10 saniye bekler. 

# VOLUMES & Bind Mount
------------------------------
```bash
docker volume create firstvolume # Create a volume with 
docker volume ls # List existing volumes
docker volume inspect firstvolume # View detailed info 
```
Attaching a Volume to a Container
```bash
docker container run -it -v <vplume_name_Host>:/folder_in_container <image> sh
```
`-v firstvolume:/the_folder_in_container:ro` seklinde de olur. One volume can be shared by multiple containers simultaneously. You can mount a host folder directly into the container:
### örnek
```bash
docker run -v $(pwd):/app ubuntu
docker run -d -v  ~/websitesi:/usr/share/nginx/html nginx
```
Son örnekte nginx html ve lokaldeki websitesi dosyalarini mount ettim ve artik icerigi lokalden cekiyor. zirt pirt iceri girmek zorunda kalmiyorum

# NETWORK
------------------------------
```bash
docker network ls 
docker network inspect bridge
docker container run -it --net host  <container> # Default yerine host network kullanildi. Böylece izolasyon kalkti ve üzerinde calistigi makineyle ayni agdaymis gibi calisti.
```

## CASE STUDY
sever da container lari gruplamak ve gruplar arasinda keine Verbindung istiyorum. O zaman birden fazla bridge network gerekir.Ayrica default bridge network icinde birbirlerinin isimlerini cözemezler. Napalim AQ?

Create a custom network:
subnet1/2 olusturup iclerine  websunucu1/2 va database1/2 koyacaz
```bash
docker network create subnet1 
docker network ls
docker network create subnet2
docker network inspect subnet1  subnet2
docker container run -dit --name  websunucu1 --net subnet1  <id>
docker container run -dit --name  database1 --net subnet1  <id> 
docker container exec -it websunucu1 bash
docker container run -dit --name  websunucu2 --net subnet2  <id>
docker container run -dit --name  database2 --net subnet2  <id>
# veya iceri gireceksen
docker container exec -it websunucu2 sh 
ping database2` # calisir
ping websunucu 1` # calismaz. farkli networkteler
```

bir container üretilen bir subnet e baglanirmi
```bash
docker network connect subnet1 websunucu2 # (disconnect de mümkün)
```

docker container run -d -p 8081:80 --name  deneme  <id>
Açıklama:
`-p <host_port>:<container_port>`
Yani: Soldaki 8081 → senin Kali (host) sistemindeki port Sağdaki 80 → container içindeki port 80

# DOCKER COMPOSE
------------------------------
Example docker-compose.yml:
```yaml
version: "3"  
services:  
  app:  
    build: .  
    ports:  
      - "5000:5000"  
  redis:  
    image: "redis:alpine"
```

Commands:
```bash
docker-compose up             # Start services  
docker-compose down           # Stop and remove services  
docker-compose build          # Build services from Dockerfile
```

# ENVIROMENT VARIABLES
-------------------------------------------

Environment variables are values defined at the operating system level, accessible globally by applications and processes.  In contrast, variables defined inside a programming language (e.g., a Python script) are only valid within that local scope.

## Windows
List environment variables: `Get-ChildItem Env:`
Example: If the HOME variable is set to \Users\enver, running ` cd $HOME` will navigate to your home directory.
Create a new variable: `Env:LOCATION="C:\Users\enver\Desktop"`

## Linux
List environment variables: `printenv`
Create a new variable: 

```bash
export TESTVAR="/home/kali/Desktop/inventory"
```
Make a variable permanent: Add the export command to your ~/.bashrc file, then reload: 
```bash
source  ~/.bashrc
```
## Docker
Create a container with a single environment variable:
```bash
docker run -it -d --env VAR1=testvalue1 ubuntu
```
Create a container using an environment file:
```bash
docker run -it --env-file /home/kali/envlist ubuntu sh # This automatically assigns all variables listed in the file to the container.
```
Practical Example: Instead of hardcoding a web application's background color, define a variable such as APP_COLOR and change its value as needed. Check a container's environment variables: 
```bash
docker inspect <container_name>
```
Run a container with a specific APP_COLOR:
```bash
docker run -p 80:80 -e APP_COLOR=blue -d <container_name>
```
This sets the application's background color to blue without modifying the code.,