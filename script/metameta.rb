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
  
  # belongs_to :object, :class_name => "Object", :foreign_key => "object_id"
  def bt_model(key,value)
    mdl = value[4..-2]
    if mdl.empty? then
      "  belongs_to :#{key}"
    else
      "  belongs_to :#{key}, :class_name => '#{mdl}'"
    end
  end
  
  # has_many :objects, :class_name => "object", :foreign_key => "reference_id"
  def hm_model(key,value)
    mdl = value[4..-2]
    if mdl.empty? then
      "  has_many :#{key}"
    else
      "  has_many :#{key}, :class_name => '#{mdl}'"
    end
  end
  
  def parse_model(key,value)
    send((value[1,2]+"_model").to_sym,key,value)
  end
  
  def process_model(key,value)
    value[0,1] != '*' ? nil : parse_model(key,value)
  end
  
  def do_the_heavy_work(metatable)
    metametanames = []

    puts "\n-=:[First generate basic scaffold]:=-"
    metatable.each do |item|
      name = item.keys.first
      cmd = "rails g scaffold #{name} "
      metametanames << "#{name}"
      item[item.keys.first].each { |prop| cmd += process(prop.keys.first,prop[prop.keys.first]).to_s+" " }
      puts cmd
      puts `#{cmd}`
    end

    puts "\n-=:[Migrate the database]:=-"
    puts `rake db:migrate`

    puts "\n-=:[web-app-themized]:=-"
    metatable.each do |item|
      cmd = "rails g web_app_theme:themed #{item.keys.first}s --engine=haml --force"
      puts cmd
      puts `#{cmd}`
    end

    metametainfo = ["METAMETAINFO = ["]

    puts "\n-=:[Make new controllers to restricted access]:=-"
    metametanames.each do |name|
      metametainfo << "['#{name}',#{name.downcase}s_path],"
      lines = File.open("app/controllers/#{name.downcase}s_controller.rb").readlines
      lines.insert(1,"  before_filter :authenticate_user!\n")
      File.open("app/controllers/#{name.downcase}s_controller.rb", 'w') {|f| f.write(lines.join) }
    end

    metametainfo << "]"

    puts "\n-=:[Write metainfo of paths for menu]:=-"
    File.open("config/metametainfo.rb", 'w') {|f| f.write(metametainfo.join("\n")) }

    puts "\n-=:[Add relations to models]:=-"
    metatable.each do |item|
      name = item.keys.first
      relations = []
      item[item.keys.first].each { |prop| 
        relations << process_model(prop.keys.first,prop[prop.keys.first]) 
      }
      relations.compact!
      unless relations.empty?
        lines = File.open("app/models/#{name.downcase}.rb").readlines
        lines.insert(1,relations.join("\n")+"\n")
        File.open("app/models/#{name.downcase}.rb", 'w') {|f| f.write(lines.join) }
      end
    end
  end
end

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
    {:squadron => '*bt()'}
    
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
    {:turns => '*hm()'}
  ]},{
  
  'Turn' => [
    {:game => '*bt()'},
    {:moves => '*hm()'},
    {:fires => '*hm()'}
  ]},{
  
  'Move' => [
    {:unit => '*bt()'},
    {:x => 'float'},
    {:y => 'float'},
    {:turn => '*bt()'}
  ]},{
  
  'Fire' => [
    {:orig => '*bt(Unit)'},
    {:dest => '*bt(Unit)'},
    {:distance => 'integer'},
    {:dice => 'integer'},
    {:coverage => 'float'},
    {:turn => '*bt()'},
    {:damage => 'integer'}
  ]
}]

Parsers.new.do_the_heavy_work(metatable)

