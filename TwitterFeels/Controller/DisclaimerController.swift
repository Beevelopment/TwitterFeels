//
//  DisclaimerController.swift
//  TwitterFeels
//
//  Created by Carl Henningsson on 11/8/18.
//  Copyright © 2018 Carl Henningsson. All rights reserved.
//

import UIKit

class DisclaimerController: UIViewController {
    
    let titleLable: UILabel = {
        let lbl = UILabel()
        lbl.text = "Disclaimer"
        
        return lbl
    }()
    
    let textView: UITextView = {
        let text = UITextView()
        text.text = "TwitterFeels uses your search term to predict how the emotions and feelings are around that subject, company or person. We are doing this by using Twitters open API and read the tweets that include your search term. You can see the difference of predictions in percentage of your search.\n\nTwitterFeels only read through the 100 latest tweets and predict the overall feelings of the subject on Twitter.\n\nTwitterFeels read tweets from 7 days ago.\n\nAt this moment in time TwitterFeels only read tweets that are written in English.\n\nTwitterFeels are constantly working to improve the overall predictions by expanding the knowledge of human interaction on Twitter. TwitterFeels also works on creating a broader understanding of the language we use and how it´s used.\n\nTwitterFeels will in a short future be able to predict the emotions and feelings of Twitter in different language which will help getting a more accurate prediction.\n\nTwitterFeels takes no responsibility for any action that you take based on or are influenced by the information presented by TwitterFeels. None of the information is a guarantee for trends in stock markets or in any other businesses."
        
        return text
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        let sideMargin = view.frame.width / 10
        
        view.backgroundColor = .white
        
        view.addSubview(titleLable)
        view.addSubview(textView)
        
        _ = titleLable.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: nil, topConstant: sideMargin, leftConstant: sideMargin, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        _ = textView.anchor(titleLable.bottomAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: sideMargin, leftConstant: sideMargin, bottomConstant: sideMargin, rightConstant: sideMargin, widthConstant: 0, heightConstant: 0)
    }
}
