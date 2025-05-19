// Create in-memory projection (include startYear next time)
CALL gds.graph.project('mkg', ['titles', 'names'], '*', {nodeProperties: ['startYear', 'budget', 'domestic', 'international', 'worldwide']});

// Drop in-memory projection
CALL gds.graph.drop('mkg');

// Create Node2Vec embeddings
CALL gds.node2vec.mutate('mkg', {mutateProperty: 'n2v_embedding'});

// Calculate centrality measures
CALL gds.pageRank.mutate('mkg', {mutateProperty: 'page_rank'});
CALL gds.degree.mutate('mkg', {mutateProperty: 'degree_centrality'});
CALL gds.betweenness.mutate('mkg', {mutateProperty: 'betweenness_centrality'});

//DB settings
dbms.memory.heap.initial_size=2G
dbms.memory.heap.max_size=4G
dbms.memory.pagecache.size=1G

// List GDS graphs
CALL gds.graph.list();

// Look at the added node property in the GDS graph
CALL gds.graph.nodeProperty.stream('mkg', 'n2v_embedding')
YIELD nodeId, propertyValue
WITH gds.util.asNode(nodeId) AS node, propertyValue
WHERE 'names' IN labels(node)
RETURN node, propertyValue
LIMIT 10;

// Write back Node2Vec embeddings to the DB
CALL gds.graph.writeNodeProperties('mkg', ['n2v_embedding', 'page_rank', 'degree_centrality', 'betweenness_centrality']);


// Update ROI
CALL {
  MATCH (m:titles)
  WHERE m.worldwide IS NOT NULL AND m.budget IS NOT NULL AND toFloat(m.budget) > 0
  WITH m, toFloat(m.worldwide) / toFloat(m.budget) AS roi_worldwide
  SET m.roi_worldwide = roi_worldwide
}

CALL {
  MATCH (m:titles)
  WHERE m.domestic IS NOT NULL AND m.budget IS NOT NULL AND toFloat(m.budget) > 0
  WITH m, toFloat(m.domestic) / toFloat(m.budget) AS roi_domestic
  SET m.roi_domestic = roi_domestic
}

CALL {
  MATCH (m:titles)
  WHERE m.international IS NOT NULL AND m.budget IS NOT NULL AND toFloat(m.budget) > 0
  WITH m, toFloat(m.international) / toFloat(m.budget) AS roi_international
  SET m.roi_international = roi_international
}


// Update class
MATCH (m:titles)
WHERE m.roi_worldwide IS NOT NULL
SET m.worldwide_class = 
  CASE 
    WHEN m.roi_worldwide < 1 THEN 0
    WHEN m.roi_worldwide >= 1 AND m.roi_worldwide < 2 THEN 1
    ELSE 2
  END;

MATCH (m:titles)
WHERE m.roi_domestic IS NOT NULL
SET m.domestic_class = 
  CASE 
    WHEN m.roi_domestic < 1 THEN 0
    WHEN m.roi_domestic >= 1 AND m.roi_domestic < 2 THEN 1
    ELSE 2
  END;

MATCH (m:titles)
WHERE m.roi_international IS NOT NULL
SET m.international_class = 
  CASE 
    WHEN m.roi_international < 1 THEN 0
    WHEN m.roi_international >= 1 AND m.roi_international < 2 THEN 1
    ELSE 2
  END;
