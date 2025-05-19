// Create Pipeline
CALL gds.beta.pipeline.nodeClassification.create('frp_pipeline');

// Tune Hyperparameters
CALL gds.beta.pipeline.nodeClassification.addNodeProperty('frp_pipeline', 'fastRP', {
  mutateProperty: 'frp',
  embeddingDimension: 128,
  iterationWeights: [0.7, 0.5, 0.2, 0.1],
  nodeSelfInfluence: 0.7,
  normalizationStrength: 0.7,
  randomSeed: 42
})
YIELD name, nodePropertySteps;

// Select Node features
CALL gds.beta.pipeline.nodeClassification.selectFeatures('frp_pipeline', ['frp'])
YIELD name, featureProperties;

// Select ML Algorithms
CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('frp_pipeline')
YIELD parameterSpace;
CALL gds.beta.pipeline.nodeClassification.addRandomForest('frp_pipeline', {numberOfDecisionTrees: 50})
YIELD parameterSpace;
CALL gds.alpha.pipeline.nodeClassification.addMLP('frp_pipeline')
YIELD parameterSpace;

// Configure auto-tuning
CALL gds.alpha.pipeline.nodeClassification.configureAutoTuning('frp_pipeline', {
  maxTrials: 100
}) YIELD autoTuningConfig;

// Training estimate
CALL gds.beta.pipeline.nodeClassification.train.estimate('titles_ml', {
  pipeline: 'frp_pipeline',
  targetNodeLabels: ['titles'],
  modelName: 'frp-model',
  targetProperty: 'domestic_class',
  randomSeed: 1337,
  metrics: [ 'ACCURACY' ]
})
YIELD requiredMemory;


// Train and get result scores
CALL gds.beta.pipeline.nodeClassification.train('titles_ml', {
  pipeline: 'frp_pipeline',
  targetNodeLabels: ['titles'],
  modelName: 'frp-model',
  targetProperty: 'domestic_class',
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
CALL gds.model.drop('frp-model');

// Drop Pipeline
CALL gds.beta.pipeline.drop('frp_pipeline');
