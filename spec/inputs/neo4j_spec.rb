require_relative "../spec_helper"
require "logstash/plugin"
require "logstash/json"

describe LogStash::Inputs::Neo4j do

  let(:path)   { "spec/fixtures/graph.db" }

  let(:query)  { "MATCH (p:`Person`)-[r]->(m:`Movie`) WHERE m.released = 2000 RETURN *" }
  let(:plugin) { LogStash::Plugin.lookup("input", "neo4j").new( {"path" => path, "query" => query} ) }

  let(:dummy_client) { double("dummy-neo4j-client") }
  let(:dummy_node) { { :labels => "Movie", :props => {:title=>"The Replacements", :released=>2000, :tagline=>"Pain heals"} } }

  before do
    allow(Neo4jrb::Client).to receive(:open).and_return(dummy_client)
    allow(dummy_client).to receive(:execute_query).and_yield([ OpenStruct.new(dummy_node) ] )
    allow(dummy_client).to receive(:session).and_return( "dummy_session" )
  end

  it "register without errors" do
    expect { plugin.register }.to_not raise_error
  end

  it "teardown without errors" do
    expect { plugin.teardown }.to_not raise_error
  end

  context "event retrieval" do

    let(:logstash_queue) { Queue.new }

    before do
      plugin.register
      plugin.run(logstash_queue)
    end

    it "retrieve data from neo4j" do
      expect(logstash_queue.size).to eq(1)
    end

    it "retrieve data in the expected format" do
      while(!logstash_queue.empty?)
        element = logstash_queue.pop
        message = JSON.parse(element["message"])
        expect(message["props"]["released"]).to eq(2000)
      end
    end
  end
end
