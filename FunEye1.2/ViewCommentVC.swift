//
//  ViewCommentVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire
import SocketIOClientSwift


class ViewCommentVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var uiviewOldCmt: UIView!
    
    var btnPost: UIButton!
    var uivTextField: UIView!
    var textField: UITextField!
    
    static var imageCache = NSCache()
    
    var post_id: String!
    var comments = [Comment]()
    var nextCmtPage = 1
    
    let indicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        commentTableView.estimatedRowHeight = 70
        commentTableView.rowHeight = UITableViewAutomaticDimension
        
        print(post_id)
        
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.startAnimating()
        
        loadCommentData()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "More older comment!")
        refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        commentTableView.addSubview(self.refreshControl)
    }
    
    func refresh(sender:AnyObject)
    {
        print("load new data refresh")
        loadCommentData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        createInputField()
        registerKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unregisterKeyboardNotifications()
    }
    
    func registerKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewCommentVC.keyboardDidShow(_:)), name: UIKeyboardDidShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewCommentVC.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unregisterKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func keyboardDidShow(notification: NSNotification) {
        print("show keyboard")
        let userInfo: NSDictionary = notification.userInfo!
        let keyboardSize = userInfo.objectForKey(UIKeyboardFrameBeginUserInfoKey)!.CGRectValue.size
        
        self.uivTextField.frame = self.setFrameUiview(keyboardSize.height)
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(0.3) {
            
            self.uivTextField.frame = self.setFrameUiview(0.0)
        }
    }
    
    func setFrameUiview(bottom: CGFloat) -> CGRect {
        let heightUiview: CGFloat = 45.0
        let yUivew = self.view.frame.height - heightUiview - bottom
        let widthUiview = self.view.frame.width
        
        return CGRectMake(0, yUivew, widthUiview, heightUiview)
    }
    
    func createInputField() {
        uivTextField = UIView(frame: setFrameUiview(0.0))
        uivTextField.backgroundColor=UIColor.whiteColor()
        
        self.view.addSubview(uivTextField)
        
        //add button post
        btnPost = UIButton(frame: CGRectMake(self.view.frame.width - 58, 8, 50, 30))
        btnPost.setTitle("Post", forState: .Normal)
        btnPost.setTitleColor(UIColor(red: 100/255, green: 53/255, blue: 201/255, alpha: 1.0), forState: .Normal)
        btnPost.addTarget(self, action: #selector(self.btnPost(_:)), forControlEvents: .TouchUpInside)
        
        uivTextField.addSubview(btnPost)
        
        //add textfield
        textField = UITextField(frame: CGRectMake(8, 8, self.view.frame.width - 66, 30))
        textField.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 0.5)
        textField.font = UIFont(name: "Helvetica", size: 14.0)
        textField.layer.cornerRadius = 3.0
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1).CGColor
        textField.textColor = UIColor.darkTextColor()
        textField.placeholder = "Để lại nhận xét"
        
        uivTextField.addSubview(textField)
        
        //add border 
        let uivBoder = UIView(frame: CGRectMake(0, 0, self.view.frame.width, 1))
        uivBoder.backgroundColor = UIColor(red: 227/255, green: 227/255, blue: 227/255, alpha: 1)
        uivTextField.addSubview(uivBoder)
    }
    
    var checkDoneCmt = true
    func btnPost(sender: UIButton) {
        if textField.text != "" {
            let dataCmt = textField.text
            print("dataCmt \(dataCmt)")
            self.view.endEditing(true)
            if checkDoneCmt {
                checkDoneCmt = false
                Alamofire.request(.POST, URL_GET_COMMENT_POST(post_id), parameters: ["content": dataCmt!]).responseJSON { response in
                    self.checkDoneCmt = true
                    if let res = response.result.value as? Dictionary<String, AnyObject> {
                        print("Comnet Done \(res)")
                        self.textField.text = ""
                        
                        self.nextCmtPage = 1
                        self.comments = [Comment]()
                        self.loadCommentData()
                    } else {
                        print("response \(response)")
                    }
                }
            }
        }
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) ->
        UITableViewCell {

        if let cell = tableView.dequeueReusableCellWithIdentifier("ViewCommentCell") as? ViewCommentCell {
            cell.configureCell(comments[indexPath.row])
            return cell
        } else {
            return ViewCommentCell()
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showAlertClickComment()
        view.endEditing(true)
        
    }
   
    func showAlertClickComment() {
        let myActionSheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let blueAction = UIAlertAction(title: "Block", style: UIAlertActionStyle.Destructive) { (action) in
            print("Block action button tapped")
        }
        
        let redAction = UIAlertAction(title: "Trả lời", style: UIAlertActionStyle.Default) { (action) in
            print("Trả lời action button tapped")
        }
        
        let yellowAction = UIAlertAction(title: "Xóa", style: UIAlertActionStyle.Default) { (action) in
            print("Xóa action button tapped")
        }
        
        let cancelAction = UIAlertAction(title: "Hủy Bỏ", style: UIAlertActionStyle.Cancel) { (action) in
            print("Cancel action button tapped")
        }
        
        myActionSheet.addAction(blueAction)
        myActionSheet.addAction(redAction)
        myActionSheet.addAction(yellowAction)
        myActionSheet.addAction(cancelAction)
        
        self.presentViewController(myActionSheet, animated: true, completion: nil)
    }
    
    func loadCommentData() {
        let url =  URL_MAIN_DOMAIN + "/api/articles/\(post_id)/comments?page=\(nextCmtPage)&access_token=\(ACCESS_TOKEN)"
        Alamofire.request(.GET, url).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    for json in jsons {
                        let comment = Comment(dictionary: json)
                        self.comments.insert(comment, atIndex:0)
                    }
                    self.commentTableView.reloadData()
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
    @IBAction func backNewfeeds(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}
