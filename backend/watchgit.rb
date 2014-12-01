#!/usr/bin/env ruby
# encoding: utf-8

require 'active_record'
require 'rugged'
require 'fileutils'
require 'yaml'
YAML::ENGINE.yamler = 'psych'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require "TestCase.rb"
require 'env.rb'

$REPOS = Hash.new

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
				repo = TestCase.new r
				# If test name exists, skip
				if $REPOS[repo.name] != nil
					puts "Duplicated name '#{repo.name}', skip"
					next
				end
				$REPOS[repo.name] = repo if repo.built
			end
		end

		# Write to cache
		$REPOS.each do |name, repo|
			repo.pull
			repo.record_commit
		end

		sleep(3)
	end
end

if __FILE__ == $0
	startme
end

