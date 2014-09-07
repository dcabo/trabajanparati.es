# See http://djellemah.com/blog/2013/02/27/rails-23-with-ruby-20/
# via http://stackoverflow.com/questions/15349869/undefined-method-source-index-for-gemmodule-nomethoderror

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# monkey patch for 2.0. Will ignore vendor gems.
if RUBY_VERSION >= "2.0.0"
  module Gem
    def self.source_index
      sources
    end

    def self.cache
      sources
    end

    SourceIndex = Specification

    class SourceList
      # If you want vendor gems, this is where to start writing code.
      def search( *args ); []; end
      def each( &block ); end
      include Enumerable
    end
  end
end

Rails::Initializer.run do |config|
  config.gem 'haml'
  # etc
  # maybe some more
  # and so on...

  # Note that iconv is a gem in ruby-2.0
  config.gem 'iconv' if RUBY_VERSION >= "2.0.0"

  # some other config stuff
  # and some more
  # and a little more...
end