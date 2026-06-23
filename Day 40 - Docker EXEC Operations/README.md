# Day 40: Docker EXEC Operations


## Objective
The objective was to finalize a pending task on App Server 2 (`stapp02`) by installing and configuring Apache within a running Docker container named `kkloud`. The web server needed to be reconfigured to listen on a non-standard port (**3001**) for all network interfaces.


## 1. Accessed the Target Container
Logged into App Server 2 and entered the interactive bash shell of the running container.

```bash
ssh steve@stapp02
sudo docker exec -it kkloud bash
```


## 2. Installed Apache2
Updated the local package index and installed the Apache HTTP server using the `apt` package manager.

```bash
apt update
apt install -y apache2
```


## 3. Configured Custom Listen Port
By default, Apache listens on port 80. To meet the requirement, we modified the configuration files to use port **3001**.

**Update the main ports configuration:**
```bash
sed -i 's/Listen 80/Listen 3001/' /etc/apache2/ports.conf
```

**Update the default VirtualHost configuration:**
```bash
sed -i 's/:80/:3001/' /etc/apache2/sites-available/000-default.conf
```

**Verification:**
Used `grep` to confirm that the port changes were applied correctly in both files.


## 4. Initialized and Verified Service
Started the Apache service and confirmed its operational status.

```bash
service apache2 start
service apache2 status
```

**Result:** The output confirmed `* apache2 is running`.


## 5. Final State Verification
After exiting the container, we verified that the container remained in a running state as required.

```bash
exit
sudo docker ps
```

**Result:**
The container `kkloud` remains **Up**, successfully hosting the Apache service on the internal port 3001.


## Screenshot
![day-40-screenshot](day-40-screenshot.png)