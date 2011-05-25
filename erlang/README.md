# Erlang Scripts - A collection of Erlang scripts #

This directory contains a bunch of scripts that I wrote for my own
convenience that may or may not be useful to others. Feel free to
use them if you like, but many of the scripts run as the root
operator so unless you know what you're doing, leave'em alone. Use
of the scripts in the archive does not imply any responsibility on
the part of the author if you brick your machine.

In other words, read the scripts before you use them and make sure
that you know what you're doing.

Suggestions, improvements, updates, and corrections gratefully
accepted.


>  install-erlang.sh - A script to retrieve and install Erlang and
                      its docs from the main Erlang site. The script
                      also builds the Dialyzer PLT file.
                      The script currently supports Max OS X and
                      Linux.

                      Usage: install-erlang.sh [-w 32 | 64] [-d] vsn

                      -w  - word size (32-bit or 64-bit)
                      -d  - install docs
                      vsn - Erlang version to install (e.g., R14B03)

>                      This script should be run as root unless the user
                      has permissions to write to the the /usr/local
                      directory. The source tarballs are retrieved to
                      /usr/local/src and are unpacked into their own
                      directories under /usr/local/src. Care should be
                      taken to ensure that /usr/local/bin is in the path.
