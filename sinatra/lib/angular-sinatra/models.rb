require 'sequel'
require 'yaml'

db_params = YAML.load( File.read(__dir__ + '/../../database.yaml') )

connection_string = ""
connection_string << db_params['engine'] << '://'
if db_params['user']
  connection_string << db_params['user']
  if db_params['password']
    connection_string << ':' << db_params['password']
  end
  connection_string << '@'
end
connection_string << db_params['host']
if db_params['port']
  connection_string << ':' << db_params['port']
end
connection_string << '/' << db_params['database']

$db = Sequel.connect(connection_string)

require_relative 'models/user'
