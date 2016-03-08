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
* [`man upl`](#man-upl)


## Lab Overview:

Lists UPL servers and the services on them that perform tasks essential to running the lab.

### Eris
#### The main server in the UPL
* Home directories (NFS) 
  * Home directories provided to all other UPL machines via NFS
  * /home
* Home directory backups as well
  * In /home_backup
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
* Runs Ubuntu with an emulator wrapper (RetroArch)
* To add a game:
 * Download your favorite ROM and unzip in terminal using `unzip` <ROM>
 * Move the unziped ROM to the `games` directory and in the correct directory (eg. N64)(you can use the visual file explorer to do this)
 * Open up the `RetroArch` and scan the directory where you put the unziped ROM
 * Go to the emulator for that ROM and it should now be in that list.
 * If not in list, go to `load content` in the main menu of `RetroArch` and load the ROM from its directory 

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
1. Have the user sign up sheet handy
2. Ensure that they have a CSL account (if not, send e-mail to lab?)
3. Run `sudo upl-admin`, and follow the prompts
4. Log into the [CSL authenticated web pages](https://www-auth.cs.wisc.edu/forms/) as user `upluse` and add the UPL bit there. (It will claim it failed, but it's not true) you should have the password, if not, start by obtaining it.
5. Add the user to the upl-users mailing list. You should have the password. If not, start by obtaining it
  * [Go to the cs mailman](https://lists.cs.wisc.edu/mailman/admin/upl-users)
  * Access the "admin interface". Login.
  * Open up the "Membership Management".
  * Click on the "Mass Subscription".
  * Add users to the mailing list, one per line.
    * The options are "Subscribe", Send Welcome Message should be "Yes", Send Notifications of new subscriptions to the list owner should be "No".

## Adding a Coord

Similarly, run `sudo upl-admin`, and follow the prompts.

Now add them to the coords mailing list by going to https://lists.cs.wisc.edu/mailman/admin/upl-coords, signing in, clicking on Member Management, then Mass Subscription, then typing in the e-mail address of the new coord. 

___Then have them meet with Bart, get an after-hour pass, and get an OD Key.___

## Removing a Coord

Run `sudo upl-admin`, and follow the prompts.

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

## `man upl`

__"READ THE MANPAGE!"__

This is a user-contributed `man` page for new UPL users to become better acquainted with the lab and its facilities.
Please see the directory `man-upl` for content and the `man` page generation script.

To generate (or update) the `upl` manpage entry, just run:

```bash
$ bash generate-upl-manpage.sh
```

If you are interested in contributing to the effort or have input, please let us know by speaking with a coord or filing an issue on [GitHub](https://github.com/UW-UPL/Documentation).
