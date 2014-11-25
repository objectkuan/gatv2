# encoding: utf-8

class GitCommit
	attr_reader :name
	attr_reader :local_dir, :remote_url
	attr_reader :repo

	# Initialize from the YAML configuration
	def initialize config
		@name = config[:name]
		@remote_url = config[:remote_url]
		@local_dir = File.join $GAT_REPOS, config[:name]
		FileUtils.mkdir_p @local_dir
		Dir.chdir @local_dir
		
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

	# Print the object as a string
	def to_s
		s = "[#{@name}] - [#{@local_dir}] \n"
		s += "\t[#{@repo.head.target_id}]: \n"
		s += "\t#{@repo.head.target.message}\n"
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

	def head
		@repo.head
	end
end
