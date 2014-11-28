# encoding: utf-8

require 'active_record'

class DB
	@dbconfig = YAML.load File.read("db.yaml")
	ActiveRecord::Base.establish_connection(@dbconfig[:database])
	
	class Repository < ActiveRecord::Base
		self.table_name = "repository"
	end
end
