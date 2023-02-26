# SSH Backup Script
This bash script performs a backup of specified directories from remote hosts via SSH. It uses rsync to copy the specified directory from each remote host to a local directory named "backups", compresses the backup directory, and encrypts it using gpg with a passphrase specified in the script.

## Prerequisites
- A Unix-like operating system (Linux, macOS, etc.)
rsync and gpg installed on the local machine
- SSH access to the remote hosts and the ability to execute commands on them
- A list of remote hosts and directories to back up in the format ssh_connection_string source_directory, one entry per line in a file named hosts.txt
- Optionally, a list of files or directories to exclude from the backup, one entry per line in a file named exclude-list.txt

## Usage
Modify the following variables in the script to fit your needs:

-  HOSTS_FILE: The path to the file containing the list of remote hosts and directories to back up. By default, this is set to "hosts.txt".

Example:

        user@remotehost1:/path/to/dir1
        user@remotehost2:/path/to/dir2

- PASSPHRASE: The passphrase to use for encrypting the backup files. By default, this is set to "mysecretpassphrase".
- EXCLUDE_FILE: The path to the file containing the list of files or directories to exclude from the backup. By default, this is set to "exclude-list.txt".

Example:

        *.log
        temp/

You can also modify the rsync options to suit your needs. By default, the script uses the options -av --delete to archive and synchronize the remote directory to the local machine, and --exclude-from="${EXCLUDE_FILE}" to exclude files and directories listed in the exclude-list.txt file.

Run the script from the command line:

        bash backup.sh

The script will loop through each remote host specified in hosts.txt, back up the specified directory to a local directory named "backups", compress and encrypt the backup, and save the encrypted backup file in a subdirectory of the "backups" directory named after the hostname of the remote host.

To restore a backup, copy the encrypted backup file to the remote host and run the following command:

        gpg --batch --decrypt --passphrase <PASSPHRASE> <backup_file> | tar -xz -C </destination/directory/>


## File Structure

The script assumes that there is a directory named "backups" in the same directory as the script. The backups will be saved in subdirectories of the "backups" directory named after the hostname of the remote host being backed up. For example, if the backup script is run for a remote host with the hostname "remotehost1", the backup files will be saved in "backups/remotehost1/". If the "backups" directory does not exist, it will be created automatically.
