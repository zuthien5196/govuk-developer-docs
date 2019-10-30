require_relative './requires'
require 'yaml'
require 'active_support/all'

require 'neo4j'
require 'neo4j/core/cypher_session/adaptors/bolt'

class Export
  attr :applications

  def initialize
    repository_path = Dir.getwd
    application_data_load_path = File.join(repository_path, "data/applications.yml")

    @applications = AppDocs.pages.reject(&:retired?)
  end

  def export
    delete_all

    app_nodes
    aws_machines
    carrenza_machines

    app_to_aws_machines_edgelist
    app_to_carrenza_machines_edgelist
    app_to_team

    govuk_docker
  end

  def delete_all
    neo4j_session.query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r;')
  end

  def app_nodes
    applications.each do |app|
      neo4j_session.query("CREATE (n:Application { name: '#{app.app_name}', html_url: '#{app.html_url}' })")
    end
  end

  def aws_machines
    AppDocs.aws_machines.each do |aws_machine|
      neo4j_session.query("CREATE (n:AWSMachine { node_class: '#{aws_machine.first}' })")
    end
  end

  def carrenza_machines
    AppDocs.carrenza_machines.each do |carrenza_machine|
      neo4j_session.query("CREATE (n:CarrenzaMachine { node_class: '#{carrenza_machine.first}' })")
    end
  end

  def app_to_aws_machines_edgelist
    AppDocs.aws_machines.each do |aws_machine|
      aws_machine[1]['apps'].each do |app_name|

        app = find_app(app_name)
        if app && app.production_hosted_on == 'aws'
          neo4j_session.query("
MATCH (app:Application { name: '#{app_name}'}), (aws_machine:AWSMachine { node_class: '#{aws_machine.first}'})
CREATE (aws_machine)-[:HOSTS]->(app)
;")
        end
      end
    end
  end

  def app_to_carrenza_machines_edgelist
    AppDocs.carrenza_machines.each do |carrenza_machine|
      carrenza_machine[1]['apps'].each do |app_name|
        app = find_app(app_name)
        if app && app.production_hosted_on == 'carrenza'
        neo4j_session.query("
MATCH (app:Application { name: '#{app_name}'}), (carrenza_machine:CarrenzaMachine { node_class: '#{carrenza_machine.first}'})
CREATE (carrenza_machine)-[:HOSTS]->(app)
;")
        end
      end
    end
  end

  def app_to_team
    teams = applications.map(&:team).uniq.reject(&:nil?)
    teams.each do |team|
      neo4j_session.query("CREATE (n:Team { name: '#{team}' })")
    end

    applications.each do |app|
      next if app.team.nil?

      neo4j_session.query("
MATCH (app:Application { name: '#{app.app_name}'}), (team:Team { name: '#{app.team}'})
CREATE (team)-[:OWNS]->(app)
;")
    end
  end

  def govuk_docker
    services = YAML.load_file(ENV['HOME'] + '/govuk/govuk-docker/docker-compose.yml')
    services['services'].keys.each do |service|
      neo4j_session.query("CREATE (n:Service { name: '#{service}' })")
    end

    Dir.glob(ENV['HOME'] + '/govuk/govuk-docker/services/**/docker-compose.yml').each do |file|
      compose = YAML.load_file(file)
      app_name = compose.keys[1][2..]

      app_definition = compose['services'].find { |k, _v| k[-4..] == '-app' }
      next if app_definition.nil?

      depends_on = app_definition[1]['depends_on']
      next if depends_on.nil?

      depends_on.each do |dependancy|
        if dependancy[-4..] == "-app"
          dependancy = dependancy[0..-5]
          neo4j_session.query("
MATCH (app:Application { name: '#{app_name}'}), (dependancy:Application { name: '#{dependancy}'})
CREATE (app)-[:DEPENDS_ON]->(dependancy)
;")
        else
          neo4j_session.query("
MATCH (app:Application { name: '#{app_name}'}), (dependancy:Service { name: '#{dependancy}'})
CREATE (app)-[:DEPENDS_ON]->(dependancy)
;")
         end
      end
    end
  end

  def self.run
    new.export
  end

  def find_app(app_name)
    applications.find { |a| a.app_name == app_name }
  end

private

  def neo4j_session
    return @neo4j_session if @neo4j_session

    bolt_adaptor = Neo4j::Core::CypherSession::Adaptors::Bolt.new('bolt://neo4j:test@localhost:7687', ssl: false)
    @neo4j_session = Neo4j::Core::CypherSession.new(bolt_adaptor)
  end
end
