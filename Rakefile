require "automateit"

# Create an Interpreter for project in current directory.
@interpreter = AutomateIt.new(:project => ".")

# Include Interpreter's methods into Rake session.
@interpreter.include_in(self)

task :default => :shell

desc "Interactive AutomateIt shell"
task :shell do
  AutomateIt::CLI.run
end

desc "Run a recipe"
task :hello do
  invoke "hello"
end

desc "Preview action, e.g, 'rake preview hello'"
task :preview do
  preview true
end
