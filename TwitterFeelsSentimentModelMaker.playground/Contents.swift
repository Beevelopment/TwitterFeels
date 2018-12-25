import Cocoa
import CreateML

let data = try MLDataTable(contentsOf: URL(fileURLWithPath: "/Users/Henningsson/Desktop/TwitterFeels/Sentiment-Dataset/twitter-sanders-apple3.csv"))

let(trainingData, testingData) = data.randomSplit(by: 0.8, seed: 5)

let sentimentClassifier = try MLTextClassifier(trainingData: trainingData, textColumn: "text", labelColumn: "class")

let evaluationMetrics = sentimentClassifier.evaluation(on: testingData)

let evaluationAccuracy = (1.0 - evaluationMetrics.classificationError) * 100

let metaData = MLModelMetadata(author: "Carl Henningsson", shortDescription: "Model for classify sentiments on tweets", version: "1.0")

try sentimentClassifier.write(to: URL(fileURLWithPath: "/Users/Henningsson/Desktop/TwitterFeels/Sentiment-Dataset/TweetSentimentClassifer.mlmodel"))
