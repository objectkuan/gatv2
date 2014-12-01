# encoding: utf-8

require 'active_record'
require 'DB.rb'
require 'open3'
require 'test_in_docker.rb'

class Scheduler
	attr_reader :name
	attr_reader :local_dir, :remote_url
	attr_reader :repo
	attr_reader :tools

	# Initialize from the YAML configuration
	def initialize 
	end

	# Return the object as a string
	def to_s
	end

	# Return whether the repository is clone successfully
	def built
	end

	def pull
	end

	# Return the HEAD of the local repository
	def head
	end
	
	# Pick one to-test repository according to some rule
	def pick_one
		repo = DB::Repository.where("last_commit != head_commit").order(:last_time).first
		repo
	end

	# Perform a testing
	def test remote_url, head_commit, tool, testbox, tool_options
		puts "Perform testing with #{remote_url}:#{head_commit} with #{tool} in #{testbox} - #{tool_options.inspect}"
		case testbox
		when "docker"
			puts "Fetching docker"
			test_in_docker remote_url, head_commit, tool, *tool_options
		when "kvm"
			puts "Fetching kvm"
		when "host"
			puts "Fetching host"
		else
			puts "Cannot find #{testbox}"
		end
	end
end
