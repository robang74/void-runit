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

runit is used by default in the Void distribution.
    
To see enabled services for "current" runlevel:

    $ ls -l /var/service

To see available runlevels (default and single, which just runs sulogin):

    $ ls -l /etc/runit/runsvdir

To enable and start a service into the "current" runlevel:

    # ln -s /etc/sv/<service> /var/service

To disable and remove a service:

    # rm -f /var/service/<service>

Feel free to send patches and contribute with improvements and/or new services!
