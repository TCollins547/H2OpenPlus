//
//  CourseView.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/16/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit

class CourseView: UIView, UIScrollViewDelegate {

    @IBOutlet weak var courseNameLabel: UILabel!
    @IBOutlet weak var courseMapImage: UIImageView!
    @IBOutlet weak var courseInstructionsTextView: UITextView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        courseInstructionsTextView.setContentOffset(CGPoint.zero, animated: false)
    }
    
    override func awakeFromNib() {
        scrollView.delegate = self
        scrollView.maximumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return courseMapImage
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
