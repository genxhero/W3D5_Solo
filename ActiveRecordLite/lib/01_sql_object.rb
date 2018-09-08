require_relative 'db_connection'
require 'active_support/inflector'
require 'byebug'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns
    # debugger
    return @cols if @cols.nil? == false
    cols =  DBConnection.execute2(<<-SQL)
      SELECT *
      FROM  #{self.table_name}
      SQL
    @cols = cols[0].map {|el| el.to_sym}
  end

  def self.finalize!
    self.columns.each do |col|
      define_method("#{col}=") do |val|
        @attributes[col] = val
        # instance_variable_set("#{col}", val)
      end
    end

    self.columns.each do |col|
       define_method(col) do
         @attributes[col]
         # instance_variable_get("@#{col}")
       end
    end


  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    "#{self}s".downcase
  end

  def self.all
    arr =  DBConnection.execute(<<-SQL)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
     SQL
     self.parse_all(arr)
     #arr.each {|hash| SQLObject.parse_all(hash)}
  end

  def self.mew
    puts "MEOW!!!!"
  end

  def self.parse_all(results)
    results.map { |result| self.new(result) }
  end

  def self.find(id)
    result =  DBConnection.execute(<<-SQL, id)
      SELECT #{self.table_name}.*
      FROM #{self.table_name}
      WHERE id = ?
     SQL
     puts "The first element of result is #{result[0]},  a #{result[0].class}"
     return nil if result.empty?
     obj = self.new(result[0])
  end

  def initialize(params = {})
    self.attributes
    params.each do |key, value|
      symbol = key.to_sym
      self.class.instance_methods.include?(symbol) ? self.send("#{key}=", value) : (raise "unknown attribute \'#{key}\'")
    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
#     I wrote a SQLObject#attribute_values method that returns an array
#of the values for each attribute. I did this by calling Array#map on SQLObject::columns,
#calling send on the instance to get the value.
# Once you have the #attribute_values method working, I passed this into DBConnection.execute
#using the splat operator.
    arr = []
    @attributes.each { |k, v| arr << v }
    arr
  end

  def insert
     col_names = self.class.columns.join(',')
    q_marks = (["?"] * col_names.length).join(',')
    DBConnection.execute(<<-SQL,  *col_names, *attribute_values, q_marks)
      INSERT INTO
      debugger
      #{self.class.table_name} (col_names)
      VALUES
      (q_marks)
    SQL
  end

  def update
    # ...
  end

  def save
    # ...
  end

end
