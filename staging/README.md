# Remote Backup Script
This is a bash script for backing up a specified directory on multiple remote hosts. The script uses rsync to transfer the backup data to the local host, compresses and encrypts the backup data with tar and gpg, and stores the encrypted backup file on the local host.

## Usage
Clone the repository to your local machine:

        git clone https://github.com/yourusername/remote-backup-script.git

Modify the hosts.txt file to specify the list of remote hosts and directories to back up. The format of each line in the file should be:

        user@hostname:/path/to/directory

where user is the username to use for the SSH connection, hostname is the hostname or IP address of the remote host, and /path/to/directory is the path to the directory on the remote host to back up.

(Optional) Modify the exclude-list.txt file to specify a list of files or directories to exclude from the backup. Each line in the file should be a relative path to the file or directory to exclude, e.g.:

        tmp/
        .DS_Store

(Optional) Modify the PASSPHRASE variable in the script to specify a passphrase to use for encrypting the backup.

Run the script:

        ./backup.sh

The script will create a timestamped backup file for each host in the backups directory.

## Restoring a Backup

To restore a backup, follow these steps:

Copy the encrypted backup file(s) for the desired host(s) to the remote host where you want to restore the backup.

Concatenate the backup chunks together using the cat command, decrypt the concatenated backup using gpg, and extract the contents of the backup using tar. For example:

        cat backups/hostname/backup-file.tar.gz.gpg.* | gpg --batch --passphrase mysecretpassphrase -d | tar -xzvf -

Replace hostname with the name of the remote host where the backup was taken, and backup-file.tar.gz.gpg with the name of the encrypted backup file.

## License

This script is released under the MIT License.