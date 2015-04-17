require "logstash/devutils/rspec/spec_helper"
require "logstash/inputs/neo4j"
require "logstash/inputs/neo4j-client"
require 'ostruct'

def load_fixture(name)
  IO.read("spec/fixtures/#{name}")
end
