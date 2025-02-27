### 1. Question 1  
#### Why does Jenkins use `/tmp/44444464464644.sh`?  
**Answer:**  
Jenkins often creates temporary shell scripts in the `/tmp` directory when executing build steps. These scripts contain the commands that Jenkins needs to run as part of a job. The reason for using `/tmp` is:  

1. **Temporary Storage:**  
   - The `/tmp` directory is used for temporary files, and many Linux distributions mount it as a `tmpfs` (RAM-based filesystem).  
   - This improves performance since reading/writing in RAM is much faster than on disk.  

2. **Automatic Cleanup:**  
   - The files in `/tmp` are automatically deleted after execution or upon system reboot.  
   - This ensures that unnecessary scripts do not clutter the system.  

3. **Jenkins Execution Process:**  
   - When you define a shell script or command in a Jenkins job, Jenkins generates a temporary script file (e.g., `/tmp/44444464464644.sh`).  
   - It executes the script and then deletes it to keep the system clean.  

