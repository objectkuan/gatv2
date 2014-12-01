#!/usr/bin/env ruby
# encoding: utf-8

require 'active_record'
require 'fileutils'
require 'env.rb'


def test_in_docker (*args)
	# Parsing the argument values
	remote_url = args[0]
	head_commit = args[1]
	tool = args[2]
	tool_options = args[3..-1]

	########################
	#  Here Goes the Main  #
	########################
	FileUtils.mkdir_p $GAT_VOLS_DOCKER
	# Create the volumes
	docker_vol = remote_url.gsub! '/', '#'
	docker_vol = "#{docker_vol}##{tool}"
	vol_dir = File.join $GAT_VOLS_DOCKER, docker_vol
	FileUtils.mkdir_p vol_dir
	
	# Before creating a docker, describe an init job
	init_job = "ls -a"

	# Create a Docker
	cmd = "docker run -d -v #{vol_dir}:/opt/vol ubuntu:14.10 /bin/bash -c \"#{init_job}\""
	stdin, stdout, stderr = Open3.popen3(cmd)
	container_id = (stdout.readlines)[0]
	#cmd = "docker logs #{container_id}"
	#stdin, stdout, stderr = Open3.popen3(cmd)
	sleep(1)

	cmd = "docker rm -f #{container_id}"
	stdin, stdout, stderr = Open3.popen3(cmd)

	puts head_commit
	puts tool_options.inspect
	puts cmd


end
