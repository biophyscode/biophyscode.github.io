require 'html-proofer'

#! you must build to _site/{{ site.baseurl }} from config.yml
task :test do
  sh "bundle exec jekyll build -d ./_site/"
  options = { :assume_extension => true, :empty_alt_ignore => true }
  HTMLProofer.check_directory("./_site", options).run
end
