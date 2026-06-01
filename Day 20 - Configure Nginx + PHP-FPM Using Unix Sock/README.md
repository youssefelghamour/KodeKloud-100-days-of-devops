# Day 20: Configure Nginx + PHP-FPM Using Unix Sock

## Objective
The goal is to deploy a PHP application on App Server 3 (`stapp03`) in the Stratos Datacenter. Unlike a standard setup, we are connecting the web server (Nginx) to the PHP engine (PHP-FPM) using a **Unix Socket** to maximize performance and security.


## 1. PHP-FPM and Unix Socket

![nginx-php-fpm-unix-socket](nginx-php-fpm-unix-socket.jpeg)

### What is PHP-FPM?
PHP-FPM (FastCGI Process Manager) is the backend process that actually executes PHP code. It's like the **"Gunicorn" of PHP**. Nginx is a high-performance web server, but it cannot read PHP. It acts as a **Reverse Proxy**, receiving HTTP requests and passing them to PHP-FPM to be processed.

### What is a Unix Socket?
A Unix Socket is a special type of file (often with a `.sock` extension) that acts as a **direct "data pipe"** between two programs on the same server.

*   **TCP Port:** Usually, Nginx talks to PHP over `127.0.0.1:9000`. This uses the Linux "Network Stack," which is slower because the server has to handle packet headers and network math, even though the data never leaves the server.
*   **Unix Socket:** Nginx writes data directly into the socket file address, and the Linux Kernel hands it instantly to PHP-FPM's memory. This is faster and more secure because we can use standard Linux **file permissions** to control who can touch the pipe.


## 2. Connected to App Server 3 and Installed Packages
Enabled the PHP 8.3 repository and installed both the web server and the FastCGI process manager.

```bash
ssh banner@stapp03
sudo dnf module enable php:8.3 -y
sudo dnf install -y nginx php-fpm
```


## 3. Prepared the Socket Directory
Because we are using a custom socket path, we must ensure the parent directory exists and has the correct ownership so the services can create and access the socket file.

```bash
sudo mkdir -p /var/run/php-fpm
sudo chown nginx:nginx /var/run/php-fpm
```


## 4. Configured PHP-FPM
Edited the PHP-FPM pool configuration file `/etc/php-fpm.d/www.conf`. We had to ensure the process runs as `nginx` and creates the socket file at the correct path with the correct owner.

**Changes made to `/etc/php-fpm.d/www.conf`:**
```ini
[www]
user = nginx
group = nginx

; Set the path to the Unix Socket
listen = /var/run/php-fpm/default.sock

; Set permissions so Nginx can read/write to the socket
listen.owner = nginx
listen.group = nginx
listen.mode = 0660
```

- `user = nginx` / `group = nginx`: Sets the user the process runs as.
- `listen = /var/run/php-fpm/default.sock`: Tells PHP to create the socket file here.
- `listen.owner = nginx` / `listen.group = nginx`: Allows Nginx to talk through the socket.


## 5. Configured Nginx
Updated the main `/etc/nginx/nginx.conf` file to handle the custom port **8094** and route `.php` requests to the Unix Socket.

**The following block was added to the `http` context:**
```nginx
server {
    listen       8094;
    server_name  _;
    root         /var/www/html;
    index        index.php index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # Pass PHP scripts to PHP-FPM via the Unix Socket
    location ~ \.php$ {
        include fastcgi_params;
        # Tell PHP exactly which file to execute
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        # Link to the socket file
        fastcgi_pass unix:/var/run/php-fpm/default.sock;
    }
}
```


## 6. Troubleshooting and Debugging
During deployment, the initial setup resulted in a **502 Bad Gateway**. So I used a two-step debugging process to resolve this:

### Step 1: Fixing Permission
By running `ls -l`, I saw the socket was owned by `root`. I discovered that the line `listen.acl_users = apache,nginx` in the PHP config was overriding our ownership settings.
- **Fix:** Commented out the ACL line and restarted PHP-FPM. The socket was then correctly owned by `nginx`.

### Step 2: Fixing Config Overrides
The 502 persisted. I checked `/var/log/nginx/error.log` and saw Nginx was trying to connect to `www.sock` (a system default) instead of our `default.sock`.
- **Fix:** I found that a hidden file in `/etc/nginx/default.d/` was overriding our block. I commented out the `include /etc/nginx/default.d/*.conf;` line in the main Nginx config to force it to use our settings.


## 7. Final Verification
From the **Jump Host**, we verified that the Nginx bridge was successfully delivering requests to the PHP engine.

```bash
curl http://stapp03:8094/index.php
```

### Result:
```text
Welcome to xFusionCorp Industries!
```


## Screenshot
![day-20-screenshot](day-20-screenshot.png)