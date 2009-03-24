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

desc "Update recipes from git"
task :update do
  sh "git pull origin master"
end

desc "Upgrade server by pulling changes from git and applying them"
task :upgrade do
  Rake::Task[:update].invoke
  Rake::Task[:all].invoke
end

desc "Generate README as HTML"
file "README.html" => "README.markdown" do
  require 'rubygems'
  require 'maruku'
  File.open("README.html", "w+") do |handle|
    handle.write(Maruku.new(File.read("README.markdown")).to_html_document)
  end
end
