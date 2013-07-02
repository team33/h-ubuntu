
To prepare [H] Ubuntu image:

1. Execute prepare.sh from current dir -- this will download all the packages
2. Prepare a tarball of current directory
3. Install Ubuntu 12.04.2 (while being connected to the Internet) with the
   following in mind:

     Device size: 7876666368 bytes

     swap: 366*10^6 bytes (beginning) (sda1)
     ext4: rest (sda2)
     Denver / Mountain Time [sic!]
     user:password@host -- horde:team33ftw@horde-changeme

     Do not download updates while installing

4. Boot the image and log in
5. Open a terminal
6. Go to /dev/shm
7. Download tarball from step 2, make sure to specify
   -o UserKnownHostsFile=/dev/null with scp, I use:

     scp -o UserKnownHostsFile=/dev/null user@vmhost:h-ubuntu.tar .

8. Untar
9. Delete the tarball
10. Go to directory containing extracted contents
11. Run ./h.sh and provide sudo password when requested
12. If h.sh is sucessful, perform following steps
13. Run: ulimit -n 0
14. Close the terminal
15. Power-off the machine (from the panel)
16. Zip resulting image
17. You're done!
