# Install Docker and Docker Compose:

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) \
signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo $VERSION_CODENAME) stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli \
containerd.io docker-buildx-plugin docker-compose-plugin -y
```
## Test Docker installation:

```bash
sudo docker run hello-world
```

# Install Caddy:

```bash 
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
| sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
| sudo tee /etc/apt/sources.list.d/caddy-stable.list

sudo apt update
sudo apt install caddy -y
Edit the Caddyfile configuration file:

sudo nano /etc/caddy/Caddyfile
Enter your domain and configure reverse proxy. Replace "yourdomain.com" with your actual domain name:


:80 {
    reverse_proxy localhost:5678
}

sudo systemctl restart caddy
```

## Deploy n8n with Docker Compose:
```bash
cd ~/n8n
sudo docker compose up -d
```
