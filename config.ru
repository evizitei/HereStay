# This file is used by Rack-based servers to start the application.

# require ::File.expand_path("../lib/facebook/params_parser.rb", __FILE__)
# use Facebook::ParamsParser, :coderay, :element => "pre", :pattern => /\A:::(\w+)\s*\n/
require ::File.expand_path('../config/environment',  __FILE__)
run Micasasucasa::Application
