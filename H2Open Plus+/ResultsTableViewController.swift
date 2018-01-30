//
//  ResultsTableViewController.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/15/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit

class ResultsEventTableCell: UITableViewCell {
    
    @IBOutlet weak var eventLogo: UIImageView!
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDateLabel: UILabel!
    @IBOutlet weak var eventStatusImage: UIImageView!
    
}

class ResultsTableViewController: UITableViewController {
    
    var eventNames: [String] = []
    var eventDates: [String] = []
    var eventStatus: [String] = []
    var eventLogos: [UIImage] = []
    
    var tableSize = 0
    
    var eventCodes: [String] = []
    var placing: [String] = []
    
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
        return eventNames.count
    }
    
    
    func loadData() {
        
        let url = URL(string: "https://h2openappdata.000webhostapp.com/ResultsTable.json")!
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        var task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                
                self.showConnectionError()
                
            } else {
                print("JSON Data Loaded")
                if let urlContent = data {
                    do {
                        var jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                        if let events = jsonResult["Events"] as? [[String: AnyObject]] {
                            
                            self.tableSize = events.count
                            
                            for event in events {
                                
                                if let eventName = event["Name"] as? String {
                                    self.eventNames.append(eventName)
                                }
                                
                                if let date = event["Date"] as? String {
                                    self.eventDates.append(date)
                                }
                                
                                if let status = event["Status"] as? String {
                                    self.eventStatus.append(status)
                                }
                                
                                if let code = event["Code"] as? String {
                                    self.eventCodes.append(code)
                                }
                                
                                if let type = event["Type"] as? String {
                                    self.placing.append(type)
                                }
                                
                                if let imageLogoURL = NSURL(string: "https://h2openappdata.000webhostapp.com/Logos/\(event["Image"] as! String)") {
                                    if let imgLogo = NSData(contentsOf: imageLogoURL as URL) {
                                        self.eventLogos.append(UIImage(data: imgLogo as Data)!)
                                    } else {
                                        self.eventLogos.append(UIImage(named: "LoadingError-1.png")!)
                                    }
                                } else {
                                    self.eventLogos.append(UIImage(named: "LoadingError-1.png")!)
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
        self.eventLogos = []
        self.eventDates = []
        self.eventStatus = []
        self.eventCodes = []
        self.placing = []
        
        loadData()
        
    }
    
    func showConnectionError() {
        let loadDataErrorAlert = UIAlertController(title: "Connection Error", message: "We were not able to connect to H2Open Plus+ at this time. Please check your internet connection or try again later", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Dismiss", style: .destructive, handler: nil)
        loadDataErrorAlert.addAction(dismiss)
        self.present(loadDataErrorAlert, animated: true, completion: nil)
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultEventCell", for: indexPath) as! ResultsEventTableCell

        if tableSize == eventNames.count {
            
            cell.eventNameLabel.isHidden = false
            cell.eventDateLabel.isHidden = false
            cell.eventNameLabel.text = eventNames[indexPath.row]
            cell.eventDateLabel.text = eventDates[indexPath.row]
            
            if eventStatus[indexPath.row] == "Final" {
                cell.eventStatusImage.image = UIImage(named: "ResultsFinal.png")
            } else if eventStatus[indexPath.row] == "None" {
                cell.eventStatusImage.image = UIImage(named: "ResultsNone.png")
            } else {
                cell.eventStatusImage.image = UIImage(named: "ResultsProgress.png")
            }
            
            cell.eventLogo.image = eventLogos[indexPath.row]
            
        }

        return cell
    }
    
    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showEventResults" {
            
            let detailViewController = segue.destination as! ResultsDetailViewController
            if let row = self.tableView.indexPathForSelectedRow?.row {
                detailViewController.eventCode = self.eventCodes[row]
                detailViewController.placingType = self.placing[row]
            }
        }
    }
    
    @IBAction func unwindToEvents(segue: UIStoryboardSegue) {
    
    }
 

}
