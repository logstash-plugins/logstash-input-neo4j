Gem::Specification.new do |s|

  s.name            = 'logstash-input-neo4j'
  s.version         = '2.0.0'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "Logstash Input for Neo4j"
  s.description     = "Output events to Neo4j"
  s.authors         = ["Pere Urbon-Bayes", "Elastic"]
  s.email           = 'pere.urbon@gmail.com'
  s.homepage        = "http://purbon.com/"
  s.require_paths = ["lib"]

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "output" }

  s.add_runtime_dependency "logstash-core", "~> 2.0.0.snapshot"
  s.add_runtime_dependency 'rufus-scheduler', '3.0.9'

  if RUBY_PLATFORM == 'java'
    s.platform = RUBY_PLATFORM
    s.add_runtime_dependency 'neo4j', '~> 4.0.0'
    s.add_runtime_dependency 'neo4j-community', '~> 2.0.0'
  end

  s.add_development_dependency 'logstash-devutils'
  s.add_development_dependency 'logstash-codec-plain'

end
