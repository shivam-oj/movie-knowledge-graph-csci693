// Project graph in the memory (the n2v_embedding property can be ignored as it is recalculated in the pipelines with several hyperparameters)
CALL gds.graph.project('titles_ml', ['titles', 'names'], '*', {nodeProperties: ['n2v_embedding', 'betweenness_centrality', 'degree_centrality', 'page_rank', 'worldwide_class', 'domestic_class', 'international_class']});
