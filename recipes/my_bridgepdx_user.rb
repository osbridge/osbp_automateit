# Setup a bridgepdx user

# Create user
account_manager.add_user(default_user)

# Grant web server rights to user's group
account_manager.add_groups_to_user([default_group], 'www-data')
