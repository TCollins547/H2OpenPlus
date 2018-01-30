//
//  ResultsDetailViewController.swift
//  H2Open Plus+
//
//  Created by Tyler Collins on 4/17/17.
//  Copyright © 2017 Tyler Collins. All rights reserved.
//

import UIKit

class ResultDetailCell: UITableViewCell {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var bibLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
}

class ResultsDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var raceSelectView: UIView!
    @IBOutlet weak var racePickerView: UIPickerView!
    
    var jsonResult: [String: AnyObject] = [:]
    var tableSize = 0
    
    var placeImages: [UIImage] = []
    var names: [String] = []
    var bibNumbers: [String] = []
    var ages: [String] = []
    var times: [String] = []
    
    var events: [String] = []
    var filter: String = "No Filter Selected"
    var previousFilter = ""
    
    var eventCode: String?
    var placingType: String?
    
    var refreshController = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Table View")

        addRefresh()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addRefresh() {
        
        self.raceSelectView.layer.masksToBounds = true
        self.raceSelectView.layer.cornerRadius = 8
        
        self.refreshController.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshController.addTarget(self, action: #selector(self.handleRefresh(_:)), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refreshController)
        
        self.refreshController.beginRefreshing()
        self.handleRefresh(refreshController)
        self.tableView.setContentOffset(CGPoint(x: 0, y: -self.refreshController.frame.height - self.topLayoutGuide.length), animated: true)
    }
    
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.names = []
        self.bibNumbers = []
        self.ages = []
        self.times = []
        
        loadData()
        
    }
    
    func loadData() {
        
        let url = URL(string: "https://h2openappdata.000webhostapp.com/Results/\(eventCode!).json")!
        
        let request = URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        
        var task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error!)
            } else {
                print("JSON Data Loaded")
                
                if let urlContent = data {
                    
                    do {
                        
                        
                        self.jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as! [String: AnyObject]
                            
                        DispatchQueue.main.sync(execute: {
                            self.changeFilter()
                            self.racePickerView.reloadAllComponents()
                            self.refreshController.endRefreshing()
                        })
                        
                    } catch {
                        
                        let noResultsAlert = UIAlertController(title: "No Results Found", message: "There are currently no results for this event. Please check back later.", preferredStyle: .alert)
                        let dismiss = UIAlertAction(title: "OK", style: .destructive, handler: { (action) -> Void in
                            self.performSegue(withIdentifier: "unwindToResults", sender: self)
                        })
                        noResultsAlert.addAction(dismiss)
                        self.present(noResultsAlert, animated: true, completion: nil)
                    }
                }
            }
        }
        
        task.resume()
        
        
    }
    
    
    func changeFilter() {
        
        self.names = []
        self.bibNumbers = []
        self.ages = []
        self.times = []
        
        if self.filter == "No Filter Selected" {
            
            var subEvents = Array(jsonResult.keys)
            
            if subEvents.contains("Age Group") {
                subEvents.remove(at: subEvents.index(of: "Age Group")!)
            }
            
            if subEvents.contains("Unknown") {
                subEvents.remove(at: subEvents.index(of: "Unknown")!)
            }
            
            var sortedArray = subEvents.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
            
            if sortedArray.contains("Overall") {
                let element = sortedArray.remove(at: sortedArray.index(of: "Overall")!)
                sortedArray.insert(element, at: 0)
            }
            
            self.events = sortedArray
            self.filter = self.events[0]
            self.title = self.filter
        }
        
        if let events = jsonResult[self.filter] as? [[String: AnyObject]] {
            self.tableSize = events.count
            for event in events {
                
                if let name = event["Name"] as? String {
                    self.names.append(name)
                } else {
                    self.names.append("Loading Error")
                }
                
                if let bib = event["Bib #"] as? String {
                    self.bibNumbers.append(bib)
                } else {
                    self.bibNumbers.append("Loading Error")
                }
                
                if let age = event["Age"] as? String {
                    self.ages.append(age)
                } else {
                    self.ages.append("Loading Error")
                }
                
                if let time = event["Finish"] as? String {
                    self.times.append((time as NSString).substring(to: 8))
                } else {
                    self.times.append("Loading Error")
                }
            }
            
        }
        
        self.tableView.reloadData()
        
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return names.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultDetailCell", for: indexPath) as! ResultDetailCell
        
        if tableSize == names.count {
            cell.nameLabel.text = names[indexPath.row]
            cell.bibLabel.text = "Bib: #" + bibNumbers[indexPath.row]
            cell.ageLabel.text = "Age: " + ages[indexPath.row]
            cell.timeLabel.text = times[indexPath.row]
            
            cell.placeLabel.text = String (indexPath.row + 1)
            cell.placeLabel.textColor = UIColor.white
            
            if placingType == "Finals" {
                if indexPath.row == 0 {
                    cell.placeImageView.image = UIImage(named: "gold.png")
                } else if indexPath.row == 1 {
                    cell.placeImageView.image = UIImage(named: "silver.png")
                } else if indexPath.row == 2 {
                    cell.placeImageView.image = UIImage(named: "bronze.png")
                } else {
                    cell.placeImageView.image = UIImage(named: "blue.png")
                }
            } else {
                var topPlaces = Int(placingType!)
                if indexPath.row < topPlaces! {
                    cell.placeImageView.image = UIImage(named: "gold.png")
                } else {
                    cell.placeImageView.image = UIImage(named: "blue.png")
                }
            }
        }
        
        return cell
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return events.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return events[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        previousFilter = filter
        filter = events[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let myTitle = NSAttributedString(string: events[row], attributes: [NSAttributedStringKey.font:UIFont(name: "Georgia", size: 40.0)!,NSAttributedStringKey.foregroundColor:UIColor.white])
        return myTitle
    }

    
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        
        previousFilter = filter
        raceSelectView.isHidden = false
        tableView.isUserInteractionEnabled = false
        
    }

    @IBAction func selectButtonPressed(_ sender: Any) {
        
        self.title = filter
        self.changeFilter()
        
        raceSelectView.isHidden = true
        tableView.isUserInteractionEnabled = true
        
    }
    
    @IBAction func dismissButtonPressed(_ sender: Any) {
        
        raceSelectView.isHidden = true
        tableView.isUserInteractionEnabled = true
        filter = previousFilter
        
    }

}
