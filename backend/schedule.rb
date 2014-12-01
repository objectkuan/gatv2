#!/usr/bin/env ruby
# encoding: utf-8

require 'active_record'
require 'rugged'
require 'fileutils'
require 'yaml'
YAML::ENGINE.yamler = 'psych'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'env.rb'
require "Scheduler.rb"

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
	
	# We have a scheduler
	sched = Scheduler.new
	loop do
		repo = sched.pick_one
		if repo
			# If there exists one repo to test
			puts repo

			#repo.last_commit = repo.head_commit
			repo.save

			# TODO: Test it !
			tool_options = JSON.parse(repo.tool_options)
			sched.test repo.remote_url, repo.head_commit, repo.tool, repo.testbox, tool_options
			
			repo.last_time = Time.now
			repo.save
		end
		sleep 3
	end
end

if __FILE__ == $0
	startme
end

