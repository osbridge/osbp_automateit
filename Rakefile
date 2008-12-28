require "automateit"

# Create an Interpreter for project in current directory.
@interpreter = AutomateIt.new(:project => ".")

# Include Interpreter's methods into Rake session.
@interpreter.include_in(self)

task :default => :all

desc "Interactive AutomateIt shell"
task :shell do
  AutomateIt::CLI.run
end

desc "Run recipes"
task :all do
  invoke "all"
end

desc "Preview action, e.g, 'rake preview hello'"
task :preview do
  preview true
end

desc "Update server by pulling changes from git and applying them"
task :update do
  sh "git pull origin master"
  sh "rake"
end
