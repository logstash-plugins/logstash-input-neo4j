require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/neo4j"
require "logstash/inputs/neo4j-client"
require "ostruct"
require "fileutils"

def load_fixture(name)
  IO.read("spec/fixtures/#{name}")
end

def temp_db_path
  File.join(Dir.tmpdir, "graphdb")
end

def build_database(path)
  session = ::Neo4j::Session.open(:embedded_db, path, :auto_commit => true)
  session.start
  Neo4j::Transaction.run do
    nodeA = Neo4j::Node.create({name: 'personA'}, :person)
    nodeB = Neo4j::Node.create({name: 'personB'}, :person)
    nodeA.create_rel(:knows, nodeB, since: 2015)
  end
end

def remove_database(path)
  session = Neo4j::Session.current
  session.shutdown
  FileUtils.rm_rf(path)
end

RSpec.configure do |config|
  config.before(:all) do
    build_database(temp_db_path)
  end

  config.after(:all) do
    remove_database(temp_db_path)
  end
end
