require "bundler"
Bundler::GemHelper.install_tasks

require "rake"
require "rake/rdoctask"
require "rspec"
require "rspec/core/rake_task"

Rspec::Core::RakeTask.new(:rcov) do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.rcov = true
  t.rcov_opts = ["--exclude", "^spec,/gems/"]
end

Rake::RDocTask.new do |rdoc|
  require File.expand_path("../lib/vidibus-resource/version", __FILE__)
  rdoc.rdoc_dir = "rdoc"
  rdoc.title = "vidibus-resource #{Vidibus::Resource::VERSION}"
  rdoc.rdoc_files.include("README*")
  rdoc.rdoc_files.include("lib/**/*.rb")
  rdoc.options << "--charset=utf-8"
end
