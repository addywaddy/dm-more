require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'lib/dm-ar-finders'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  lib = "do_#{name}"

  begin
    gem lib, '~>0.9.7'
    require lib
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]

    FileUtils.touch LOG_PATH
    DataMapper::Logger.new(LOG_PATH, 0)
    at_exit { DataMapper.logger.close }
    true
  rescue Gem::LoadError => e
    warn "Could not load #{lib}: #{e}"
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'
LOG_PATH     = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')
