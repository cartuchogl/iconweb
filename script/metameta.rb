# cleaning full working copy
# => git reset --hard HEAD && git clean -f -d -x
# Meta-meta programing the world!!
class Parsers
  def process(key,value)
    value[0,1] != '*' ? "#{key}:#{value}" : parse(key,value)
  end
  
  def parse(key,value)
    send(value[1,2].to_sym,key,value)
  end
  
  def bt(key,value)
    "#{key}_id:integer"
  end
  
  def hm(key,value)
    nil
  end
end

parsers = Parsers.new

metatable = [{
  #rails generate scaffold Unit 
  'Unit' => [
    {:name => 'string'},
    {:position => 'string'},
    {:exp => 'integer'},
    {:level => 'integer'},
    {:name_unit => 'string'},
    {:faction_name => 'string'},
    {:cost => 'integer'},
    {:move => 'integer'},
    {:force => 'integer'},
    {:resistance => 'integer'},
    {:agility => 'integer'},
    {:skill => 'integer'},
    {:intelligence => 'integer'},
    {:primary => '*bt(Weapon)'},
    {:secondary => '*bt(Weapon)'},
    {:squadron => '*bt(Squadron)'}
    
  ]},{
  
  'Weapon' => [
    {:name => 'string'},
    {:cost => 'integer'},
    {:damage => 'string'},
    {:clip => 'integer'},
    {:total => 'integer'},
    {:vshort => 'integer'},
    {:vshort_bonus => 'integer'},
    {:vshort_damage => 'string'},
    {:short => 'integer'},
    {:short_bonus => 'integer'},
    {:short_damage => 'string'},
    {:long => 'integer'},
    {:long_bonus => 'integer'},
    {:long_damage => 'string'},
    {:vlong => 'integer'},
    {:vlong_bonus => 'integer'},
    {:vlong_damage => 'string'}
  ]},{
  
  'Squadron' => [
    {:name => 'string'},
    {:player => '*bt(User)'}
  ]},{
  
  'Game' => [
    {:squadron1 => '*bt(Squadron)'},
    {:squadron2 => '*bt(Squadron)'},
    {:turns => '*hm(Turn)'}
  ]},{
  
  'Turn' => [
    {:game => '*bt(Game)'},
    {:moves => '*hm(Move)'},
    {:fires => '*hm(Fire)'}
  ]},{
  
  'Move' => [
    {:unit => '*bt(Unit)'},
    {:x => 'float'},
    {:y => 'float'},
    {:turn => '*bt(Turn)'}
  ]},{
  
  'Fire' => [
    {:orig => '*bt(Unit)'},
    {:dest => '*bt(Unit)'},
    {:distance => 'integer'},
    {:dice => 'integer'},
    {:coverage => 'float'},
    {:turn => '*bt(Turn)'},
    {:damage => 'integer'}
  ]
}]

metametanames = []

metatable.each do |item|
  name = item.keys.first
  cmd = "rails g scaffold #{name} "
  metametanames << "#{name}"
  item[item.keys.first].each { |prop| cmd += parsers.process(prop.keys.first,prop[prop.keys.first]).to_s+" " }
  puts cmd
  `#{cmd}`
end

puts `rake db:migrate`

metatable.each do |item|
  cmd = "rails g web_app_theme:themed #{item.keys.first}s --engine=haml --force"
  puts cmd
  puts `#{cmd}`
end

metametainfo = ["METAMETAINFO = ["]

metametanames.each do |name|
  metametainfo << "['#{name}',#{name.downcase}s_path],"
  lines = File.open("app/controllers/#{name.downcase}s_controller.rb").readlines
  lines.insert(1,"  before_filter :authenticate_user!\n")
  File.open("app/controllers/#{name.downcase}s_controller.rb", 'w') {|f| f.write(lines.join) }
end

metametainfo << "]"

File.open("config/metametainfo.rb", 'w') {|f| f.write(metametainfo.join("\n")) }

