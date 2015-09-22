require_relative "../spec_helper"

describe "Neo4jrb::Client", :integration => true do

  let(:client) { Neo4jrb::Client.open(temp_db_path) }

  it "can count all nodes within the database" do
    expect(client.count_nodes).to eq(2)
  end

  context "while running a query" do
    let(:query) { "MATCH (p:`person`)-->(m:`person`) WHERE p.name = 'personA' RETURN *" }

    subject(:resultset) { client.execute_query(query) }

    it "return the right amount of data" do
      expect(resultset.count).to eq(1)
    end

    it "return the right type of data as array" do
       resultset.each do |result|
         result.map! { |e| e.labels.first }.flatten
         expect(result).to eq([:person, :person])
       end
    end
  end
end
