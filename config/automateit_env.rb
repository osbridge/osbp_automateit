# Put your environment commands here

set :default_user, "bridgepdx"
set :default_group, "bridgepdx"
set :stow_dir, "/usr/local/stow"
set :apache_manager, ApacheManager.new(self)
set :mysql_manager, MysqlManager.new(self)
set :postgresql_manager, PostgresqlManager.new(self)

#-----------------------------------------------------------------------
#
# == ENVIRONMENT
#
# This is an AutomateIt environment file. Use it to customize AutomateIt
# and provide settings to recipes, interactive shell, or embedded
# Interpreters using this project.
#
# The "self" in this file is an Interpreter instance, so you can execute
# all the same commands that you'd normally put in a recipe.
#
# This file is loaded after the project's tags, fields and libraries.
#
#-----------------------------------------------------------------------
