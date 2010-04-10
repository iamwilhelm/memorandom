# Memorandom is a simple memoizer for object attributes
#
# It caches the result of a method into a local variable.  Can only use
# on methods that take no arguments.  The memoized function will take
# on argument called "reload".  Set to true if want to reload
#
#   class Foo
#     def long_calculation
#       @result = some_long_request()
#     end
#     memoize(:long_calculation)
#   end
#
#   foo = Foo.new
#   foo.long_calculation # => Takes a long time calculate value
#   foo.long_calculation # => Now it takes a short time, yay!
#   foo.long_calculation(true) # => Takes a long time again
#
module Memorandom
  def self.included(base)
    base.extend(Memorandom::ClassMethods)
  end
  
  module ClassMethods
    def memoize(method_name, options = {})
      alias_method "unmemoized_#{method_name}", method_name
      define_method(method_name) do |*args|
        reload = args ? args.pop : false
        value = if (reload == true || instance_variable_get("@#{method_name}").nil?)
                  send("unmemoized_#{method_name}")
                else
                  instance_variable_get("@#{method_name}")
                end
        instance_variable_set("@#{method_name}", value)        
      end
      
    end
  end
end

if __FILE__ == $0

  def timer
    start_time = Time.now
    yield
    puts "#{Time.now - start_time} secs elapsed"
  end

  # TODO turn memoize example into a test
  class Foo
    include Memorandom
    
    def expensive
      sleep(2)
      return 42
    end
    memoize :expensive

  end

  foo = Foo.new
  timer do
    puts "result 1: #{foo.expensive}"
    puts "It's slow the first time around to warm up cache"
  end
  puts
  timer do
    puts "result 2: #{foo.expensive}"
    puts "This time, it's cached so it's fast"
  end
  puts
  timer do
    puts "result 2: #{foo.expensive(true)}"
    puts "This time, it's slow, because we reloaded"
  end

end
