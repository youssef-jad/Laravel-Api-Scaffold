=begin
Author : Youssef Jad
=end
begin
  load 'libs/connector.rb'
  load 'libs/generator.rb'
  require 'colorize'
rescue LoadError => e
  raise e.inspect
end

class Scaffold < Connector

  @@Columns = []
  @@tableName = String

  def initialize
    #  Get Database Configs from Yml File
    cnf = YAML::load_file(File.join(__dir__, 'config.yml'))
    begin
      @@db = Connector.new(cnf['host'].to_s, cnf['username'], cnf['password'], cnf['database'])
    rescue Exception => e
      puts e
    end
  end

  def setTableName tableName
      tableName["\n"] = ''
      @@tableName = tableName
  end

  def getTableName
    name = @@tableName
  end

  def generator
    tables = self.getAllTables

    puts "========= Tables =========\n"
    tables.each do |line|
      printf "--"
      puts line["#{hashKey tables }"]
    end
    puts "=======================\n"

    puts "Please Type a Table Name To Make A Module For it : ".light_red
    tableName = gets
    self.setTableName tableName
    verifyTable(tables)

    columns = @@db.getTableColumns("#{self.getTableName}")
    # generate Module Dir
    # generate Module Files
    # write Model
    # write recourse`s Route File
    # write Controller File
    generate  = Generator.new columns , self.getTableName
    generate.makeDirectories

  end

  def hashKey tables
    hashKey = tables.fields.to_s
    hashKey["["] = ''
    hashKey['"'] = ''
    hashKey["]"] = ''
    hashKey['"'] = ''
    return hashKey
  end

  def verifyTable  tables
    tablesArr = []
    tables.each do |table|
      tablesArr = tablesArr.push(table["#{hashKey tables }"])
    end
    if tablesArr.include?(getTableName) == false
      puts 'Table Not Found Kindly Choose Right Table'
      input = '-----Reloading-----'
      input.each_char { |c|
        print c
        sleep(0.1)
      }
      sleep 3
      load 'api-scaffold.rb'
    end

  end

end

puts " .----------------.  .----------------.  .----------------.
| .--------------. || .------------ --. || .--------------. |
| |   _____      | || |      __      | || |    _______   | |
| |  |_   _|     | || |     /  \\     | || |   /  ___  |  | |
| |    | |       | || |    / /\\ \\    | || |  |  (__ \\_|  | |
| |    | |   _   | || |   / ____ \\   | || |   '.___`-.   | |
| |   _| |__/ |  | || | _/ /    \\ \\_ | || |  |`\\____) |  | |
| |  |________|  | || ||____|  |____|| || |  |_______.'  | |
| |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------'
  ".red
puts "#{'Laravel'.yellow} #{'API'.blue} #{'Scaffolding'.red} - #{'Youssef Jad - KSI - V.0.1'.colorize(:color => :yellow, :background => :light_black) }"
scaffold = Scaffold.new
scaffold.generator


