# frozen_string_literal: true

require 'yard'
require 'rake/testtask'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'

task default: %i[rubocop test]

Rake::TestTask.new do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.warning = false
end

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names']
end

