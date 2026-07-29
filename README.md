# 100 Days of DevOps: The Nautilus Project

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-121011?style=for-the-badge&logo=gnubash&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge&logo=git&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=jenkins&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-EE0000?style=for-the-badge&logo=ansible&logoColor=white)
![Terraform](https://img.shields.io/badge/Terraform-844FBA?style=for-the-badge&logo=terraform&logoColor=white)

This repository is my documentation of the **KodeKloud 100 Days of DevOps Challenge**. It serves as a hands-on technical journal of my progress in managing the infrastructure for **xFusionCorp Industries** within the **Stratos Datacenter**.

Each day in this challenge is framed as a real-world ticket for a fictional company (xFusionCorp / Nautilus), simulating the kind of tasks a DevOps engineer might actually be handed on the job, like provisioning a server, fixing a broken deployment, setting up CI/CD, securing access, etc. The goal is practical, ticket-style problem solving.

## Tech Stack
*   **Linux SysAdmin:** User security, process troubleshooting, firewalls, and database management.
*   **Git:** Advanced version control, branching strategies, and server-side automation.
*   **Docker:** Containerization, custom image building, and multi-tier orchestration with Compose.
*   **Kubernetes:** Orchestrating scalable, self-healing applications and persistent storage.
*   **CI/CD:** Automating the software development lifecycle using Jenkins.
*   **Ansible:** Configuration management and automation.
*   **Terraform:** Infrastructure as Code.

## Repository Structure


Each folder contains a `README.md` for each daily challenge including:
1.  **The Objective:** What problem was I trying to solve?
2.  **The Concept:** How does the tool (like a Unix Socket or a Kubernetes Secret) actually work?
3.  **The Resolution:** The exact commands and YAML manifests I used to fix the issue.
4.  **The Journal/screenshots:** Showcasing the implementation of the solution for the task or the troubleshooting steps taken.


### [linux-sysadmin](./linux-sysadmin)
This section covers managing Linux servers and keeping them secure. It involves setting up user access, hardening SSH, and troubleshooting web or database services. I focus on resolving port conflicts, managing traffic with iptables firewalls, and configuring SSL for Nginx. It also includes optimizing local process communication by transitioning from TCP ports to Unix Sockets.

### [git](./git)
This domain focuses on version control and managing the infrastructure that hosts code. It covers maintaining a clean history through rebase and cherry-pick, and collaborating with teams using Pull Requests and forking. I also implemented server-side automation by writing Git hooks to handle tasks like automated version tagging on bare repositories.

### [docker](./docker)
This folder is about moving applications into containers for better portability. I build optimized images using Dockerfiles and ensure data remains persistent by using volumes. It also involves container networking—using macvlan drivers or port mapping—and orchestrating multi-tier stacks (like PHP and MariaDB) using Docker Compose.

### [kubernetes](./kubernetes)
This is for orchestrating containers across a cluster for high availability. I manage application lifecycles using deployments, rolling updates, and rollbacks. I also handle complex storage through PV and PVC resources, manage traffic via NodePort and ClusterIP services, and use specific design patterns like Sidecars for logging and Init Containers for pre-deployment setup.

### [jenkins](./jenkins)
This section is dedicated to automating the CI/CD pipeline. I set up the Jenkins server environment and manage the plugin ecosystem to link source control to the build process. It acts as the central bridge that automatically tests, builds, and prepares applications for deployment whenever code is updated.

### [ansible](./ansible)
This section focuses on configuration management and fleet automation. I use idempotent playbooks to automate repetitive setup tasks across multiple servers at once. This ensures that every server in the environment stays in a consistent state without needing manual configuration on individual machines.

### [terraform](./terraform)
This part is about Infrastructure as Code (IaC). I use configuration files to provision and manage the actual servers, networks, and storage from scratch. This approach allows the entire foundation of the datacenter to be versioned and deployed automatically through code.