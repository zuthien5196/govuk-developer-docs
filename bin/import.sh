rm export/*.csv
bundle exec rake graph:export
cat export/import.cypher | cypher-shell -u neo4j -p test -a 0.0.0.0
