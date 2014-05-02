$: << File.expand_path(File.join(File.dirname( __FILE__ ), "../lib"))

require 'libyajl2'

RSpec.configure do |c|

  c.order = 'random'

  c.expect_with :rspec do |c|
    c.syntax = :expect
  end

end
