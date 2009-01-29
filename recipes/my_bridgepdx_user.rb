# Setup a bridgepdx user

# Create user
account_manager.add_user 'bridgepdx'

# Grant web server rights to user's group
account_manager.add_groups_to_user(['bridgepdx'], 'www-data')
