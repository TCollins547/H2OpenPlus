//
//  HomeSubView.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/15/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit

class HomeSubView: UIView {
    
    @IBOutlet weak var typeImageView: UIImageView!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        descriptionTextView.setContentOffset(CGPoint.zero, animated: false)
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
