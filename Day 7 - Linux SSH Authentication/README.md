# Day 7: Linux SSH Authentication

## Objective

Configure passwordless SSH access from user `thor` on the jump host server to all the 3 app servers using SSH key authentication


Once set up SSH key authentication replaces passwords with cryptographic proof:

* Private key stays on the client (jump host)
* Public key is stored on the server
* Login is validated without typing a password


## The `.ssh` Folder

### On Jump Host (Client)

Located at:

```bash
~/.ssh/
```

Contains:

* `id_ed25519`: **Secret** Private key
* `id_ed25519.pub`: Public key (this is shared with servers)
* `known_hosts`: Stores fingerprints of servers we connected to (our machine (initiating SSH) stores server fingerprint on first connection to prevent connecting to fake servers used to trust servers identity)

### On App Servers (Server Side)

Located at:

```bash
~/.ssh/authorized_keys
```

Contains: a list of all allowed public keys for login


## SSH Authentication Flow

1. We run:

```bash
ssh tony@stapp01
```

2. Server checks:

* It looks inside `authorized_keys`
* Finds stored public keys

3. Client responds: proves it owns the matching private key by sending a cryptographic signature

4. Server verifies: the server tries to verify this cryptographic signature using its stored public keys in authorized_keys and if one of the stored public keys verifies it that means it's authorized so login is allowed

## Method 1 - Automated

### Step 1: Generate key on jump host

```bash
ssh-keygen
```

### Step 2: Copy key to server

```bash
ssh-copy-id tony@stapp01
ssh-copy-id steve@stapp02
ssh-copy-id banner@stapp03
```

### What it does internally:

* Connects using password once
* Appends our public key into the servers `authorized_keys`

## Method 2 - Manual Setup

### Step 1: Generate key on jump host

```bash
ssh-keygen
```

### Step 2: Show public key

```bash
cat ~/.ssh/id_ed25519.pub
```

### Step 3: SSH into each server

```bash
ssh tony@stapp01
```

### Step 4: On server

```bash
mkdir -p ~/.ssh
vi ~/.ssh/authorized_keys
```

Paste the public key inside the file

### Step 5: Fix permissions

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```