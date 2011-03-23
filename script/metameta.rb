# cleaning full working copy
# => git reset --hard HEAD && git clean -f -d
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

metatable = 
{
  #rails generate scaffold Unit 
  'Unit' => {
    :position => 'string',
    :exp => 'integer',
    :level => 'integer',
    :name => 'string',
    :name_unit => 'string',
    :faction_name => 'string',
    :cost => 'integer',
    :move => 'integer',
    :force => 'integer',
    :resistance => 'integer',
    :agility => 'integer',
    :skill => 'integer',
    :intelligence => 'integer',
    :primary => '*bt(Weapon)',
    :secondary => '*bt(Weapon)'
  },
  
  'Weapon' => {
    :name => 'string',
    :cost => 'integer',
    :damage => 'string',
    :clip => 'integer',
    :total => 'integer',
    :vshort => 'integer',
    :vshort_bonus => 'integer',
    :vshort_damage => 'string',
    :short => 'integer',
    :short_bonus => 'integer',
    :short_damage => 'string',
    :long => 'integer',
    :long_bonus => 'integer',
    :long_damage => 'string',
    :vlong => 'integer',
    :vlong_bonus => 'integer',
    :vlong_damage => 'string'
  },
  
  'Squadron' => {
    :name => 'string',
    :player => '*bt(User)'
  },
  
  'Game' => {
    :squadron1 => '*bt(Squadron)',
    :squadron2 => '*bt(Squadron)',
    :turns => '*hm(Turn)'
  },
  
  'Turn' => {
    :game => '*bt(Game)',
    :moves => '*hm(Move)',
    :fires => '*hm(Fire)'
  },
  
  'Move' => {
    :unit => '*bt(Unit)',
    :x => 'float',
    :y => 'float',
    :turn => '*bt(Turn)'
  },
  
  'Fire' => {
    :orig => '*bt(Unit)',
    :dest => '*bt(Unit)',
    :distance => 'integer',
    :dice => 'integer',
    :coverage => 'float',
    :turn => '*bt(Turn)',
    :damage => 'integer'
  }
  
}

metatable.each do |key, value|
  cmd = "rails g scaffold #{key} "
  value.each { |k,v| cmd += parsers.process(k,v).to_s+" " }
  puts cmd
  `#{cmd}`
end

`rake db:migrate`

metatable.each do |key, value|
  cmd = "rails g web_app_theme:themed #{key}s --engine=haml --force"
  puts cmd
  puts `#{cmd}`
end
