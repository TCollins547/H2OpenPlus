//
//  HomeViewController.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/15/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit
import MessageUI

var loadImages = true

class HomeViewController: UIViewController, UIScrollViewDelegate, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var referanceView: UIView!
    @IBOutlet weak var settingsButton: UIButton!
    
    @IBOutlet weak var pageController: UIPageControl!
    
    //Creates instances of the 3 subviews that will be shown
    let subView1: HomeSubView = Bundle.main.loadNibNamed("HomeSubView", owner: self, options: nil)?.first as! HomeSubView
    let subView2: HomeSubView = Bundle.main.loadNibNamed("HomeSubView", owner: self, options: nil)?.first as! HomeSubView
    let subView3: HomeSubView = Bundle.main.loadNibNamed("HomeSubView", owner: self, options: nil)?.first as! HomeSubView
    var subViews: [HomeSubView] = []
    
    //Holds data for each part of the subViews
    var typeImages: [UIImage] = []
    var titles: [String] = []
    var descriptions: [String] = []
    var imageURLs: [String] = []
    var images: [UIImage] = []
    
    //Controls the settings button
    var contactAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let willLoadImages = UserDefaults.standard.object(forKey: "loadImages") {
            loadImages = willLoadImages as! Bool
        } else {
            UserDefaults.standard.set(true, forKey: "loadImages")
        }
        
        //Appends all subviews into array subViews
        subViews.append(subView1); subViews.append(subView2); subViews.append(subView3)
        
        loadData()
        createSubViews()
        setupAlertController()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    **
    */
    func createSubViews() {
        
        //Sets up scrollView for handling subViews and adds backgroundImage
        scrollView.delegate = self
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(subViews.count), height: view.frame.height)
        
        let backgroundImage = UIImageView(image: UIImage(named: "HomeBackgroundImage.jpeg"))
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.frame = CGRect(x: 0, y: 0, width: scrollView.frame.width, height: view.frame.height)
        scrollView.addSubview(backgroundImage)
        
        
        var i = 0
        //Configures each subView and adds to the scrollView
        for subView in subViews {
            
            //Hide all objects until view has data loaded
            subView.bannerImageView.isHidden = true
            subView.typeImageView.isHidden = true
            subView.headerLabel.isHidden = true
            subView.descriptionTextView.isHidden = true
            
            //Starts animating indicators on all subviews while loading
            subView.indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            subView.indicator.color = UIColor(red: 41/255, green: 53/255, blue: 117/255, alpha: 1)
            subView.indicator.startAnimating()
            
            //Aligns center to each page of the scrollView
            subView.frame = CGRect(x: 0, y: 0, width: Int(self.view.frame.width - 60), height: Int(pageController.frame.origin.y - settingsButton.frame.origin.y))
            //subView.frame.size = referanceView.frame.size
            subView.center = CGPoint(x: referanceView.center.x + (view.frame.width * CGFloat(i)), y: referanceView.center.y); i += 1
            subView.layer.cornerRadius = 8
            
            scrollView.addSubview(subView)
 
            
        }
        
    }
    
    /*
    **
    */
    func loadData() {
        
        //Calls to database set up to retrieve JSON
        let url = URL(string: "https://h2openappdata.000webhostapp.com/HomeAnnouncementsTest.json")!
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                
                self.showConnectionError()
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        var jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                        
                        if let announcements = jsonResult["Home Announcements"] as? [[String: AnyObject]] {
                            for announce in announcements {
                                
                                if let type = announce["Type"] as? String {
                                    self.typeImages.append(UIImage(named: "\(type).png")!)
                                } else {
                                    self.typeImages.append(UIImage(named: "typePlaceholder.png")!)
                                }
                                
                                if let title = announce["Title"] as? String {
                                    self.titles.append(title)
                                } else {
                                    self.titles.append("Error loading title")
                                }
                                
                                if let description = announce["Description"] as? String {
                                    self.descriptions.append(description)
                                } else {
                                    self.descriptions.append("Error loading description")
                                }
                                
                                if loadImages {
                                    if let imageURL = announce["Image"] as? String {
                                        self.imageURLs.append(imageURL)
                                    }
                                } else {
                                    self.images.append(UIImage(named: "homePlaceholder.jpeg")!)
                                }
                                
                            }
                            
                            DispatchQueue.main.sync(execute: {
                                self.displayData()
                                
                                if loadImages {
                                    self.loadImageData()
                                } else {
                                    self.displayImages()
                                }
                                
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
    
    func loadImageData() {
        for imageURL in imageURLs {
            if let imageURLData = NSURL(string: "https://h2openappdata.000webhostapp.com/Images/\(imageURL)") {
                if let imgdata = NSData(contentsOf: imageURLData as URL) {
                    self.images.append(UIImage(data: imgdata as Data)!)
                } else {
                    self.images.append(UIImage(named: "homePlaceholder.jpeg")!)
                }
            } else {
                self.images.append(UIImage(named: "homePlaceholder.jpeg")!)
            }
            
        }
        
        displayImages()
        
    }
    
    func displayImages() {
        for i in 0...subViews.count - 1 {
            subViews[i].bannerImageView.isHidden = false
            subViews[i].bannerImageView.image = images[i]
        }
    }
    
    
    /*
    **
    */
    func displayData() {
        
        for i in 0...subViews.count - 1 {
            
            subViews[i].descriptionTextView.isHidden = false
            subViews[i].descriptionTextView.text = descriptions[i]
            
            subViews[i].headerLabel.isHidden = false
            subViews[i].headerLabel.text = titles[i]
            
            subViews[i].typeImageView.isHidden = false
            subViews[i].typeImageView.image = typeImages[i]
            
            subViews[i].indicator.isHidden = true
        }
        
        
    }
    
    
    func showConnectionError() {
        let loadDataErrorAlert = UIAlertController(title: "Connection Error", message: "We were not able to connect to H2Open Plus+ at this time. Please check your internet connection or try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        loadDataErrorAlert.addAction(dismiss)
        self.present(loadDataErrorAlert, animated: true, completion: nil)
    }
    
    
    
    
    func setupAlertController() {

        
        let contactButton = UIAlertAction(title: "Contact Us", style: .default, handler:{ (action) -> Void in
            let mailComposeViewController = self.configuredMailComposeViewController(sendType: "Feedback", sendBody: "Hi H2Open Team, \n\nI would like to tell you about your program.")
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: { UIApplication.shared.statusBarStyle = .lightContent })
            } else {
                //self.showSendMailErrorAlert()
            }
        })
        
        let reportButton = UIAlertAction(title: "Report A Problem", style: .default, handler:{ (action) -> Void in
            let mailComposeViewController = self.configuredMailComposeViewController(sendType: "App Problem", sendBody: "Hi H2Open Team, \n\nI've found a bug in the current version of the app.")
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: { UIApplication.shared.statusBarStyle = .lightContent })
            } else {
                //self.showSendMailErrorAlert()
            }
        })
        
        let loadImagesButton = UIAlertAction(title: "Toggle Image Loads", style: .default, handler: { (action) -> Void in
            if loadImages {
                UserDefaults.standard.set(false, forKey: "loadImages")
                loadImages = false
                let loadImageInfo = UIAlertController(title: "Disabling Image Loading", message: "Disabling images will stop background and header images from loading. This will give better load times.\nThis excludes maps.", preferredStyle: .alert)
                let dismiss = UIAlertAction(title: "OK", style: .destructive, handler: nil)
                loadImageInfo.addAction(dismiss)
                self.present(loadImageInfo, animated: true, completion: nil)
            } else {
                loadImages = true
                
                self.titles = []
                self.typeImages = []
                self.descriptions = []
                self.imageURLs = []
                self.images = []
                
                for subView in self.subViews {
                    subView.bannerImageView.isHidden = true
                    subView.descriptionTextView.isHidden = true
                    subView.typeImageView.isHidden = true
                    subView.headerLabel.isHidden = true
                    subView.indicator.isHidden = false
                }
                
                
                self.loadData()
                UserDefaults.standard.set(true, forKey: "loadImages")
            }
        
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler:{ (action) -> Void in })
        
        contactAlertController.addAction(loadImagesButton); contactAlertController.addAction(contactButton); contactAlertController.addAction(reportButton); contactAlertController.addAction(cancelButton)
    
    }
    
    func configuredMailComposeViewController(sendType: String, sendBody: String) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.navigationBar.tintColor = UIColor.white
        mailComposerVC.setToRecipients(["H2OpenPlusApp@outlook.com"])
        mailComposerVC.setSubject(sendType)
        mailComposerVC.setMessageBody(sendBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    @IBAction func settingsButtonPressed(_ sender: Any) {
        
        self.present(contactAlertController, animated: true, completion: nil)
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / view.frame.width)
        pageController.currentPage = Int(pageIndex)
        
    }

}
