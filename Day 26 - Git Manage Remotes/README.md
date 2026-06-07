# Day 26: Git Manage Remotes

## Objective
The goal of this task was to update the remote configuration for an existing Git repository on the Storage Server (`ststor01`), add new content, and push changes to a secondary development remote.


## 1. Added New Git Remote
We navigated to the local repository and added a new remote named `dev_blog` pointing to a different bare repository on the same server. This allows the team to push code to multiple destinations (e.g., a production origin and a development remote).

```bash
cd /usr/src/kodekloudrepos/blog
sudo git remote add dev_blog /opt/xfusioncorp_blog.git
```


## 2. Updated Repository Content
We updated the `master` branch by introducing a new index file provided in the temporary directory.

```bash
# Copy the updated file into the repo
sudo cp /tmp/index.html .

# Stage and commit the change
sudo git add index.html
sudo git commit -m "Add index.html"
```


## 3. Pushed Changes to New Remote
Finally, we pushed the updated `master` branch to the newly created `dev_blog` remote.

```bash
sudo git push dev_blog master
```


## 4. Verification
We verified the remote configuration to ensure both the original `origin` and the new `dev_blog` remotes are correctly mapped.

```bash
sudo git remote -v
```

**Result:**
The repository now tracks two remotes. The `master` branch was successfully updated with the new `index.html` file and synchronized with the development repository.


## Screenshot
![day-26-screenshot](day-26-screenshot.png)