# Day 13: IPtables Installation And Configuration

## Objective

Secure the Apache service on all App Servers in the Stratos Datacenter. The goal is to restrict access to Apache's custom port (**3004**) so that **only** the Load Balancer (LBR) can reach it, while blocking all other external traffic.

This adds a critical security layer to the Nautilus infrastructure by implementing a "Default Drop" policy for sensitive application ports.


## 1. Installed `iptables` Services

```bash
sudo yum install -y iptables-services
sudo systemctl enable iptables
sudo systemctl start iptables
```


## 2. Identified LBR (Load Balancer) IP

To allow specific access, we first logged into the LBR server (**stlb01**) to find its internal IP address.

```bash
# On stlb01
ip a
```
**LBR IP Found:** `10.244.81.31`


## 3. Configured Firewall Rules (Order Matters)

In `iptables`, rules are processed from **top to bottom**. If a "REJECT" or "DROP" rule exists at the top, any "ACCEPT" rule added below it will be ignored.

### Step A: Check existing rules

```bash
sudo iptables -L INPUT --line-numbers
```
*Many default configurations have a `REJECT all` rule at the end (usually line 5 or 6). We must insert our "Allow" rule **above** that.

### Step B: Insert the "Allow" rule for LBR

Instead of using `-A` like we did at first (Append), we use `-I` (Insert) at a specific line number to ensure it sits above the rejection rules.
```bash
sudo iptables -I INPUT 5 -p tcp -s 10.244.81.31 --dport 3004 -j ACCEPT
```

### Step C: Append the "Drop" rule

Once the LBR is allowed, we block everyone else from that specific port.
```bash
sudo iptables -A INPUT -p tcp --dport 3004 -j DROP
```


## 4. Ensured Persistence Across Reboots

By default, `iptables` rules are stored in memory and vanish after a reboot. To meet the requirement, we must save the current memory state to the configuration file.

```bash
sudo iptables-save | sudo tee /etc/sysconfig/iptables
```
This command takes the active rules and writes them to `/etc/sysconfig/iptables`, which the `iptables-services` reads during the boot process.


## 5. Verified Connectivity

### From Jump Host (Should be Blocked):
```bash
telnet stapp01 3004
```
**Result:** `telnet: connect to address 10.244.153.142: No route to host` (Success - Blocked).

### From LBR Host (Should be Allowed):
```bash
# SSH into stlb01 first
telnet stapp01 3004
```
**Result:** `Connected to stapp01.` (Success - Allowed).


## Screenshot
![day-13-screenshot](day-13-screenshot.png)