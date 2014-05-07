## Runit init scripts for void

This repository holds the version of runit that is used by Void Linux. It
incorporates patches that fix issues found by users as well as certain compiler
warnings.

The source history was obtained from <http://smarden.org/git/runit.git/>, but
the release tarballs have been pruned from this version.

The objective of this repository is not to revamp the runit code completely or
add functionality that detracts from its simplicity, but rather to provide a
canonical version of the source code and to avoid the inclusion of patches in
[void-packages](https://github.com/void-linux/void-packages). This also makes
reviewing patches much simpler. If you have an issue or patch that you feel fits
inside these objectives, please open an issue or pull request!

This is loosely based on https://github.com/chneukirchen/ignite but with the
difference that I'm trying to avoid the bash dependency.

### How to use it

    # xbps-install -Sy runit-void
    
Append `init=/usr/bin/runit-init` to the kernel cmdline, I'd suggest you to use `/etc/default/grub`:

    ...
    GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 init=/usr/bin/runit-init"
    ...
    
and then update GRUB's configuration file:

    # update-grub

To reboot after making the change, you'll need to use the previous init tool "systemd" 
reboot command directly.  From a command shell, as root run:

    # systemctl reboot

After the reboot runit will kick in and start services in "default" runlevel (multi-user).

To see enabled services for "current" runlevel:

    $ ls /var/service

To see available runlevels (default and single, which just runs sulogin):

    $ ls /etc/runit/runsvdir

To enable and start a service into the "current" runlevel:

    # ln -s /etc/sv/<service> /var/service

To disable and remove a service:

    # rm -f /var/service/<service>

Feel free to send patches and contribute with improvements and/or new services!
