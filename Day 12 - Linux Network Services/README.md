# Day 12: Linux Network Services

## Objective

Identify and resolve why the Apache service on `stapp01` is not reachable on port `5003` from the jump host. Troubleshoot potential service down-time, port conflicts, or firewall restrictions without compromising security.

Apache (`httpd`) is an open-source HTTP server. It is configured via a configuration file (usually `httpd.conf`) where the `Listen` directive defines which port it uses to serve web traffic.

`telnet` test from the jump host returned **"No route to host"**

## 1. Connected to App Server 1 and Identified Port Conflict

Initially, the Apache service failed to start. Using `netstat`, we identified that another service `sendmail` was using the Port `5003`

```bash
ssh tony@stapp01
sudo netstat -tulnp | grep 5003
```


## 2. Resolved Service Conflict

To allow Apache to use port `5003`, we had to stop the conflicting service and start `httpd`.

```bash
sudo systemctl stop sendmail
sudo systemctl start httpd
sudo systemctl enable httpd
```


## 3. Verified Apache Configuration

We checked the configuration to ensure Apache was explicitly told to listen on the correct port.

```bash
grep -R "Listen" /etc/httpd/conf/httpd.conf
```

**Configuration found:**
```apache
Listen 5003
```


## 4. Troubleshooting Network Connectivity (Firewall)

Even with the service running, a `telnet` test from the jump host returned **"No route to host"**. This indicates that the server's firewall was actively dropping or rejecting packets.

Since `firewall-cmd` was not available, we used `iptables` to manage the kernel-level packet filtering.


## 5. Configured Firewall Rules

We added a specific rule to allow traffic from the jump host (`10.244.247.248`) to port `5003`.

```bash
sudo iptables -I INPUT -s 10.244.247.248 -p tcp --dport 5003 -j ACCEPT
```

**Logic:**
- `-I INPUT`: Inserts the rule at the very top of the chain to ensure it is processed before any global `REJECT` rules.
- `-s 10.244.247.248`: Limits access specifically to the jump host, maintaining security.
- `--dport 5003`: Opens only the specific port required for the application.


## 6. Final Verification

From the **Jump Host**, we verified the fix using `curl`.

```bash
curl -I http://stapp01:5003
```

## Screenshot

![day-12-screenshot](day-12-screenshot.png)