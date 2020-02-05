# UPL: The Dark Age

> We stand in the ruins of a long lost lab. Technological
> marvels whirl and buzz, beyond our limited understanding.
> This is an age of dusk and darkness. The sun has set, and all the wizards gone.
>
> We seek to restore honor to this sacred shrine! To cast out ignorance from
> these hallowed lands Bart bestowed upon us.
> We will fight to the dying daybreak for the glory of a new age!


### TODO

- [x] fix run machines/servers/unmanaged
- [ ] remove 2 redundant UPL-CONFIGs from siren
- [ ] identify redudant bash scripts
- [ ] translate cutil to bash
- [ ] remove symlinks in config
- [ ] change manifests to newline delims
- [ ] test knowledge: add a new machine
- [ ] write man file

### Assorted Notes

DHCP config has lots of expired leases?
Leases way out of date? Check what date eris thinks it is?

gennet.c uses obsolete network call gethostbyname, use getaddrinfo

machine-deploy is the KEY TO ALL OF THIS.
HOW TO SETUP NFS?

Machine-deploy/setup-fstab mentions
gen-nfs-exports must be run on eris, then do mount -a to mount nfs
from /etc/fstab, using local dns names

maintain is a user with no-password sudo. The 'home' is /srv/maintain.
`/home/` and `/srv/maintain/` are mounted through NFS using `fstab` files

Documentation/readme.md differs from upl-config/network/readme.md
Both have important info the other lacks.

look through the configuration in
`/UPL-Config/docker/bind9/data/webmin/etc/*`
what's all this?

Old commit in documentation mentions

> if network doens't work on machine plugged in,
> try restarting siren

AFS remains a stretch goal. The NFS system should work. Reasons to switch
