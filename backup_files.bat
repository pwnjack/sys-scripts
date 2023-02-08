@echo off

rem Set the folder to be backed up
set folder="C:\Program Files (x86)\PrivateArk"

rem Set the passphrase for encrypting the archive
set passphrase="INSERT-PASSPHRASE-HERE"

rem Set the name of the archive file, including the hostname and timestamp
set hostname=%COMPUTERNAME%
set timestamp=%date:~10,4%%date:~4,2%%date:~7,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set archive=D:\backups\%hostname%_%timestamp%.7z

rem Create the encrypted archive
"C:\Program Files\7-Zip\7z.exe" a -p%passphrase% %archive% %folder%

rem Set the path to the private key file
set keyfile=C:\Users\Administrator\Scripts\bck_key.ppk

rem Push the archive to the remote Linux server using the private key for authentication
pscp -i %keyfile% %archive% backups@10.128.0.9:/exporter_IN/backups

rem Remove the local copy of the .zip file
del %archive%