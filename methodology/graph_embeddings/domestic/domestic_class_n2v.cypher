// Create Pipeline
CALL gds.beta.pipeline.nodeClassification.create('n2v_pipeline');

// Tune Hyperparameters
CALL gds.beta.pipeline.nodeClassification.addNodeProperty('n2v_pipeline', 'node2vec', {
  randomSeed: 42,
  mutateProperty: 'n2v',
  walkLength: 10,
  walksPerNode: 10,
  windowSize: 5,
  inOutFactor: 0.25,
  returnFactor: 0.25,
  negativeSamplingRate: 5,
  embeddingDimension: 128
})
YIELD name, nodePropertySteps;

// Select Node features
CALL gds.beta.pipeline.nodeClassification.selectFeatures('n2v_pipeline', ['n2v'])
YIELD name, featureProperties;

// Select ML Algorithms
CALL gds.beta.pipeline.nodeClassification.addLogisticRegression('n2v_pipeline')
YIELD parameterSpace;
CALL gds.beta.pipeline.nodeClassification.addRandomForest('n2v_pipeline', {numberOfDecisionTrees: 50})
YIELD parameterSpace;
CALL gds.alpha.pipeline.nodeClassification.addMLP('n2v_pipeline')
YIELD parameterSpace;

// Configure auto-tuning
CALL gds.alpha.pipeline.nodeClassification.configureAutoTuning('n2v_pipeline', {
  maxTrials: 100
}) YIELD autoTuningConfig;

// Training estimate
CALL gds.beta.pipeline.nodeClassification.train.estimate('titles_ml', {
  pipeline: 'n2v_pipeline',
  targetNodeLabels: ['titles'],
  modelName: 'n2v-model',
  targetProperty: 'domestic_class',
  randomSeed: 1337,
  metrics: [ 'ACCURACY' ]
})
YIELD requiredMemory;


// Train and get result scores
CALL gds.beta.pipeline.nodeClassification.train('titles_ml', {
  pipeline: 'n2v_pipeline',
  targetNodeLabels: ['titles'],
  modelName: 'n2v-model',
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
CALL gds.model.drop('n2v-model');

// Drop Pipeline
CALL gds.beta.pipeline.drop('n2v_pipeline');
