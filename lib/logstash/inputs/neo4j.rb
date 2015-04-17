# encoding: utf-8
require "logstash/inputs/base"
require "logstash/namespace"

# This plugin gets data from a Neo4j database in predefined intervals. To fetch
# this data uses a given Cypher query.
#
# ### Usage:
# [source, ruby]
# input {
#   neo4j {
#     query => "MATCH (p:`Person`)-->(m:`Movie`) WHERE m.released = 2005 RETURN *"
#     path  => "/foo/bar.db"
#   }
# }
#
# In embedded_db mode this plugin require a neo4j db 2.0.1 or superior. If
# using the remote version there is no major restriction.
#
class LogStash::Inputs::Neo4j < LogStash::Inputs::Base

  config_name "neo4j"

  # If undefined, Logstash will complain, even if codec is unused.
  default :codec, "plain"

  # Cypher query used to retrieve data from the neo4j database, this statement
  # should looks like something like this:
  #
  # MATCH (p:`Person`)-->(m:`Movie`) WHERE m.released = 2005 RETURN *
  #
  config :query, :validate => :string, :required => true

  # The path within your file system where the neo4j database is located
  config :path, :validate => :string, :required => true

  # Schedule of when to periodically run statement, in Cron format
  # for example: "* * * * *" (execute query every minute, on the minute).
  # If this variable is not specified then this input will run only once
  config :schedule, :validate => :string

  public
  def register
    require "rufus/scheduler"
    require "logstash/inputs/neo4j-client"
    @client = Neo4jrb::Client.open(@path)
  end # def register

  def run(queue)
    if @schedule
      setup_scheduler(queue)
    else
      fetch(queue)
    end
  end # def run

  private
  def setup_scheduler(queue)
    @scheduler = Rufus::Scheduler.new
    @scheduler.cron(@schedule) do
      fetch(queue)
    end
    @scheduler.join
  end

  def fetch(queue)
    @client.execute_query(@query) do |nodes|
      payload = compose_payload(nodes)
      event = LogStash::Event.new(payload)
      decorate(event)
      queue << event
    end
  end

  def compose_payload(nodes)
    object = { "labels" => nodes[0].labels, "props" => nodes[0].props }
    object["_rels"] = []
    (1...nodes.count).each do |i|
      rel     = nodes[i]
      payload = { "props" => rel.props }
      payload["labels"] = rel.respond_to?(:labels) ? rel.labels : "Relationship"
      object["_rels"] << payload
    end
    { "message" => LogStash::Json.dump(object), "host" => @client.session.inspect}
  end

end # class LogStash::Inputs::Neo4j
