//
//  DetailLauncher.swift
//  TwitterFeels
//
//  Created by Carl Henningsson on 11/4/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit
import Lottie

class DetailLauncher: NSObject {

    var mainController: MainController?
    
    let blackView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bv.alpha = 0
        
        return bv
    }()
    
    let urlAnimation: LOTAnimationView = {
        let url = LOTAnimationView()
        url.setAnimation(named: "openURL")
        
        return url
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.font = UIFont.systemFont(ofSize: 32, weight: .semibold)
        title.textColor = SECONDARY_TEXT
        title.textAlignment = .center
        title.text = "@Tesla"
        
        return title
    }()
    
    lazy var tweetsRead: UILabel = {
        let tweet = UILabel()
        tweet.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tweet.textColor = SECONDARY_TEXT
        tweet.textAlignment = .center
        tweet.text = "Tweets read: 100%"
        
        return tweet
    }()
    
    lazy var posTweet: UILabel = {
        let tweet = UILabel()
        tweet.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        tweet.textColor = MAIN_GREEN
        tweet.textAlignment = .center
        tweet.text = "55%"
        
        return tweet
    }()
    
    lazy var neuTweet: UILabel = {
        let tweet = UILabel()
        tweet.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        tweet.textColor = MAIN_BLUE
        tweet.textAlignment = .center
        tweet.text = "25%"
        
        return tweet
    }()
    
    lazy var negTweet: UILabel = {
        let tweet = UILabel()
        tweet.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        tweet.textColor = MAIN_RED
        tweet.textAlignment = .center
        tweet.text = "20%"
        
        return tweet
    }()
    
    lazy var tweetScore: UILabel = {
        let tweet = UILabel()
        tweet.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        tweet.textColor = SECONDARY_TEXT
        tweet.textAlignment = .center
        tweet.text = "Overall Score: -5"
        
        return tweet
    }()
    
    let dismissButon: UIButton = {
        let share = UIButton(type: .system)
        share.setTitle("Dismiss", for: .normal)
        share.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .semibold)
        share.tintColor = MAIN_BLUE
        
        return share
    }()
    
    let at: UIButton = {
        let a = UIButton(type: .system)
        a.setTitle("@", for: .normal)
        a.tintColor = MAIN_BLUE
        a.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        
        return a
    }()
    
    let dollarSign: UIButton = {
        let a = UIButton(type: .system)
        a.setTitle("$", for: .normal)
        a.tintColor = MAIN_BLUE
        a.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        
        return a
    }()
    
    let hashTag: UIButton = {
        let a = UIButton(type: .system)
        a.setTitle("#", for: .normal)
        a.tintColor = MAIN_BLUE
        a.titleLabel?.font = UIFont.systemFont(ofSize: 50, weight: .semibold)
        
        return a
    }()
    
    @objc func openTwitterURL() {
        let notAllowedCharacterSet = NSCharacterSet(charactersIn: "!*'();:@&=$,+/?%#[]. ")
        let allowedCharactersSet = notAllowedCharacterSet.inverted
        
        guard let searchTerm = titleLabel.text else { return }
        let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: allowedCharactersSet)
        
        let encodedURL = "https://twitter.com/search?f=tweets&vertical=default&q=\(encodedSearchTerm!)&src=typd"
        
        guard let twitterURL = URL(string: encodedURL) else { return }
        if UIApplication.shared.canOpenURL(twitterURL) {
            UIApplication.shared.open(twitterURL) { (succes) in
                if !succes {
                    print("Carl: Error with link")
                }
            }
        }
    }
    
    func detailLauncher() {
        if let window = UIApplication.shared.keyWindow {
            
            urlAnimation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openTwitterURL)))
            dismissButon.addTarget(self, action: #selector(dismissDetailLauncher), for: .touchUpInside)
            
            urlAnimation.isHidden = false
            tweetsRead.isHidden = false
            posTweet.isHidden = false
            neuTweet.isHidden = false
            negTweet.isHidden = false
            tweetScore.isHidden = false
            dismissButon.isHidden = false
            
            let windowHeight = window.frame.height
            let windowWidth = window.frame.width
            
            window.addSubview(blackView)
            window.addSubview(mainView)
            mainView.addSubview(urlAnimation)
            mainView.addSubview(titleLabel)
            mainView.addSubview(tweetsRead)
            mainView.addSubview(posTweet)
            mainView.addSubview(neuTweet)
            mainView.addSubview(negTweet)
            mainView.addSubview(tweetScore)
            mainView.addSubview(dismissButon)
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            mainView.frame = CGRect(x: 0, y: windowHeight, width: windowWidth, height: windowHeight * 0.5)
            urlAnimation.frame = CGRect(x: windowWidth * 0.85, y: windowWidth * 0.08, width: 50, height: 50)
            titleLabel.frame = CGRect(x: 0, y: windowWidth * 0.1, width: windowWidth, height: 35)
            tweetsRead.frame = CGRect(x: 0, y: windowWidth * 0.2 + 35, width: windowWidth, height: 20)
            posTweet.frame = CGRect(x: 0, y: windowWidth * 0.3 + 55, width: windowWidth / 3, height: 22)
            neuTweet.frame = CGRect(x: windowWidth / 3, y: windowWidth * 0.3 + 55, width: windowWidth / 3, height: 22)
            negTweet.frame = CGRect(x: windowWidth / 3 * 2, y: windowWidth * 0.3 + 55, width: windowWidth / 3, height: 22)
            tweetScore.frame = CGRect(x: 0, y: windowWidth * 0.4 + 77, width: windowWidth, height: 20)
            dismissButon.frame = CGRect(x: windowWidth / 4, y: mainView.frame.height - windowWidth * 0.1 - 50, width: windowWidth / 2, height: 50)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.mainView.frame = CGRect(x: 0, y: windowHeight * 0.4, width: windowWidth, height: windowHeight * 0.6)
                self.urlAnimation.frame = CGRect(x: windowWidth * 0.85, y: windowWidth * 0.08, width: 50, height: 50)
                self.titleLabel.frame = CGRect(x: 0, y: windowWidth * 0.1, width: windowWidth, height: 35)
                self.tweetsRead.frame = CGRect(x: 0, y: windowWidth * 0.2 + 35, width: windowWidth, height: 20)
                self.posTweet.frame = CGRect(x: 0, y: windowWidth * 0.3 + 55, width: windowWidth / 3, height: 22)
                self.neuTweet.frame = CGRect(x: windowWidth / 3, y: windowWidth * 0.3 + 55, width: windowWidth / 3, height: 22)
                self.negTweet.frame = CGRect(x: windowWidth / 3 * 2, y: windowWidth * 0.3 + 55, width: windowWidth / 3, height: 22)
                self.tweetScore.frame = CGRect(x: 0, y: windowWidth * 0.4 + 77, width: windowWidth, height: 20)
                self.dismissButon.frame = CGRect(x: windowWidth / 4, y: self.mainView.frame.height - windowWidth * 0.1 - 50, width: windowWidth / 2, height: 50)
            }) { (true) in
                self.urlAnimation.play()
            }
        }
    }
    
    func chooseBegining() {
        if let window = UIApplication.shared.keyWindow {
            
            at.addTarget(self, action: #selector(choiceAt), for: .touchUpInside)
            dollarSign.addTarget(self, action: #selector(choiceDollarSign), for: .touchUpInside)
            hashTag.addTarget(self, action: #selector(choiceHashTag), for: .touchUpInside)
            
            at.isHidden = false
            dollarSign.isHidden = false
            hashTag.isHidden = false
            
            let windowHeight = window.frame.height
            let windowWidth = window.frame.width
            
            window.addSubview(blackView)
            window.addSubview(mainView)
            mainView.addSubview(titleLabel)
            mainView.addSubview(at)
            mainView.addSubview(dollarSign)
            mainView.addSubview(hashTag)
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            mainView.frame = CGRect(x: 0, y: windowHeight, width: windowWidth, height: windowHeight * 0.3)
            titleLabel.frame = CGRect(x: 0, y: windowWidth * 0.1, width: windowWidth, height: 35)
            at.frame = CGRect(x: 0, y: windowWidth * 0.2 + 35, width: windowWidth / 3, height: 50)
            dollarSign.frame = CGRect(x: windowWidth / 3, y: windowWidth * 0.2 + 35, width: windowWidth / 3, height: 50)
            hashTag.frame = CGRect(x: windowWidth / 3 * 2, y: windowWidth * 0.2 + 35, width: windowWidth / 3, height: 50)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.mainView.frame = CGRect(x: 0, y: windowHeight * 0.7, width: windowWidth, height: windowHeight * 0.3)
                self.titleLabel.frame = CGRect(x: 0, y: windowWidth * 0.1, width: windowWidth, height: 35)
                self.at.frame = CGRect(x: 0, y: windowWidth * 0.2 + 35, width: windowWidth / 3, height: 50)
                self.dollarSign.frame = CGRect(x: windowWidth / 3, y: windowWidth * 0.2 + 35, width: windowWidth / 3, height: 50)
                self.hashTag.frame = CGRect(x: windowWidth / 3 * 2, y: windowWidth * 0.2 + 35, width: windowWidth / 3, height: 50)
            })
            
            titleLabel.text = "Choose"
        }
    }
    
    @objc func choiceAt() {
        if let text = mainController?.inputField.text, text != "" {
            mainController?.inputField.text.insert("@", at: text.startIndex)
        }
        dismissDetailLauncher()
        mainController?.searchTweets()
    }
    
    @objc func choiceDollarSign() {
        if let text = mainController?.inputField.text, text != "" {
            mainController?.inputField.text.insert("$", at: text.startIndex)
        }
        dismissDetailLauncher()
        mainController?.searchTweets()
    }
    
    @objc func choiceHashTag() {
        if let text = mainController?.inputField.text, text != "" {
            mainController?.inputField.text.insert("#", at: text.startIndex)
        }
        dismissDetailLauncher()
        mainController?.searchTweets()
    }
    
    @objc func dismissDetailLauncher() {
        if let window = UIApplication.shared.keyWindow {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.mainView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: window.frame.height * 0.6)
            }) { (true) in
                
                self.at.isHidden = true
                self.dollarSign.isHidden = true
                self.hashTag.isHidden = true
                self.urlAnimation.isHidden = true
                self.tweetsRead.isHidden = true
                self.posTweet.isHidden = true
                self.neuTweet.isHidden = true
                self.negTweet.isHidden = true
                self.tweetScore.isHidden = true
                self.dismissButon.isHidden = true
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.blackView.alpha = 0
                })
            }
        }
    }
}
