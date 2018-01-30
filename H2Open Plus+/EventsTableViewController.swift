//
//  EventsTableViewController.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/15/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit

class EventTableCell: UITableViewCell {
    
    @IBOutlet weak var eventBackgroundImage: UIImageView!
    @IBOutlet weak var eventLogoImage: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    
}

class EventsTableViewController: UITableViewController {
    
    //Holds data that is loaded in loadData
    var eventNames: [String] = []
    var eventBackgrounds: [UIImage] = []
    var eventLogos: [UIImage] = []
    
    //Passed through to detail view
    var codes: [String] = []
    var eventDescriptions: [String] = []
    var numberOfCourses: [Int] = []
    
    //Keeps track of how large loadData file is
    var tableSize = 0
    
    //Creates refreshController for tableView
    var refreshController = UIRefreshControl()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        addRefresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableSize
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath) as! EventTableCell

        if eventNames.count == tableSize {
            cell.eventBackgroundImage.image = eventBackgrounds[indexPath.row]
            cell.eventLogoImage.layer.cornerRadius = 5
            cell.eventLogoImage.image = eventLogos[indexPath.row]
            cell.eventNameLabel.text = eventNames[indexPath.row]
            cell.eventNameLabel.layer.masksToBounds = true
            cell.eventNameLabel.layer.cornerRadius = 6
            cell.eventNameLabel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        }

        return cell
    }
    
    
    
    func loadData() {
        
        let url = URL(string: "https://h2openappdata.000webhostapp.com/EventTable.json")!
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        var task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                
                self.showConnectionError()
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        var jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                        
                        if let events = jsonResult["Events"] as? [[String: AnyObject]] {
                            
                            self.tableSize = events.count
                            
                            for event in events {
                                
                                if let eventName = event["Name"] as? String {
                                    self.eventNames.append(eventName)
                                } else {
                                    self.eventNames.append("Error loading event name")
                                }
                                
                                if let code = event["Code"] as? String {
                                    self.codes.append(code)
                                } else {
                                    self.codes.append("None")
                                }
                                
                                if let courseCount = event["Course Count"] as? Int {
                                    self.numberOfCourses.append(courseCount)
                                } else {
                                    self.numberOfCourses.append(0)
                                }
                                
                                if let imageLogoURL = NSURL(string: "https://h2openappdata.000webhostapp.com/Logos/\(event["Logo"] as! String)") {
                                    if let imgLogo = NSData(contentsOf: imageLogoURL as URL) {
                                        self.eventLogos.append(UIImage(data: imgLogo as Data)!)
                                    } else {
                                        self.eventLogos.append(UIImage(named: "LoadingError-1.png")!)
                                    }
                                } else {
                                    self.eventLogos.append(UIImage(named: "LoadingError-1.png")!)
                                }
                                
                                if loadImages {
                                    if let imageBGURL = NSURL(string: "https://h2openappdata.000webhostapp.com/Images/\(event["Background"] as! String)") {
                                        if let imgBG = NSData(contentsOf: imageBGURL as URL) {
                                            self.eventBackgrounds.append(UIImage(data: imgBG as Data)!)
                                        } else {
                                            self.eventBackgrounds.append(UIImage(named: "eventPlaceholder.png")!)
                                        }
                                    }
                                } else {
                                    self.eventBackgrounds.append(UIImage(named: "eventPlaceholder.png")!)
                                }
                                
                            }
                            
                            DispatchQueue.main.sync(execute: {
                                self.refreshController.endRefreshing()
                                self.tableView.reloadData()
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
    
    
    
    
    func addRefresh() {
        
        self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshController.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshController)
        
        self.refreshController.beginRefreshing()
        self.handleRefresh(refreshController)
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshController.frame.height - self.topLayoutGuide.length), animated: true)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.eventNames = []
        self.eventBackgrounds = []
        self.eventLogos = []
        
        self.codes = []
        self.eventDescriptions = []
        self.numberOfCourses = []
        
        self.loadData()
        
    }
    
    func showConnectionError() {
        let loadDataErrorAlert = UIAlertController(title: "Connection Error", message: "We were not able to connect to H2Open Plus+ at this time. Please check your internet connection or try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        loadDataErrorAlert.addAction(dismiss)
        self.present(loadDataErrorAlert, animated: true, completion: nil)
    }

    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showEventDetail" {
            
            let detailView = segue.destination as! EventDetailViewController
            
            if let row = self.tableView.indexPathForSelectedRow?.row {
                detailView.eventNameText = eventNames[row]
                detailView.banner = eventBackgrounds[row]
                detailView.logo = eventLogos[row]
                detailView.code = codes[row]
                detailView.numberOfCourses = numberOfCourses[row]
            }
            
        }
        
    }
    

}
