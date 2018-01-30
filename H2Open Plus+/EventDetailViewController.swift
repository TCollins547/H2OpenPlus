//
//  EventDetailViewController.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/16/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit

class EventDetailViewController: UIViewController {
    
    //Is the object itself
    @IBOutlet weak var bannerImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var eventDescription: UITextView!
    @IBOutlet weak var descriptionIndicator: UIActivityIndicatorView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var referanceView: UIView!
    @IBOutlet weak var dismissButton: UIButton!
    
    
    //Are the passed values from previous view
    var eventNameText: String?
    var banner: UIImage?
    var logo: UIImage?
    var descriptionText: String?
    var code: String?
    
    //Loaded in data
    var courseNames: [String] = []
    var courseMaps: [UIImage] = []
    var courseInstructions: [String] = []
    
    var courses: [CourseView] = []
    var numberOfCourses: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        createCourseViews()
        
        bannerImage.image = banner
        logoImage.image = logo
        titleLabel.text = eventNameText
        descriptionIndicator.startAnimating()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        if !(dismissButton.center.y > view.frame.height) && (blurView.isHidden) {
            dismissButton.center = CGPoint(x: view.center.x, y: dismissButton.center.y + view.frame.height)
        }
        eventDescription.isScrollEnabled = false
        eventDescription.isScrollEnabled = true
        eventDescription.setContentOffset(CGPoint.zero, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func loadData() {
        
        let url = URL(string: "https://h2openappdata.000webhostapp.com/Events/\(self.code!).json")!
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                print("JSON Data Loaded")
                if let urlContent = data {
                    do {
                        var jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                        if let courses = jsonResult[self.code!] as? [[String: AnyObject]] {
                            
                            for course in courses {
                                
                                if let description = course["Description"] as? String {
                                    self.descriptionText = description
                                }
                                
                                if let courseName = course["Name"] as? String {
                                    self.courseNames.append(courseName)
                                }
                                
                                if let instruction = course["Instructions"] as? String {
                                    self.courseInstructions.append(instruction)
                                }
                                
                                if (course["Map"] as! String) == "None" {
                                    self.courseMaps.append(UIImage(named: "NoImage.jpeg")!)
                                } else if let imageMap = NSURL(string: "https://h2openappdata.000webhostapp.com/Maps/\(course["Map"] as! String)") {
                                    if let imgBG = NSData(contentsOf: imageMap as URL) {
                                        self.courseMaps.append(UIImage(data: imgBG as Data)!)
                                    } else {
                                        self.courseMaps.append(UIImage(named: "LoadingError.png")!)
                                    }
                                }
                                
                            }
                            
                            
                            DispatchQueue.main.sync(execute: {
                                self.descriptionIndicator.stopAnimating()
                                self.descriptionIndicator.isHidden = true
                                self.eventDescription.text = self.descriptionText!
                                self.eventDescription.isHidden = false
                                self.updateCoursesData()
                            })
                            
                        }
                    } catch {
                        self.showConnectionError()
                    }
                }
            }
        }
        
        task.resume()
        
    }
    
    func showConnectionError() {
        let noConnection = UIAlertController(title: "Connection Error", message: "We were not able to connect to H2Open Plus+ at this time. Please check your internet connection or try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
        })
        noConnection.addAction(dismiss)
        self.present(noConnection, animated: true, completion: nil)
    }
    
    
    
    func createCourseViews() {
        
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(numberOfCourses!), height: scrollView.frame.height)
        
        for i in 0 ..< numberOfCourses! {
            let course: CourseView = Bundle.main.loadNibNamed("CourseView", owner: self, options: nil)?.first as! CourseView
            
            print(referanceView.frame.height)
            
            courses.append(course)
            
            courses[i].frame = CGRect(x: 0, y: 0, width: referanceView.frame.width, height: referanceView.frame.height)
            courses[i].center = CGPoint(x: referanceView.center.x + (view.frame.width * CGFloat(i)), y: scrollView.center.y + view.frame.height)
            courses[i].layer.cornerRadius = 8
            
            courses[i].courseNameLabel.isHidden = true
            courses[i].courseMapImage.isHidden = true
            courses[i].courseInstructionsTextView.isHidden = true
            courses[i].indicator.startAnimating()
            
            scrollView.addSubview(courses[i])
            
        }
        
        scrollView.center = CGPoint(x: view.center.x, y: view.center.y)
        
    }
    
    func updateCoursesData() {
        
        
        for i in 0...numberOfCourses! - 1 {
            
            courses[i].courseInstructionsTextView.text = courseInstructions[i]
            courses[i].courseInstructionsTextView.isScrollEnabled = false
            courses[i].courseInstructionsTextView.isScrollEnabled = true
            courses[i].courseInstructionsTextView.isHidden = false
            courses[i].courseMapImage.image = courseMaps[i]
            courses[i].courseMapImage.isHidden = false
            courses[i].courseNameLabel.text = courseNames[i]
            courses[i].courseNameLabel.isHidden = false
            courses[i].indicator.isHidden = true
            
        }
        
    }
    
    
    
    @IBAction func viewCoursesButtonPressed(_ sender: Any) {
        
        scrollView.isHidden = false
        dismissButton.isHidden = false
        blurView.isHidden = false
        blurView.alpha = 0
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            
            for i in 0...self.scrollView.subviews.count - 1 {
                var scrollFrame = self.scrollView.subviews[i].frame
                scrollFrame.origin.y = self.referanceView.frame.origin.y
                self.scrollView.subviews[i].frame = scrollFrame
            }
            
            
            var xframe = self.dismissButton.frame
            xframe.origin.y = xframe.origin.y - self.view.frame.height
            self.dismissButton.frame = xframe
            
            self.blurView.isHidden = false
            var blurAlpha = self.blurView.alpha
            blurAlpha = CGFloat(1)
            self.blurView.alpha = blurAlpha
            
        }, completion: { finished in })
        
    }
    
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        
        let registrationDownAlert = UIAlertController(title: "Registration Connection Error", message: "We were not able to connect to H2Open Plus+ Registration. \nPlease register online or at the event.", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        registrationDownAlert.addAction(dismiss)
        self.present(registrationDownAlert, animated: true, completion: nil)
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        
        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
            
            for i in 0...self.scrollView.subviews.count - 1 {
                var scrollFrame = self.scrollView.subviews[i].frame
                scrollFrame.origin.y = scrollFrame.origin.y + self.view.frame.height
                self.scrollView.subviews[i].frame = scrollFrame
            }
            
            var xframe = self.dismissButton.frame
            xframe.origin.y = xframe.origin.y + self.view.frame.height
            self.dismissButton.frame = xframe
            
            self.blurView.isHidden = false
            var blurAlpha = self.blurView.alpha
            blurAlpha = CGFloat(0)
            self.blurView.alpha = blurAlpha
            
        }, completion: { finished in
            self.scrollView.isHidden = true
            self.dismissButton.isHidden = true
            self.blurView.isHidden = true
        })
        
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
