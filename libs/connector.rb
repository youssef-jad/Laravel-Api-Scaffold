=begin
Author : Youssef Jad
=end
# This class will handle Database Connecting and getting Tables columns
begin
  require 'mysql2'
  require 'fileutils'
  require 'yaml'
rescue Exception => e
  puts e

end
class Connector
  @@client

  def initialize (localhost, userName, password , dataBase )
    begin
      self::connect(localhost , userName , password , dataBase)
    rescue Exception => e
      puts e
    end
  end

  def connect (host , userName , password , databaseName)
    begin
      @@client = Mysql2::Client.new(:host => host, :username => userName , :password => password, :database => databaseName)
    rescue Exception => e
        puts e
    end
  end

  def getTableColumns (tableName)
    tableObj =  @@client.query("SHOW COLUMNS FROM #{tableName};")
    return tableObj
  end

  def getAllTables
    tableObj =  @@client.query("SHOW tables;")
    return tableObj
  end

end



