# Day 14: Linux Process Troubleshooting

## Objective

Identify and resolve an issue where the Apache service is reported down on one of the app servers in the Stratos Datacenter. Ensure Apache is running on port **3002** across all three app servers (`stapp01`, `stapp02`, and `stapp03`) and set to start automatically on boot.


## 1. Identified the Faulty Host

We performed a status check across the application servers to find the service failure.

```bash
ssh tony@stapp01
sudo systemctl status httpd
```

**Observation on stapp01:**
The service was in a `failed` state. The logs showed the following error:
`Address already in use: AH00072: make_sock: could not bind to address [::]:3002`


## 2. Investigated the Port Conflict

To identify which process was blocking Apache from starting on port `3002`, we used the socket statistics tool.

```bash
sudo ss -tulnp | grep 3002
```

**Finding:**
The `sendmail` service was bound to `127.0.0.1:3002`. Since Apache was configured to listen on the same port, it could not start.


## 3. Resolved the Conflict and Started Apache

We stopped the conflicting service and enabled Apache to ensure it remains running after a reboot.

```bash
# Stop and disable the conflicting service
sudo systemctl stop sendmail
sudo systemctl disable sendmail

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd
```

**Why this works:**
By stopping `sendmail`, we freed up port `3002`. Using `enable` creates a symlink in the systemd multi-user target, ensuring the web server starts automatically if the server is restarted.


## 4. Verified Configuration on stapp02 and stapp03

We checked the remaining servers to ensure they were correctly configured on port `3002`.

```bash
# On stapp02 and stapp03
sudo systemctl status httpd
sudo ss -tulnp | grep httpd
```

**Observation:**
Apache was already active on `stapp02` and `stapp03` listening on port `3002`. We ensured they were also set to `enabled` to satisfy the persistent run requirement.


## 5. Final Connectivity Test

From the **Jump Host** and the **LBR (stlb01)**, we used `telnet` to verify that port `3002` was open and accepting connections on all three hosts.

```bash
telnet stapp01 3002
telnet stapp02 3002
telnet stapp03 3002
```

### Result
All servers returned a **"Connected"** status:
```text
Trying 10.244.240.176...
Connected to stapp01.
Escape character is '^]'.
```

The issue is resolved: the conflicting service was removed, and Apache is now standardized on port 3002 across the entire fleet.


## Screenshot

![day-14-screenshot](day-14-screenshot.png)