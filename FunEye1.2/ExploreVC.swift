//
//  ExploreVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ExploreVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tabeviewCategories: UITableView!
    @IBOutlet weak var uivTrending: UIView!
    
    var topics = [Dictionary<String, AnyObject?>]()
    
    var refreshControl: UIRefreshControl!
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabeviewCategories.delegate = self
        tabeviewCategories.dataSource = self
        
        setupRefreshControl()
        
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        loadCotegory()
        loadTrending()
    }
    
    func loadCotegory() {
        print(URL_GET_CATEGORIES)
        Alamofire.request(.GET, URL_GET_CATEGORIES).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        for json in jsons {
                            if let id = json["_id"] as? Int {
                                let topic = ["_id": id, "image" : "https://graph.facebook.com/246809342331820/picture", "name": json["name"], "backgroundColor": json["color"]]
                                self.topics.append(topic)
                            }
                        }
                        self.indicator.stopAnimating()
                        self.tabeviewCategories.reloadData()
                        self.refreshControl.endRefreshing()
                    }
                } else {
                    print("Load topic follow \(response)")
                }
            }
        }
    }
    
    func loadTrending() {
        Alamofire.request(.GET, URL_GET_TRENDING).responseJSON { response in
            if response.result.error != nil {
                print("error load follow \(response.result.error)")
            } else {
                if let res = response.result.value as? Dictionary<String, AnyObject> {
                    if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                        for (index, json) in jsons.enumerate() {
                            let width = self.view.frame.size.width / 2 - 8 - 2
                            var frame: CGRect
                            var x: CGFloat
                            var y: CGFloat!
                            
                            let check = index % 2
                            if check == 0 {
                                y = CGFloat(index * 25 / 2 + index * 4 / 2)
                                x = 0
                            } else {
                                y = CGFloat((index - 1) * 25 / 2 + (index - 1) * 4 / 2)
                                x = width + 4
                            }
                            
                            frame = CGRectMake(x, y, width, 25.0)
                            let btnTrend = UIButton(frame: frame)
                            if let trend = json["_id"] as? String {
                                btnTrend.setTitle(trend, forState: .Normal)
                            } else {
                                continue
                            }
                            
                            btnTrend.setTitleColor(UIColor.darkTextColor(), forState: .Normal)
                            btnTrend.titleLabel!.font =  UIFont(name: "HelveticaNeue-Thin", size: 14)
                            btnTrend.backgroundColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
                            btnTrend.layer.cornerRadius = 3.0
                            
                            btnTrend.addTarget(self, action: #selector(self.btnChooseTrend(_:)), forControlEvents: .TouchUpInside)
                            
                            self.uivTrending.addSubview(btnTrend)
                        }
                    }
                }
            }
        }
    }
    
    func btnChooseTrend(sender: UIButton) {
        print("tap bt")
        
        let data = sender.titleForState(.Normal)
        if let showExploreVC = storyboard!.instantiateViewControllerWithIdentifier("ShowExploreVC") as? ShowExploreVC {
            showExploreVC.type = "hashtag"
            showExploreVC.data = data
            showExploreVC.cateName = data
            
            self.navigationController?.showViewController(showExploreVC, sender: nil)
        }
    }
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Load new post")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        tabeviewCategories.addSubview(self.refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        loadCotegory()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier("ExploreCell") as? ExploreCell {

            let topic = topics[indexPath.row]
            cell.configureCell(topic)
            cell.btnChooseCategory.tag = indexPath.row
            cell.btnChooseCategory.addTarget(self, action: #selector(self.btnChooseCategoryACTION(_:)), forControlEvents: .TouchUpInside)
            
            return cell
        
        } else {
            return ExploreCell()
        }
    }
    
    @IBAction func btnMenuQuickACTION(sender: UIButton) {
        let tag = sender.tag
        var cateId: String!
        
        if tag == 1 {
            cateId = "New"
        } else if tag == 2 {
            cateId = "Hot"
        } else if tag == 3 {
            cateId = "Hit"
        }
        
        performSegueWithIdentifier("ShowExploreVC", sender: cateId)
    }
    
    func btnChooseCategoryACTION(sender: UIButton) {
        let tag = sender.tag
        performSegueWithIdentifier("ShowExploreVC", sender: tag)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowExploreVC" {
            if let showExploreVC = segue.destinationViewController as? ShowExploreVC {
                if let dataSender = sender as? Int {
                    showExploreVC.type = "category"
                    if let cateId = topics[dataSender]["_id"] as? Int {
                        showExploreVC.data = "\(cateId)"
                    }
                    if let name = topics[dataSender]["name"] as? String {
                        showExploreVC.cateName = name
                    }
                }
            }
        }
    }
}
