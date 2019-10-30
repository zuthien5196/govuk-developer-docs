docker run \
    --name neo4j \
    -p7474:7474 -p7687:7687 \
    -d \
    -v $HOME/govuk/govuk-developer-docs/neo4j/data:/data \
    -v $HOME/govuk/govuk-developer-docs/neo4j/logs:/logs \
    -v $HOME/govuk/govuk-developer-docs/export:/var/lib/neo4j/import \
    -v $HOME/govuk/govuk-developer-docs/neo4j/plugins:/plugins \
    --env NEO4J_AUTH=neo4j/test \
    neo4j:latest
