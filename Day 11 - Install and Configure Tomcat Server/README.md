# Day 11: Install and Configure Tomcat Server

## Objective

Install and configure `Apache Tomcat` on App Server 2 to host the provided Java web application.
Configure Tomcat to run on port `8089`, and deploy the provided `ROOT.war` application, and ensuring the application is accessible directly from the base URL.

`Apache Tomcat` is a Java application server used to run Java web applications.

It provides a runtime environment that:
- receives HTTP requests
- executes Java web applications
- returns responses to users


## 1. Connected to App Server 2 and installed Apache Tomcat

```bash
ssh steve@stapp02
sudo yum install -y tomcat
```

## 2. Located Tomcat Configuration Files

```bash
/etc/tomcat/server.xml
```

This is the main configuration file for Tomcat, It defines HTTP ports, server connectors, deployment behavior


## 3. Changed Tomcat Port to 8089

Edited:

```bash
sudo vi /etc/tomcat/server.xml
```

Changed:

```bash
<Connector port="8080"
```

to:

```bash
<Connector port="8089"
```

A Connector is the Tomcat component that:
- listens for incoming HTTP requests
- forwards them into Tomcat applications

Default port is `8080`, but the task required `8089`


## 4. Copied Application WAR File

From Jump Host:

```bash
scp /tmp/ROOT.war steve@stapp02:/tmp/
```

A `.war` (Web Application Archive) is a packaged Java web application containing:
- backend Java code
- frontend files (HTML/CSS/JS)
- configuration and libraries

It is deployed into a servlet container like Tomcat


## 5. Deployed the Application

In App Server 2
```bash
sudo cp /tmp/ROOT.war /usr/share/tomcat/webapps/
```


`/webapps/` is Tomcat’s deployment directory. Any `.war` placed here is automatically extracted, deployed and made accessible via HTTP


`ROOT.war` matters because Tomcat maps WAR filenames to URL paths:
- `app.war` -> `/app`
- `shop.war` -> `/shop`

But:

```bash
ROOT.war
```

is special and becomes:

```bash
/
```

So it is accessible directly at the base URL


## 6. Started and Enabled Tomcat

```bash
sudo systemctl start tomcat
sudo systemctl enable tomcat
```

## 7. Tested Application

Locally:
```bash
curl http://localhost:8089
```

### Result
HTML page returned:
```html
<h2>Welcome to xFusionCorp Industries!</h2>
```

From Jump Host
```bash
curl http://stapp02:8089
```

Same HTML response returned successfully deployment fully successful


## Screenshot

![day-11-screenshot](day-11-screenshot.png)