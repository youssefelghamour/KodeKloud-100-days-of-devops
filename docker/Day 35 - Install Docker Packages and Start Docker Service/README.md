# Day 35: Install Docker Packages and Start Docker Service

## Objective
Enable containerization capabilities on App Server 2 (`stapp02`) by installing the official Docker Community Edition engine and the Docker Compose plugin.

## 1. Configured Repository
Since Docker-CE is not part of the standard AppStream repositories, we added the official Docker yum repository.
```bash
sudo dnf install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

## 2. Installed Docker Stack

```bash
sudo dnf install -y docker-ce docker-compose-plugin
```

## 3. Service Management
We initialized the Docker daemon and configured it to start automatically upon system boot to ensure high availability for containerized applications.
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## 4. Verification
Confirmed the installation by checking the service status and the binary versions.
- **Docker Engine:** Successfully initialized.
- **Docker Compose:** Plugin available for multi-container orchestration.

## Screenshot
![day-35-screenshot](day-35-screenshot.png)