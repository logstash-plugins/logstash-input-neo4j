require "spec_helper"

describe "Neo4jrb::Client", :integration => true do


  let(:path)   { "spec/fixtures/graph.db" }
  let(:client) { Neo4jrb::Client.open(path) }

  it "can count all nodes within the database" do
    expect(client.count_nodes).to eq(171)
  end

  context "while running a query" do
    let(:query) { "MATCH (p:`Person`)-->(m:`Movie`) WHERE m.released = 2000 RETURN *" }

    subject(:resultset) { client.execute_query(query) }

    it "return the right amount of data" do
      expect(resultset.count).to eq(24)
    end

    it "return the right type of data as array" do
       resultset.each do |result|
         result.map! { |e| e.labels.first }.flatten
         expect(result).to eq([:Movie, :Person])
       end
    end
  end
end
