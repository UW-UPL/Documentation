# Documentation
Documentation on running the UPL. Pull requests and the like are welcomed. 


Table of Contents:
* [Eris - The main server in the UPL](#eris)
* [Siren - Naming / IP responsibilities](#siren)
* [Spearow - Apache webserver](#spearow)
* [Chiptunes - Music server](#chiptunes)
* [General Configuration](#general-configuration)
* [Helpful installed packages](#helpful-installed-packages)
* [Adding a User](#adding-a-user)
* [Common Problems](#common-problems)
* [TODO](#todo)


## Lab Overview:

Lists UPL servers and the services on them that perform tasks essential to running the lab.

### Eris
#### The main server in the UPL
* Home directories (NFS) 
  * Home directories provided to all other UPL machines via NFS
  * /home
* Home directory backups as well
  * In /home_backup
* Postgres Database of Users / their status as member, coord, etc
  * Python scripts use this to generate needed files for linux functionality
* AFS Connection
  * Mounts a network drive of the CSL lab so we an read out valid CS users. 
* Webcam
  * Webcam control server
    * Runs out of /webcam folder on eris
    * Started by a line in /etc/rc.local on eris
    * These changes to rc.local should be moved so that cfengine enforces them, but I’m lazy
  * Webcam stream
    * Runs out of /webcam folder on eris
    * Started by a line in /etc/rc.local on eris
    * These changes to rc.local should be moved so that cfengine enforces them, but I’m lazy

### Siren
#### Naming / IP responsibilities
* Bind9
  * DNS Server, basically allows us to use machine names instead of ip addresses
*Isc_dhcp_server
  * DHCP server, hands certain machines fixed ip addresses
    * We own a nice block of IPV4 IP addresses
  * Is really dumb and doesn’t always start right automatically
    * “hacky fix” in place for this, I ensure it is started with a line in /etc/rc.local on siren

### Spearow
#### Apache Webserver
* Serves the UPL Website / Knowledgebase
* Should also serve websites people have set up in their ~username/Public folders, but this has been broken for a little while. 
  * Might be a good first thing for someone to tackle and fix.

### Chiptunes
#### Music server
* Mpd: music player daemon
  * The backend that actually plays music over the stereo
* Ncmpcpp: the nice frontend
  * A frontend to mpd, its how we tell mpd what to play
  * To add music:
   * `cp` or `scp` album to the `/music` directory of `chiptunes`
   * Open `ncmpcpp` and type `u` to update the collection
   * __PLEASE ONLY PUT LEGAL COPIES ONTO CHIPTUNES!__
   * If your addition did not register with `ncmpcpp`, try `chmod`ing it
* Pianobar: Pandora internet radio music player
  * Sign in with your Pandora account, and crank the tunes


## General Configuration
* Lives in ~upl/newconfig/files/cfmaster
  * Self explanatory, takes out actions on groups of machines (defined in cf.group)
  * Actions are defined in the other cf.* files
    * Cf.main is the most important one
  * REALLY THOROUGHLY LOOK THROUGH AND UNDERSTAND THESE FILES
    * A lot of what they do is copy files to places
* Kerberos
  * System that allows people in the CSL to log in with their CS user / pass
  * We base our login off of that as well, look through the cf configs for references to a Kerberos config file, then read that.
* Cron Jobs
  * Cron is what ensures tasks run at certain times. All cron jobs are defined in cf.main
    * File backups (happen at 1am)
    * Package updating, upgrading (happens at 1am)
    * Cfagent (a  helper program that checks for cfengine configuration changes)
      * Runs on every machine every 5 minutes
      * This is why adding a user can take 5 minutes to propagate and work



## Helpful installed packages
### Most (if not all machines) have these packages installed to help run the lab

* Nfs_common – necessary for a machine to load homefolders
* Fail2ban – stops China and Russia from endlessly bruteforcing logins on our machines
  * Ip bans them for a few hours if they fuck around too much
* Libpam_krb5 – package enabling Kerberos authentication so people can log in with their CS credentials
  * Contacts CS’s Kerberos server (Kerberos.cs.wisc.edu) to auth users
* Cfengine2 – cfengine, the package that really enforces machine “state” and configuration



## Adding a User
1. Have the user sign up sheet handy (We should put that up here...)
2. Ensure that they have a CSL account(if not, send e-mail to lab?)
3. Log onto eris and become root 'su'
4. Navigate to ~upl/bin
5. Run adduser.py
6. Follow the prompts. Be careful, the script doesn't handle bad input well
7. Log into the [CSL authenticated web pages](https://www-auth.cs.wisc.edu/forms/) as user `upluse` and add the UPL bit there. (It will claim it failed, but it's not true) you should have the password, if not, start by obtaining it.
8. Add the user to the upl-users mailing list. You should have the password. If not, start by obtaining it
  * [Go to the cs mailman](https://lists.cs.wisc.edu/mailman/admin/upl-users)
  * Access the "admin interface". Login.
  * Open up the "Membership Management".
  * Click on the "Mass Subscription".
  * Add users to the mailing list, one per line.
    * The options are "Subscribe", Send Welcome Message should be "Yes", Send Notifications of new subscriptions to the list owner should be "No".



## Common Problems:

* KnowledgeBase
  * I can’t sign in to the Spearow knowledgebase, or page editing gives an error.
    * Disk is out of space on Spearow, probably need to clear /var/log

* Adding User
  * When adding a user, I get an error from adduser.py saying a file reports “Resource unavailable”
    * I LITERALLY have no idea why this happens, but you must take additional measures to ensure the user is added and can log in.
      * At the end of running, adduser.py runs three other python files, you must now run them manually, ( sudo ./script_here.py) on eris
        * Export_group.py	- takes care of user groups
        * Export_passwd.py 	- exports passwd file (for linux login)
        * Install_passwd.py 	- puts passwd file in correct place for login
      * If any of the three scripts failed, I think it means that file is locked by something. If you’re more linuxy than I am, there are things that can be done to see what is locking a file.
      * Waiting a few minutes, then trying again, or trying to open the file in nano is usually enough to “unstick it”, then you can run it as a python script again
    * Now you have to manually create the user’s home directory, this is EZ
      * Sudo mkhomedir_helper usernamehere

* The music server is playing a song, but I can't hear it
  * Did you make sure the cords are plugged in?
    * When the power goes out, the actual stereo in the server rack gets reset.
    * In order to reset, click the function button until you're on the 'aux' channel

# TODO
- Nick is working on these.
  - Refactor wording of this doc.
  - Add NUAF.
  - Once documentation is legit, create physical repo in the room.
- Fix user websites not being served correctly.
