= Open Source Bridge Portland - AutomateIt recipes for setting up servers

== Summary

These files represent all the configurations and commands needed to setup the
OSBP servers. For instructions on using them, read the README files in the
various directories and the documentation at http://automateit.org/


== Secrets

The publicly-available source code doesn't contain a vital file called
"config/secrets.yml", which contains passwords and other sensitive information.
The "config/secrets.yml.sample" file provides an example of this file's
structure and content.


== Bootstrap

To setup AutomateIt, you will need to run the shell commands in the
"bootstrap.sh" file.

== Usage

Once the machine is bootstrapped, you can apply the recipes by running "rake",
or apply individual recipes using commands like "automateit
recipe/base_apache.rb".

Once the recipes have been applied, they'll install a pair of handy helper
commands into "/usr/local/bin". Both of these commands accept the same
arguments as the "automateit" command, such as "-n" for enablingpreview mode:

* "aiapply" will apply all the recipes ("/var/local/automateit/recipes/all.rb").
* "aiupgrade" will pull the latest changes from the git repository and apply them.


== Development

You should always develop recipes on a temporary virtual machine, never on the
production servers. You will typically run the temporary VM on your
development desktop or notebook computer using a program like VMware or
Virtualbox.

A special set of development environment preparation commands will help make
it easier to create and update recipes by letting you edit files directly on
your development machine, and save you from downloading binary packages
repeatedly.

    WARNING! DO NOT RUN THESE COMMANDS ON AS-IS OR ON PRODUCTION SERVERS! These
    instructions are only intended for use on development virtual machines.
    Your computer will have different paths, you must change the paths.

Your development virtual machine should contain a pristine copy of Ubuntu 8.04
Server and you should take a VM snapshot of it before making any changes so
that you can revert to a clean slate. You'll want to read the instructions in
the "devprep.sh" file and follow them to prepare your development VM.


== License

This software is provided under an MIT License, see "LICENSE.txt" for further
information.
