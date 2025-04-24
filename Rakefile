# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'

Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/test_*.rb']
  t.verbose = true
end

desc "Run all examples"
task :examples do
  puts "Running examples..."
  example_files = FileList['examples/*.rb']
  example_files.each do |example|
    puts "\nRunning #{example}:"
    sh "ruby -Ilib #{example}"
  end
  puts "\nExamples finished."
end

task default: :test
