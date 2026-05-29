# Day 16: Install and Configure Nginx as an LBR

## Objective

The goal is to configure the Load Balancer (LBR) server (`stlb01`) to distribute incoming traffic across the three application servers (`stapp01`, `stapp02`, and `stapp03`) using Nginx as a reverse proxy.


## 1. Verified Backend Service (App Servers)
Before configuring the load balancer, we verified the state of the Apache (`httpd`) service on the backend app servers. 

```bash
ssh tony@stapp01
sudo systemctl status httpd
sudo ss -tulnp | grep httpd
```

**Observation:**
Apache was running successfully, but troubleshooting revealed it was listening on port **`6200`**. An initial attempt to connect to port `3002` resulted in a "Connection Refused" error, and the LBR initially returned a **502 Bad Gateway** because of this port mismatch.


## 2. Installed Nginx on LBR Server
We logged into the LBR server to ensure Nginx was installed and up to date.

```bash
ssh loki@stlb01
sudo yum install -y nginx
```


## 3. Configured Load Balancing in `nginx.conf`
Following the requirement to use only the main configuration file, we edited `/etc/nginx/nginx.conf` within the `http` context to define the backend pool and the proxy settings.

```bash
sudo vi /etc/nginx/nginx.conf
```

**Key Configuration Added:**
Inside the `http` block, we defined the **upstream** group and updated the **server** block:

```nginx
http {
    upstream backend {
        server stapp01:6200;
        server stapp02:6200;
        server stapp03:6200;
    }

    server {
        listen 80;
        location / {
            proxy_pass http://backend;
        }
    }
}
```

- **`upstream`**: Groups the application servers together under a single alias (`backend`).
- **`proxy_pass`**: Instructs Nginx to take any request coming into port 80 and forward it to one of the servers in the backend pool.


## 4. Validated and Applied Configuration
We tested the configuration for syntax errors and then restarted the service to apply the load-balancing logic.

```bash
sudo nginx -t
sudo systemctl restart nginx
sudo systemctl enable nginx
```


## 5. Final Verification
From the **Jump Host**, we performed a `curl` request to the Load Balancer's hostname on port 80.

```bash
curl http://stlb01:80
```

### Result
The Load Balancer successfully communicated with the backend app servers and returned the site content:
```text
Welcome to xFusionCorp Industries!
```

The high-availability stack is now fully operational, with traffic being balanced correctly across all application nodes.


## Screenshot

![day-16-screenshot](day-16-screenshot.png)