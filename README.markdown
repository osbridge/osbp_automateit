[Open Source Bridge Portland](http://bridgepdx.org/)

AutomateIt recipes for setting up OSBP servers
==============================================

Summary
-------

These files represent all the configurations and commands needed to setup the OSBP servers. For instructions on using them, read the README files in the various directories and the documentation at [http://automateit.org/](http://automateit.org/)


Secrets
-------

The publicly-available source code **does not** contain a vital file called `config/secrets.yml`, which contains passwords and other sensitive information. The [config/secrets.yml.sample](config/secrets.yml.sample) file provides an example of this file's structure and content.


Bootstrap
---------

To setup AutomateIt, you will need to run the shell commands in the [bootstrap.sh](bootstrap.sh) file. Once the machine is bootstrapped, you can apply the recipes by running `rake`, or apply individual recipes using commands like `automateit recipe/base_apache.rb`.


Development
-----------

You should always develop recipes on a temporary virtual machine, never on the production servers. You will typically run the temporary VM on your development desktop or notebook computer using a program like [VMware](http://vmware.com/) or [Virtualbox](http://virtualbox.org/).

A special set of development environment preparation commands will help make it easier to create and update recipes by letting you edit files directly on your development machine, and save you from downloading binary packages repeatedly.

> **WARNING!** DO NOT RUN THESE COMMANDS ON PRODUCTION SERVERS! These instructions are only intended for use on development virtual machines.

> **WARNING!** DO NOT RUN THESE COMMANDS AS-IS! Your computer will have different paths, you must change the paths.

Your development virtual machine should contain a pristine copy of Ubuntu 8.04 Server and you should take a VM snapshot of it before making any changes so that you can revert to a clean slate. You'll want to read the instructions in the [devprep.sh](devprep.sh) file and follow them to prepare your development VM.


License
-------

This software is provided under an MIT License, see [LICENSE.txt](LICENSE.txt) for further
information.
