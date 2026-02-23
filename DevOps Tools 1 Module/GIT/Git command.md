# Git Commands Cheat Sheet

## Getting Started with Git

### Check Git Version
```sh
git --version
```
- Displays the installed Git version.

### Configure Git User
```sh
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```
- Sets the user name and email for Git commits.

### Initialize a Repository
```sh
git init
```
- Initializes a new Git repository in the current directory.

---

## Working with Repositories

### Clone a Repository
```sh
git clone <repository_url>
```
- Copies a remote repository to your local machine.

### View Repository Status
```sh
git status
```
- Displays the current state of the working directory and staging area.

### Add Changes to Staging Area
```sh
git add <file>
```
- Stages a specific file for commit.

```sh
git add .
```
- Stages all changes for commit.

### Commit Changes
```sh
git commit -m "Commit message"
```
- Saves staged changes with a descriptive message.

### View Commit History
```sh
git log
```
- Shows the commit history.

---

## Branching and Merging

### Create a New Branch
```sh
git branch <branch_name>
```
- Creates a new branch.

### Switch to a Branch
```sh
git checkout <branch_name>
```
- Moves to the specified branch.

```sh
git switch <branch_name>
```
- Alternative way to switch branches (recommended for newer Git versions).

### Create and Switch to a New Branch
```sh
git checkout -b <branch_name>
```
- Creates a new branch and switches to it.

```sh
git switch -c <branch_name>
```
- Alternative command for newer Git versions.

### Merge a Branch
```sh
git merge <branch_name>
```
- Merges the specified branch into the current branch.

### Delete a Branch
```sh
git branch -d <branch_name>
```
- Deletes a branch after merging.

```sh
git branch -D <branch_name>
```
- Forces deletion of a branch.

---

## Working with Remote Repositories

### Add a Remote Repository
```sh
git remote add origin <repository_url>
```
- Links a local repository to a remote one.

### View Remote URLs
```sh
git remote -v
```
- Displays the remote repository URLs.

### Push Changes to Remote Repository
```sh
git push origin <branch_name>
```
- Pushes committed changes to a remote repository.

### Pull Changes from Remote Repository
```sh
git pull origin <branch_name>
```
- Fetches and merges changes from a remote repository.

### Fetch Changes Without Merging
```sh
git fetch origin
```
- Retrieves updates from the remote repository without merging them.

---

## Undoing Changes

### Undo Last Commit (Keep Changes)
```sh
git reset --soft HEAD~1
```
- Moves HEAD back one commit, keeping the changes staged.

### Undo Last Commit (Discard Changes)
```sh
git reset --hard HEAD~1
```
- Moves HEAD back one commit and deletes all changes.

### Remove a File from Staging Area
```sh
git reset <file>
```
- Unstages a file without deleting changes.

### Restore a File to Last Committed Version
```sh
git checkout -- <file>
```
- Reverts a file to its last committed state.

---

## Stashing Changes

### Save Uncommitted Changes
```sh
git stash
```
- Temporarily saves changes without committing.

### Apply Stashed Changes
```sh
git stash apply
```
- Restores the most recent stash.

### List Stashes
```sh
git stash list
```
- Displays saved stashes.

### Drop a Specific Stash
```sh
git stash drop stash@{0}
```
- Deletes a specific stash.

---

## Additional Resources
For more details, visit the official Git documentation: [Git Docs](https://git-scm.com/doc)
