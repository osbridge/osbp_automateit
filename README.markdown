AutomateIt recipes for Open Source Bridge
=========================================

Summary
-------

These files represent all the configurations and commands needed to setup the servers for the [Open Source Bridge conference](http://opensourcebridge.org). These files use the [AutomateIt](http://automateit.org/) configuration management system, please read its documentation for details on how to use it because the instructions below will only discuss important customizations.


Secrets
-------

The publicly-available source code for this project **does not** contain a vital file called `config/secrets.yml`, which contains passwords and other sensitive information. You should get this file from from someone that has it or create it yourself using the `config/secrets.yml.sample` file as a reference.


Bootstrap
---------

To create a new server, install [Ubuntu 8.04 Server](http://www.ubuntu.com/getubuntu/download-server) -- you must use this specific version of Ubuntu. Once loaded, copy-and-paste the commands in the `bootstrap.sh` file into the new server's terminal as root to bootstrap AutomateIt. You'll also need to copy in the secrets file before applying the recipes, as the file instructs.


Apply, update and run recipes
-----------------------------

Once bootstrapped, you can run the following commands as root on the new server:

* `aiapply`: Apply all the recipes, handy when developing recipes and you want to apply the changes.
* `aiupgrade`: Pull changes from git repo and apply all the recipes, handy when upgrading a server.
* `ai /var/local/automateit/recipes/base_apt`: Apply a single recipe with the given filename.


Development
-----------

You should always develop recipes on a temporary virtual machine -- never on a production server. You will typically run this temporary virtual machine on your development desktop or notebook computer using software like [VirtualBox](http://virtualbox.org/). You should make a snapshot of the virtual machine after you've installed the base OS, then again once you've applied the recipes, and then again as you make major changes you want to keep -- this way you can easily revert changes without having to reinstall the virtual machine.

A special program called `devprepper.sh` is provided that makes development easier:

* Mounts your recipes so you can edit them on your local computer and apply them remotely to the virtual machine.
* Mounts your APT download cache directory to avoid duplicate downloads.
* Mounts a copy of the AutomateIt source code if available and you wish to use it from source.

To use this program, run `./devprepper.sh` on the local computer you're at, and then copy-and-paste its output to your remote virtual machine's root shell.


License
-------

This software is provided under an MIT License, see `LICENSE.txt` for further information.
