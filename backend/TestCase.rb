# encoding: utf-8

require 'json'
require 'active_record'
require 'DB.rb'

class TestCase
	attr_reader :name
	attr_reader :local_dir, :remote_url
	attr_reader :repo
	attr_reader :tools

	# Initialize from the YAML configuration
	def initialize config
		# Read in data
		@name = config[:name]
		@remote_url = config[:remote_url]
		@local_dir = File.join $GAT_REPOS, config[:name]
		@tools = Hash.new
		config[:tools].each do |tool|
			@tools[tool[1]] = [ tool[0], *(tool[2..-1]) ]
		end

		FileUtils.mkdir_p @local_dir
		Dir.chdir @local_dir
		
		# Pull the remote repository
		begin
			@repo = Rugged::Repository.new(@local_dir)
		rescue
			`git clone #{@remote_url} . >/dev/null 2>&1`
			unless $?.exitstatus == 0
				puts "Fail to clone #{@remote_url}"
				@repo = nil
			end
		end
	end

	# Return the object as a string
	def to_s
		s = "[#{@name}] - [#{@local_dir}] \n"
		s += "\t[#{@repo.head.target_id}]: \n"
		s += "\t#{@repo.head.target.message}\n"
		s += @tools.inspect
		s
	end

	# Return whether the repository is clone successfully
	def built
		(@repo != nil)
	end

	def pull
		tmpdir = Dir.pwd
		Dir.chdir @local_dir
		`git pull >/dev/null 2>&1`
		Dir.chdir tmpdir
	end

	# Return the HEAD of the local repository
	def head
		@repo.head
	end
	
	def record_commit
		@tools.each do |tool, settings|
			db_repo = DB::Repository.find_by(name: @name, tool: tool)
			if db_repo
				# Such repo exists in previous test
				#puts "Yes #{@name}"
				db_repo.head_commit = @repo.head.target_id
				db_repo.head_time = Time.now
				db_repo.tool = tool
				db_repo.testbox = settings[0]
				db_repo.tool_options = JSON.generate(settings[1..-1])
				db_repo.save
			else
				# No reocrd of such repo
				#puts "No #{@name}"
				DB::Repository.create(
					:name => @name,
					:remote_url => @remote_url,
					:head_commit => @repo.head.target_id,
					:head_time => Time.now,
					:tool => tool,
					:testbox => settings[0],
					:tool_options => JSON.generate(settings[1..-1]) 
				);
			end
		end
	end
end
