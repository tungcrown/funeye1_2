//
//  ViewSinglePostVC.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/10/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import Alamofire

class ViewSinglePostVC: ViewController {

    var postId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if postId != nil {
            print("postId \(postId)")
        }
    }
    
    
    var data: String!
    var cateName: String!
    
    override func getPostFromAlamofire(url: String) {
        let url = URL_GET_SINGLE_POST(postId)
        print("url load data category \(url)")
        let nsUrl = NSURL(string: url)!
        Alamofire.request(.GET, nsUrl).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                print(res)
                self.indicator.stopAnimating()
                self.posts = [Post]()
                let post = Post(dictionary: res)
                DataService.instance.addPost(post)
                self.posts.insert(post, atIndex: 0)
                self.tableView.reloadData()
            } else {
                print(response)
            }
        }
    }
    
    @IBAction func backToExploreVC() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
