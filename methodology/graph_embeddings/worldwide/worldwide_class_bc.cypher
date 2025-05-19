// Create Pipeline
CALL gds.beta.pipeline.nodeClassification.create('bc_pipeline');

// Select Node features
CALL gds.beta.pipeline.nodeClassification.selectFeatures('bc_pipeline', ['betweenness_centrality'])
YIELD name, featureProperties;

// Select ML Algorithms
CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('bc_pipeline')
YIELD parameterSpace;
CALL gds.beta.pipeline.nodeClassification.addRandomForest('bc_pipeline', {numberOfDecisionTrees: 50})
YIELD parameterSpace;
CALL gds.alpha.pipeline.nodeClassification.addMLP('bc_pipeline')
YIELD parameterSpace;

// Configure auto-tuning
CALL gds.alpha.pipeline.nodeClassification.configureAutoTuning('bc_pipeline', {
  maxTrials: 100
}) YIELD autoTuningConfig;

// Training estimate
CALL gds.beta.pipeline.nodeClassification.train.estimate('titles_ml', {
  pipeline: 'bc_pipeline',
  targetNodeLabels: ['titles'],
  modelName: 'bc-model',
  targetProperty: 'worldwide_class',
  randomSeed: 1337,
  metrics: [ 'ACCURACY' ]
})
YIELD requiredMemory;


// Train and get result scores
CALL gds.beta.pipeline.nodeClassification.train('titles_ml', {
  pipeline: 'bc_pipeline',
  targetNodeLabels: ['titles'],
  modelName: 'bc-model',
  targetProperty: 'worldwide_class',
  randomSeed: 1337,
  metrics: [ 'ACCURACY' ]
})
YIELD modelInfo, modelSelectionStats
RETURN
  modelInfo.bestParameters AS winningModel,
  modelInfo.metrics.ACCURACY.train.avg AS avgTrainScore,
  modelInfo.metrics.ACCURACY.outerTrain AS outerTrainScore,
  modelInfo.metrics.ACCURACY.test AS testScore,
  [cand IN modelSelectionStats.modelCandidates | cand.metrics.ACCURACY.validation.avg] AS validationScores;


// Drop Model
CALL gds.model.drop('bc-model');

// Drop Pipeline
CALL gds.beta.pipeline.drop('bc_pipeline');
