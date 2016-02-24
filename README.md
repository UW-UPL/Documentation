# Documentation
Documentation on running the UPL. Pull requests and the like are welcomed. 


Table of Contents:
* [Lab Overview](#lab-overview)
  * [Eris - The main server in the UPL](#eris)
  * [Siren - Naming / IP responsibilities](#siren)
  * [Spearow - Apache webserver](#spearow)
  * [Chiptunes - Music server](#chiptunes)
  * [Pepade - Arcade Machine](#pepade)
* [General Configuration](#general-configuration)
* [Helpful installed packages](#helpful-installed-packages)
* [Adding a User](#adding-a-user)
* [Adding a Coord](#adding-a-coord)
* [Removing a Coord](#removing-a-coord)
* [How to Startup the Servers](#starting-up-servers)
* [Common Problems](#common-problems)
* [Book Library](#book-library)


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
* bind9 (transitioning to docker-bind9)
  * DNS Service, basically allows us to use machine names instead of ip addresses
  * Config must be changed via cfengine at `~upl/newconfig/files/BindServer/bind/pri/upl.zone`! 
* docker-dhcp
  * DHCP service, hands certain machines fixed ip addresses
    * We own a nice Class C block of IPV4 IP addresses (`128.105.45.0/32`)
  * Run by `docker` automatically on boot! Adding documentation here shortly on how to work with this.
* Important Notes pertaining to CSL integration
  * It is VERY important that our DNS server (in this case siren) always have the IP address `128.105.45.102`
  * This IP address is whitelisted by CSL's / DoIT's DNS servers (that run cs.wisc.edu)
  * If a different IP is used, dns lookups all fail, and the UPL goes down for 8 hours during finals.
* To change a machine's hostname, edit `~upl/newconfig/files/BindServer/bind/pri/upl.zone` with the appropriate host.
  **Note that this requires a DHCP change as well, as DHCP looks up a computer's MAC addr and assigns it an IP address accordingly. This can be found in /etc/dhcp/dhcpd.conf. BACK THESE UP BEFORE CHANGING THEM!**

### Spearow
#### Apache Webserver
* Serves the UPL Website / Knowledgebase
* Should also serve websites people have set up in their ~username/Public folders

### Chiptunes
#### Music server
* Mpd: music player daemon
  * The backend that actually plays music over the stereo
* Ncmpcpp: the nice frontend
  * A frontend to mpd, its how we tell mpd what to play
  * To add music:
   * `cp` or `scp` album to the `/music` directory of `chiptunes`
   * If it isn't already, the permissions flags should be `755` for the new folder
   * Open `ncmpcpp` and type `u` to update the collection
   * __PLEASE ONLY PUT LEGAL COPIES ONTO CHIPTUNES!__
   * If your addition did not register with `ncmpcpp`, try `chmod`ing it
* Pianobar: Pandora internet radio music player
  * Sign in with your Pandora account, and crank the tunes
  * If you are getting the `TLS fingerprint mismatch` error, you need to [update your config file](https://github.com/PromyLOPh/pianobar/issues/560#issuecomment-161548123)

### Pepade
#### Arcade Machine
* Now runs a distribution of Linux called Lakkos
  * Developed explicitly for running retro games on emulators
* So much more to come regarding configuration and use, while being a linux distribution, it abstracts away many of the more operating system like things
  * Like a terminal...

## General Configuration
* Lives in ~upl/newconfig/cfmaster
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

## Adding a Coord
There are instructions in ~upl/doc under AddingCoord.

Most of the things that go into adding a new coord are done in
`postgres` on `eris`.

To make the nessasary change become root (`sudo -s`) on `eris`.
Now run:

```bash
$ psql upl
```

Get the `userid` of the user you want to make a coord (replace `<user_login>`)

```sql
SELECT  userid  FROM  user_account  WHERE  username = '<user_login>';
```

This returns the `<user_id>`

Add them to the wheel and coord groups, some useful facts are:

```sql
select * from user_group where name in ('coord', 'wheel');
```
```
 groupid |  gid  | name  | userid 
 ---------+-------+-------+--------
       2 | 10001 | coord |      1   
      70 |    10 | wheel |      1  
```

```sql
INSERT INTO user_group_user  ( groupid, userid ) VALUES ( 2, <user_id> );
INSERT INTO user_group_user  ( groupid, userid ) VALUES ( 70, <user_id> );
```

Now you need to give them the coord attribute.

Again, some useful bits of info:

```sql
select * from user_attr_type;
```
```
 attrid |   type   
 --------+----------
      1 | coord
      2 | oldcoord
      3 | locked
      4 | friend
```

```sql
INSERT INTO user_attr ( attrid, userid ) VALUES ( 1, <user_id> );
```

After these steps, exit the database (type `\q` and then hit enter), and (while `root` on `eris`), navigate to `~upl/bin` and run `export_groups.py`. You need to be `root` for this to work, you can't just use sudo. This will update the necessary files, and have them pushed out.

Now add them to the coords mailing list by going to https://lists.cs.wisc.edu/mailman/admin/upl-coords, signing in, clicking on Member Management, then Mass Subscription, then typing in the e-mail address of the new coord. 

___Then have them meet with Bart, get an after-hour pass, and get an OD Key.___

## Removing a Coord

Most of the things that go into removing a new coord are done in
`postgres` on `eris`.

To make the nessasary change become root (`sudo -s`) on `eris`.
Now run:

```bash
$ psql upl
```

Get the `userid` of the user you want to make a coord (replace `<user_login>`)

```sql
SELECT  userid  FROM  user_account  WHERE  username = '<user_login>';
```

This returns the `<user_id>`

Remove them from the wheel and coord groups, some useful facts are:

```sql
select * from user_group where name in ('coord', 'wheel');
```
```
 groupid |  gid  | name  | userid 
 ---------+-------+-------+--------
       2 | 10001 | coord |      1   
      70 |    10 | wheel |      1  
```

Removing them is done as follows:

```sql
DELETE FROM user_group_user WHERE groupid='2' AND userid='<user_id>';
DELETE FROM user_group_user WHERE groupid='70' AND userid='<user_id>';
```

Now you need to remove the coord attribute.

Again, some useful bits of info:

```sql
select * from user_attr_type;
```
```
 attrid |   type   
 --------+----------
      1 | coord
      2 | oldcoord
      3 | locked
      4 | friend
```

```sql
DELETE FROM user_attr WHERE attrid='1' AND userid='<user_id>';
DELETE FROM user_attr WHERE attrid='2' AND userid='<user_id>';
```

After these steps, exit the database (type `\q` and then hit enter), and (while `root` on `eris`), navigate to `~upl/bin` and run `export_groups.py`. You need to be `root` for this to work, you can't just use sudo. This will update the necessary files, and have them pushed out.


## Starting up servers
Machines that need to be turned back on. They are listed **in order they should be started**: 

1. Siren (DHCP, so the computers know of each other and can talk to each other)


2. Eris (home folders)

  *Sometimes need to hit enter for GRUB or F1 to boot. Plug in Monitor and Keyboard to check as you boot up.
    
3. Spearow (web server for upl.cs.wisc.edu)

    *Also sometimes need to hit F1 upon boot.
    
4. Nethack (some game servers, and mumble server)

5. Turn on all other machines

## Common Problems:

### KnowledgeBase
  * I can’t sign in to the Spearow knowledgebase, or page editing gives an error.
    * Disk is out of space on Spearow, probably need to clear /var/log

### Adding User
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

### The music server is playing a song, but I can't hear it
  * Did you make sure the cords are plugged in?
    * When the power goes out, the actual stereo in the server rack gets reset.
    * In order to reset, click the function button until you're on the 'aux' channel

### The internet doesn't work on a machine, even though it is plugged in correctly and connected to a network
  * This may be an issue with Siren issuing IP addresses. This was noticed in 11/15, and after power failure in 12/15 as well
    * This was fixed by restarting Siren.

### I need to print out new user forms, how do I do that?
  * Check the [New User Form folder README](https://github.com/UW-UPL/Documentation/blob/master/New%20User%20Form)

## Book Library
* [Link to the live gdoc](https://docs.google.com/spreadsheets/d/1vvBGUE4_Y-BbBa2enLRiEGEVqUorZEdq1Rb1O8NG4NM/edit?usp=sharing)
* [Printable empty loan sheet](upl-book-loan-sheet.pdf)
* [Open Office accessible loan sheet doc](upl-book-loan-sheet.ods)
