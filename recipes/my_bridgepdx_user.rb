# Setup a bridgepdx user

# Create user
account_manager.add_user(default_user)

# Grant web server rights to user's group
account_manager.add_groups_to_user([default_group], 'www-data')

# Setup cron environment
cronedit(default_user) do
  prepend "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin"
  append "# m h  dom mon dow   command"
end
