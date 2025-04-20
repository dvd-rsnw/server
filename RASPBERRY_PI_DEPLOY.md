# Raspberry Pi Deployment Guide

This guide will help you set up the NYC Train Status Server on a Raspberry Pi device, configured to be accessed via `server.local:4599`.

## Prerequisites

- Raspberry Pi (3 or newer recommended) with Raspberry Pi OS installed
- Docker and Docker Compose installed on your Raspberry Pi
- Network connectivity

## Installation Steps

### 1. Install Docker and Docker Compose

If you haven't already installed Docker and Docker Compose, run:

```bash
# Update package lists
sudo apt update

# Install dependencies
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the repository (check for Raspberry Pi OS version compatibility)
echo "deb [arch=armhf signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Add your user to the docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo apt install -y docker-compose
```

Log out and log back in for the group changes to take effect.

### 2. Configure server.local Hostname

```bash
# Set hostname to 'server'
sudo hostnamectl set-hostname server

# Edit hosts file
sudo nano /etc/hosts
```

Add or modify the following line:
```
127.0.1.1       server server.local
```

Reboot the Raspberry Pi:
```bash
sudo reboot
```

### 3. Clone the Repository

```bash
git clone https://github.com/yourusername/server.git
cd server
```

### 4. Run the Setup and Start Scripts

```bash
# Make scripts executable
chmod +x setup.sh start.sh

# Run the setup script
./setup.sh

# Start the application
./start.sh
```

## Accessing Your Server

After deployment, you can access your server in these ways:

1. From the Raspberry Pi itself:
   - http://localhost:4599
   - http://server.local:4599

2. From other devices on the same network:
   - http://server.local:4599
   - http://[Raspberry Pi IP address]:4599

For API documentation, visit:
- http://server.local:4599/docs

## Client Device Configuration

For other devices to access your server using the `server.local` domain:

### Method 1: mDNS (Recommended)

Many modern operating systems support mDNS/Bonjour for .local domain resolution:
- macOS: Supported by default
- iOS: Supported by default
- Android: Often supported by default on newer versions
- Windows: Install "Bonjour Print Services" or "iTunes" for .local support
- Linux: Install and enable avahi-daemon (`sudo apt install avahi-daemon`)

### Method 2: Edit hosts file

If mDNS doesn't work, add an entry to the hosts file on client devices:

**For macOS/Linux:**
```bash
sudo nano /etc/hosts
```

**For Windows:**
```
notepad C:\Windows\System32\drivers\etc\hosts
```

Add the following line (replace with your Pi's actual IP address):
```
192.168.1.X     server.local
```

## Troubleshooting

### Checking Service Status

```bash
# View running containers
docker ps

# View logs
docker compose logs -f
```

### Restart Services

```bash
# Restart all services
./start.sh

# Manually restart
docker compose down
docker compose up -d
```

### Network Troubleshooting

```bash
# Find your Pi's IP address
hostname -I

# Test connectivity
ping server.local

# Check if port 4599 is in use
sudo lsof -i :4599
```

### Firewall Issues

If you can't access the server from other devices, check if a firewall is blocking port 4599:

```bash
# Allow port 4599 through the firewall
sudo ufw allow 4599/tcp
``` 