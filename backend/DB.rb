# encoding: utf-8

require 'active_record'

class DB
	@dbconfig = YAML.load File.read("db.yaml")
	ActiveRecord::Base.establish_connection(@dbconfig[:database])
	
	class Repository < ActiveRecord::Base
		self.table_name = "repository"
		def to_s
			s = "[\n"
			s += "\tid: #{self.id}\n"
			s += "\tname: #{self.name}\n"
			s += "\tremote_url: #{self.remote_url}\n"
			s += "\tlast_commit: #{self.last_commit}\n"
			s += "\thead_commit: #{self.head_commit}\n"
			s += "\tlast_time: #{self.last_time}\n"
			s += "\thead_time: #{self.head_time}\n"
			s += "]"
		end
	end
end
