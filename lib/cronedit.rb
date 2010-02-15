# Edit the contab for the given +user+ using the +block+. This is just a
# wrapper around AutomateIt's #edit, accepts the same options and accepts the
# same block of editing instructions. However, this adds helpful logic that
# finds the user's crontab and uses common defaults for performing the edits.
def cronedit(user, opts={}, &block)
  defaults = {
    :path => "/var/spool/cron/crontabs/#{user}",
    :create => true,
    :user => user,
    :group => "crontab",
    :mode => 0600,
  }
  opts = defaults.merge(opts)
  path = opts.delete(:path)

  self.edit(path, opts, &block)
end
