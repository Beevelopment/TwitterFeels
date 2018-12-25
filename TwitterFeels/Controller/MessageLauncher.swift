//
//  MessageLauncher.swift
//  TwitterFeels
//
//  Created by Carl Henningsson on 11/4/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit
import Lottie

class MessageLauncher: NSObject {
    
    var mainController: MainController?

    let blackView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor(white: 0, alpha: 0.5)
        bv.alpha = 0
        
        return bv
    }()
    
    let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        
        return view
    }()
    
    let writeAnimation: LOTAnimationView = {
        let write = LOTAnimationView()
        write.setAnimation(named: "write")
        write.loopAnimation = true
        
        return write
    }()
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.textColor = SECONDARY_TEXT
        title.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        title.textAlignment = .center
        title.numberOfLines = 0
        title.text = "Your search needs to begin with either @, # or $ in order to predict how Twitter is feeling."
        
        return title
    }()
    
    let dismissButton: UIButton = {
        let dismiss = UIButton(type: .system)
        dismiss.setTitle("Understod", for: .normal)
        dismiss.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        dismiss.setTitleColor(MAIN_BLUE, for: .normal)
        
        return dismiss
    }()
    
    func showMessageLauncher() {
        if let window = UIApplication.shared.keyWindow {
            
            dismissButton.addTarget(self, action: #selector(dismissMessageLauncher), for: .touchUpInside)
            
            window.addSubview(blackView)
            window.addSubview(mainView)
            mainView.addSubview(writeAnimation)
            mainView.addSubview(titleLabel)
            mainView.addSubview(dismissButton)
            
            mainView.alpha = 1
            writeAnimation.alpha = 1
            titleLabel.alpha = 1
            dismissButton.alpha = 1
            
            _ = blackView.anchor(window.topAnchor, left: window.leftAnchor, bottom: window.bottomAnchor, right: window.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            mainView.frame = CGRect(x: window.frame.width * 0.1, y: -window.frame.height, width: window.frame.width * 0.8, height: window.frame.height / 2)
            writeAnimation.frame = CGRect(x: mainView.frame.width / 4, y: mainView.frame.width / 20, width: mainView.frame.width / 2, height: mainView.frame.height / 3)
            titleLabel.frame = CGRect(x: mainView.frame.width * 0.1, y: mainView.frame.height / 3, width: mainView.frame.width * 0.8, height: mainView.frame.height / 3)
            dismissButton.frame = CGRect(x: mainView.frame.width * 0.1, y: mainView.frame.height * 0.85, width: mainView.frame.width * 0.8, height: mainView.frame.height * 0.1)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.blackView.alpha = 1
                self.mainView.frame = CGRect(x: window.frame.width * 0.1, y: window.frame.height / 4, width: window.frame.width * 0.8, height: window.frame.height / 2)
            }) { (true) in
                self.writeAnimation.play()
            }
        }
    }
    
    @objc func dismissMessageLauncher() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.blackView.alpha = 0
            self.mainView.alpha = 0
            self.writeAnimation.alpha = 0
            self.titleLabel.alpha = 0
            self.dismissButton.alpha = 0
        }) { (true) in
            self.writeAnimation.stop()
        }
    }
}
