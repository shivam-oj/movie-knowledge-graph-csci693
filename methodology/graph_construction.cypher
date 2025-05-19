// Load titles
LOAD CSV WITH HEADERS FROM 'file:///refined_movies_from_imdb_bom' AS row
// WITH row LIMIT 500
CREATE(:titles {tconst: row.tconst, primaryTitle: row.primaryTitle, startYear: toInteger(row.startYear), genres: row.genres, director: row.director, producer: row.producer, composer: row.composer, cinematographer: row.cinematographer, main_actor_1: row.main_actor_1, main_actor_2: row.main_actor_2, main_actor_3: row.main_actor_3, main_actor_4: row.main_actor_4, budget: toInteger(row.budget), domestic: toInteger(row.domestic), international: toInteger(row.international), worldwide: toInteger(row.worldwide), bom_link: row.link});


// Load names in batch
:auto
LOAD CSV WITH HEADERS FROM 'file:///refined_names' AS row
CALL {
WITH row
CREATE(:names {nconst: row.nconst, primaryName: row.primaryName})
} IN TRANSACTIONS OF 10000 ROWS;


// Create DIRECTED_BY (incorrect direction)
LOAD CSV WITH HEADERS FROM "file:///refined_directors" AS row
MATCH (n:names {nconst:row.director}), (t:titles {tconst:row.tconst})
CREATE (n)-[:DIRECTED_BY]->(t);


// Invert relationship
MATCH (n:names)-[rel:DIRECTED_BY]->(t:titles)
CALL apoc.refactor.invert(rel, { failOnErrors = true })
yield input, output
RETURN input, output;

// New syntax
MATCH (n:names)-[rel:DIRECTED_BY]->(t:titles)
WITH rel
CALL apoc.refactor.invert(rel) YIELD input, output
RETURN input, output;


// Create WRITTEN_BY
LOAD CSV WITH HEADERS FROM "file:///refined_writers" AS row
MATCH (n:names {nconst:row.writer}), (t:titles {tconst:row.tconst})
CREATE (t)-[:WRITTEN_BY]->(n);


// Create KNOWN_FOR
LOAD CSV WITH HEADERS FROM "file:///refined_names_from_imdb" AS row
MATCH (n:names {nconst:row.nconst}), (t:titles {tconst:row.tconst})
CREATE (n)-[:KNOWN_FOR]->(t);

// In batch
:auto
LOAD CSV WITH HEADERS FROM 'file:///refined_names_from_imdb' AS row
CALL {
WITH row
MATCH (n:names {nconst:row.nconst}), (t:titles {tconst:row.tconst})
CREATE (n)-[:KNOWN_FOR]->(t)
} IN TRANSACTIONS OF 10000 ROWS;

// Create index
CREATE INDEX titles_index FOR (t:titles) ON (t.tconst);
CREATE INDEX names_index FOR (n:names) ON (n.nconst);


// Create ACTED_IN
LOAD CSV WITH HEADERS FROM "file:///refined_acted_in_1" AS row
MATCH (n:names {nconst:row.nconst}), (t:titles {tconst:row.tconst})
CREATE (n)-[:ACTED_IN]->(t);

LOAD CSV WITH HEADERS FROM "file:///refined_acted_in_2" AS row
MATCH (n:names {nconst:row.nconst}), (t:titles {tconst:row.tconst})
CREATE (n)-[:ACTED_IN]->(t);

LOAD CSV WITH HEADERS FROM "file:///refined_acted_in_3" AS row
MATCH (n:names {nconst:row.nconst}), (t:titles {tconst:row.tconst})
CREATE (n)-[:ACTED_IN]->(t);

LOAD CSV WITH HEADERS FROM "file:///refined_acted_in_4" AS row
MATCH (n:names {nconst:row.nconst}), (t:titles {tconst:row.tconst})
CREATE (n)-[:ACTED_IN]->(t);
