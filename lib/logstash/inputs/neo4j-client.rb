# encoding: utf-8
require "neo4j"

module Neo4jrb
  class Client

    def self.open(location)
      session = start_session_at(location)
      Neo4jrb::Client.new(session)
    end

    def count_nodes
      Neo4j::Transaction.run { @session.graph_db.all_nodes.count }
    end

    def session
      Neo4j::Session.current
    end

    def execute_query(statement, &block)
      resultset = []
      Neo4j::Session.query(statement).each do |result|
        objects = result.members.map { |member| result.send member }
        if block_given?
          block.call(objects)
        else
          resultset << objects
        end
      end
      resultset
    end

    private
    def initialize(session)
      @last_start = Time.at(0).utc
      @session    = session
    end

    def self.start_session_at(location)
      if Neo4j::Session.current.nil?
        session = ::Neo4j::Session.open(:embedded_db, location, :auto_commit => true)
        session.start
      end
      Neo4j::Session.current
    end
  end
end
