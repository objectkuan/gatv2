#!/usr/bin/env ruby
# encoding: utf-8

require 'rugged'
require 'fileutils'
require 'yaml'
YAML::ENGINE.yamler = 'psych'

# Global variables
#   The source directory of GAT
$ROOT = File.dirname(File.expand_path(__FILE__))
#   The configuration file with repositories
$REPO_CONFIG_FILE = File.join $ROOT, "repos.yaml"
#   The working directory of GAT
$GAT = "/gat/"
$GAT_REPOS = File.join $GAT, "repos/"
#   The Repositories
$REPOS = Hash.new

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "GitCommit.rb"

def md5sum fn
	md5 = `md5sum #{fn}`
	fail if $?.exitstatus != 0
	md5
end

def startme
	# Should be run as root
	user = `whoami`.strip()
	unless user == "root"
		puts "Please run as root" 
		exit
	end
	
	# Create gat direcotry at /
	FileUtils.mkdir_p $GAT_REPOS

	# Load a repo configuration file
	old_config_md5 = nil
	loop do
		exit unless File.exists? $REPO_CONFIG_FILE
		config_md5 = md5sum $REPO_CONFIG_FILE
		if config_md5 != old_config_md5
			# Repository conguration file changed

			# Load Config
			conf = YAML.load File.read($REPO_CONFIG_FILE)
			old_config_md5 = config_md5

			# Create Repos
			repos = conf[:repos]
			repos.each do |r|
				# TODO: What if duplicated names
				repo = GitCommit.new r
				$REPOS[repo.name] = repo if repo.built
			end
		end
	
		# Write to cache
		$REPOS.each do |name, repo|
			repo.pull
			puts name
			puts repo
		end

		sleep(3)
	end
end

if __FILE__ == $0
	startme
end

