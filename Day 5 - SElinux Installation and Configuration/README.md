# Day 5: SElinux Installation and Configuration

## Objective

Following a security audit, the xFusionCorp Industries security team has opted to enhance application and server security with SELinux. To initiate testing, the following requirements have been established for App server 1 in the Stratos Datacenter:
- Install the required SELinux packages
- Permanently disable SELinux for the time being; it will be re-enabled after necessary configuration changes
- No need to reboot the server, as a scheduled maintenance reboot is already planned for tonight
- Disregard the current status of SELinux via the command line; the final status after the reboot should be disabled

## Steps (App Server 1 only)

1. SSH into server
```bash
ssh tony@stapp01
```

2. Install SELinux packages
```bash
sudo yum install -y selinux-policy selinux-policy-targeted
```

3. Disable SELinux permanently
```bash
sudo vi /etc/selinux/config
```

Change:

```bash
SELINUX=enforcing
```

or:

```bash
SELINUX=permissive
```

To:

```bash
SELINUX=disabled
```

4. Verify configuration
```bash
cat /etc/selinux/config
```

Expected:

```bash
SELINUX=disabled
```

## Screenshots (combined)

![day-5-screenshots](day-5-screenshots.png)