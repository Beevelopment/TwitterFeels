//
//  MainController.swift
//  TwitterFeels
//
//  Created by Carl Henningsson on 11/3/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON
import Lottie
import Speech
import AudioToolbox

class MainController: UIViewController, UITextViewDelegate, SFSpeechRecognizerDelegate {
    
    let logoImage: UIImageView = {
        let logoImg = UIImageView()
        logoImg.image = UIImage(named: "smile")?.withRenderingMode(.alwaysTemplate)
        logoImg.tintColor = MAIN_BLUE
        logoImg.contentMode = .scaleAspectFit
        logoImg.alpha = 0
        
        return logoImg
    }()
    
    let disclaimerButton: UIButton = {
        let disclaimer = UIButton(type: .system)
        disclaimer.setImage(UIImage(named: "advise"), for: .normal)
        disclaimer.widthAnchor.constraint(equalToConstant: 25).isActive = true
        disclaimer.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        return disclaimer
    }()
    
    let iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "smile")?.withRenderingMode(.alwaysTemplate)
        icon.contentMode = .scaleAspectFit
        icon.tintColor = MAIN_BLUE
        
        return icon
    }()
    
    lazy var inputField: UITextView = {
        let input = UITextView()
        input.backgroundColor = .white
        input.layer.borderColor = MAIN_BLUE.cgColor
        input.text = "Search by @, # or $"
        input.textColor = HINT_TEXT
        input.layer.borderWidth = 1.5
        input.layer.cornerRadius = 25
        input.textContainerInset.left = 20
        input.textContainerInset.right = 60
        input.textContainerInset.top = 15
        input.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        input.returnKeyType = .search
        input.delegate = self
        
        return input
    }()
    
    let predictButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "prediction"), for: .normal)
        button.tintColor = MAIN_BLUE
        button.addTarget(self, action: #selector(searchTweets), for: .touchUpInside)
        
        return button
    }()
    
    let textViewIsEdited: UIView = {
        let view = UIView()
        view.isHidden = true
        
        return view
    }()
    
    let resultLabel: UILabel = {
        let result = UILabel()
        result.textColor = HINT_TEXT
        result.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        result.textAlignment = .center
        result.numberOfLines = 0
        result.text = "TwitterFeels"
        
        return result
    }()
    
    let loadAnimation: LOTAnimationView = {
        let load = LOTAnimationView()
        load.setAnimation(named: "loading")
        load.loopAnimation = true
        load.isHidden = false
        
        return load
    }()
    
    let infoAnimation: LOTAnimationView = {
        let info = LOTAnimationView()
        info.isUserInteractionEnabled = true
        info.setAnimation(named: "info")
        info.isHidden = false
        
        return info
    }()
    
    let speechLottie: LOTAnimationView = {
        let speech = LOTAnimationView()
        speech.isUserInteractionEnabled = true
        speech.setAnimation(named: "speech")
        speech.loopAnimation = true
        
        return speech
    }()
    
    let titleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 35))
    
    var characterArray = ["@", "#", "$"]
    
    var count = 100
    var tweets = [TweetSentimentClassiferInput]()
    var tweetCount = 0
    var sentimentScore = 0
    var posCount = 0
    var negCount = 0
    var neuCount = 0
    
    let swifter = Swifter(consumerKey: CONSUMER_KEY, consumerSecret: CONSUMER_SECRET_KEY)
    let sentimentClassifier = TweetSentimentClassifer()
    
    lazy var messageLauncher: MessageLauncher = {
        let message = MessageLauncher()
        message.mainController = self
        
        return message
    }()
    
    lazy var detailLauncher: DetailLauncher = {
        let detail = DetailLauncher()
        detail.mainController = self
        
        return detail
    }()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        infoAnimation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showDetailsAboutSearch)))
        speechLottie.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(startSpeechAnimation)))
        
        setupSpeechRecognizer()
    }
    
    func setupSpeechRecognizer() {
        speechRecognizer?.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.speechLottie.isUserInteractionEnabled = isButtonEnabled
            }
        }
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                self.inputField.textColor = .black
                self.inputField.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            speechLottie.isUserInteractionEnabled = true
        } else {
            speechLottie.isUserInteractionEnabled = false
        }
    }
    
    @objc func startSpeechAnimation() {
        infoAnimation.isHidden = true
        
        if !speechLottie.isAnimationPlaying {
            vibrate()
            speechLottie.play()
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.speechLottie.frame = CGRect(x: self.view.frame.midX - 62.5, y: self.view.frame.height * 0.70, width: 125, height: 125)
            })
            
            startRecording()
            
        } else {
            vibrate()
            speechLottie.stop()
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseIn, animations: {
                self.speechLottie.frame = CGRect(x: self.view.frame.width - 125 + self.view.frame.width / 20, y: self.view.frame.height - self.view.frame.width / 20 - 187.5, width: 125, height: 125)
            }) { (true) in
                if self.inputField.text != "Search by @, # or $" {
                    self.detailLauncher.chooseBegining()
                } else if self.inputField.text == "" {
                    self.inputField.text = "Search by @, # or $"
                }
            }
        }
    }
    
    func vibrate() {
        AudioServicesPlaySystemSound(1519)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        setupKeyboardObserver()
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        inputField.text = ""
        inputField.textColor = .black
        textViewIsEdited.isHidden = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if inputField.text.isEmpty {
            inputField.textColor = HINT_TEXT
            inputField.text = "Search by @, # or $"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            searchTweets()
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }
    
    private func startLoadingAnimation() {
        loadAnimation.play()
    }
    
    private func startInfoAnimation() {
        infoAnimation.isHidden = false
        infoAnimation.play()
    }
    
    @objc func showDetailsAboutSearch() {
        
        detailLauncher.titleLabel.text = resultLabel.text
        detailLauncher.tweetsRead.text = "Tweets Read: \(tweetCount)%"
        
        detailLauncher.posTweet.text = "\(calculateProcentage(count: posCount))%"
        detailLauncher.neuTweet.text = "\(calculateProcentage(count: neuCount))%"
        detailLauncher.negTweet.text = "\(calculateProcentage(count: negCount))%"
        
        detailLauncher.tweetScore.text = "Overall Score: \(sentimentScore)"
        
        detailLauncher.detailLauncher()
    }
    
    func calculateProcentage(count: Int) -> Int {
        let procent = Int(Double(count) / Double(tweetCount) * Double(100))
        return procent
    }
    
    @objc func searchTweets() {
        dismissKeyboard()
        
        if characterArray.contains(String(inputField.text.first!)) {
            startLoadingAnimation()
            swifter.searchTweet(using: inputField.text!, lang: "en", count: count, tweetMode: .extended, success: { (results, metaData) in
                self.tweetCount = 0
                self.tweets = []
                for i in 0..<self.count {
                    if let tweetText = results[i]["full_text"].string {
                        let tweetForClassifier = TweetSentimentClassiferInput(text: tweetText)
                        self.tweets.append(tweetForClassifier)
                        self.tweetCount += 1
                    } else {
                        print("Carl: Error with tweet")
                    }
                }
                self.prediction()
            }) { (error) in
                print(error)
            }
        } else {
            messageLauncher.showMessageLauncher()
        }
    }
    
    private func prediction() {
        sentimentScore = 0
        posCount = 0
        negCount = 0
        neuCount = 0
        
        do {
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            self.startInfoAnimation()
            
            for prediction in predictions {
                let sentiment = prediction.label
                if sentiment == "Pos" {
                    sentimentScore += 1
                    posCount += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                    negCount += 1
                } else {
                    neuCount += 1
                }
            }
            
            if sentimentScore > 0 {
                UIView.transition(with: self.iconImageView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.iconImageView.image = UIImage(named: "pos")?.withRenderingMode(.alwaysTemplate) }, completion: nil)
            } else if sentimentScore < 0 {
                UIView.transition(with: self.iconImageView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.iconImageView.image = UIImage(named: "neg")?.withRenderingMode(.alwaysTemplate) }, completion: nil)
            } else {
                UIView.transition(with: self.iconImageView, duration: 0.5, options: .transitionCrossDissolve, animations: { self.iconImageView.image = UIImage(named: "netural")?.withRenderingMode(.alwaysTemplate) }, completion: nil)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.logoImage.alpha = 1
            }
            
            resultLabel.text = inputField.text
            inputField.text = "Search by @, # or $"
            inputField.textColor = HINT_TEXT
            
            if self.loadAnimation.isAnimationPlaying {
                self.loadAnimation.stop()
                self.loadAnimation.isHidden = true
            }
            
        } catch {
            print("Carl: Error")
        }
    }
    
    @objc func openDisclaimerController() {
        let disclaimerController = DisclaimerController()
        present(disclaimerController, animated: true, completion: nil)
    }

    private func setupView() {
        view.backgroundColor = .white
        setupNavigationBar()
        
        textViewIsEdited.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        let tenMargin = view.frame.width / 20
        
        view.addSubview(iconImageView)
        view.addSubview(inputField)
        view.addSubview(speechLottie)
        view.addSubview(predictButton)
        view.addSubview(textViewIsEdited)
        view.addSubview(loadAnimation)
        view.addSubview(resultLabel)
        view.addSubview(infoAnimation)
        
        iconImageView.frame = CGRect(x: view.frame.width / 2 - 75, y: view.frame.height / 3, width: 150, height: 150)
        _ = inputField.anchor(nil, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: predictButton.leftAnchor, topConstant: 0, leftConstant: tenMargin, bottomConstant: tenMargin, rightConstant: tenMargin, widthConstant: 0, heightConstant: 50)
        _ = predictButton.anchor(nil, left: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: tenMargin + 5, rightConstant: tenMargin, widthConstant: 40, heightConstant: 40)
        _ = textViewIsEdited.anchor(view.topAnchor, left: view.leftAnchor, bottom: inputField.topAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = loadAnimation.anchor(view.topAnchor, left: nil, bottom: nil, right: view.rightAnchor, topConstant: tenMargin, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        _ = resultLabel.anchor(iconImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: tenMargin, leftConstant: tenMargin, bottomConstant: 0, rightConstant: tenMargin, widthConstant: 0, heightConstant: 0)
        _ = infoAnimation.anchor(nil, left: nil, bottom: inputField.topAnchor, right: inputField.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 150, heightConstant: 75)
        speechLottie.frame = CGRect(x: view.frame.width - 125 + tenMargin, y: view.frame.height - tenMargin - 187.5, width: 125, height: 125)
        
        loadAnimation.isHidden = true
    }
    
    private func setupNavigationBar() {
        
        logoImage.frame = titleView.bounds
        titleView.addSubview(logoImage)
        navigationItem.titleView = titleView
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: disclaimerButton)
        disclaimerButton.addTarget(self, action: #selector(openDisclaimerController), for: .touchUpInside)
        
        navigationController?.navigationBar.tintColor = MAIN_BLUE
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handelKeyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func removeKeyboardObserver() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handelKeyboardWillShow(notification: NSNotification) {
        let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let keyboardHeight = keyboardFrame.height
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.view.frame = CGRect(x: 0, y: -keyboardHeight + view.safeAreaInsets.bottom, width: self.view.frame.width, height: self.view.frame.height)
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func handelKeyboardWillHide(notification: NSNotification) {
        let keyboardDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        UIView.animate(withDuration: keyboardDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        textViewIsEdited.isHidden = true
        removeKeyboardObserver()
    }
}

