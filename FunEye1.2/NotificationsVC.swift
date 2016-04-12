//
//  NotificationsVC.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/9/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var notificationsTable: UITableView!
    
    var notifications = [Notification]()
    var nextCmtPage = 1
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notificationsTable.delegate = self
        notificationsTable.dataSource = self
        
        setupRefreshConrol()
        
        loadDataViaAPI()
        putNotificationRead()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell") as? NotificationCell {
            let noti = notifications[indexPath.row]
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.myMethodToHandleTap(_:)))
            tap.numberOfTapsRequired = 1
            cell.messageTxt.addGestureRecognizer(tap)
           
            cell.imgVideoThumb.tag = indexPath.row
            let tapImg = UITapGestureRecognizer(target: self, action: #selector(NotificationsVC.showViewSingleVC(_:)))
            tapImg.numberOfTapsRequired = 1
            cell.imgVideoThumb.userInteractionEnabled = true
            cell.imgVideoThumb.addGestureRecognizer(tapImg)
            
            cell.configureCell(noti)
            return cell
        } else {
            return NotificationCell()
        }
    }
    
    func putNotificationRead() {
        Alamofire.request(.PUT, URL_PUT_READ_NOTIFICATION)
    }
    
    func loadDataViaAPI() {
        let url =  URL_GET_NOTIFICATION("1")
        
        Alamofire.request(.GET, url).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        let noti = Notification(dictionary: json)
                        self.notifications.insert(noti, atIndex:0)
                    }
                    self.notificationsTable.reloadData()
                }
                
                if let isNext = res["isNext"] as? Bool where isNext == true {
                    self.nextCmtPage += 1
                    self.refreshControl.endRefreshing()
                } else {
                    self.refreshControl.endRefreshing()
                    self.refreshControl.removeFromSuperview()
                    
                }
                
                self.indicator.stopAnimating()
            } else {
                print("comment nil")
            }
        }
    }
    func setupRefreshConrol() {
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()

        
        refreshControl = UIRefreshControl()
        //refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        notificationsTable.addSubview(self.refreshControl)
    }

    func refresh(sender:AnyObject)
    {
        print("load new data refresh")
        loadDataViaAPI()
    }
    
    func setupTapOnNotification() {
        
    }
    
    func myMethodToHandleTap(sender: UITapGestureRecognizer) {
        print("taptap")
        
        let myTextView = sender.view as! UITextView
        let layoutManager = myTextView.layoutManager
        
        // location of tap in myTextView coordinates and taking the inset into account
        var location = sender.locationInView(myTextView)
        location.x -= myTextView.textContainerInset.left;
        location.y -= myTextView.textContainerInset.top;
        
        // character index at tap location
        let characterIndex = layoutManager.characterIndexForPoint(location, inTextContainer: myTextView.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        // if index is valid then do something.
        if characterIndex < myTextView.textStorage.length {
            
            // print the character index
            print("character index: \(characterIndex)")
            
            // print the character at the index
            let myRange = NSRange(location: characterIndex, length: 1)
            let substring = (myTextView.attributedText.string as NSString).substringWithRange(myRange)
            print("character at index: \(substring)")
            
            // check if the tap location has a certain attribute
            let attributeName = "MyCustomAttributeName"
            let attributeValue = myTextView.attributedText.attribute(attributeName, atIndex: characterIndex, effectiveRange: nil) as? String
            if let value = attributeValue {
                print("You tapped on \(attributeName) and the value is: \(value)")
                let dataPass = value
                //self.performSegueWithIdentifier("ViewSinglePostVC", sender: dataPass)
                if let profileVC = storyboard!.instantiateViewControllerWithIdentifier("ProfileVC") as? ProfileVC {
                    profileVC.userId = dataPass
                    self.navigationController?.showViewController(profileVC, sender: nil)
                }
            }
            
        }
    }
    
    func showViewSingleVC(sender: UITapGestureRecognizer) {
        let tag = sender.view!.tag
        let dataPass = notifications[tag].id
        print("dataPass \(dataPass)")
        self.performSegueWithIdentifier("ViewSinglePostVC", sender: dataPass)
        /*
        if let notificationsVC = storyboard!.instantiateViewControllerWithIdentifier("ViewSinglePostVC") as? ViewSinglePostVC {
            notificationsVC.postId = notifications[tag].posId
            notificationsVC.isViewNextComment = true
            self.navigationController?.showViewController(notificationsVC, sender: nil)
        }*/
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewSinglePostVC" {
            if let notificationsVC = segue.destinationViewController as? ViewSinglePostVC {
                if let dctUrl = sender as? String {
                    for noti in notifications {
                        if noti.id == dctUrl {
                            if (noti.posId != nil) {
                                if noti.type == "comment" {
                                    notificationsVC.postId = noti.posId
                                    notificationsVC.isViewNextComment = true
                                } else {
                                    notificationsVC.postId = noti.posId
                                    notificationsVC.isViewNextComment = false
                                }
                            }
                            break
                        }
                    }
                }
            }
        }
    }
}
