//
//  ShowExploreVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/6/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SocketIOClientSwift

class ShowExploreVC: ViewController {
    
    var data: String!
    var cateName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = UIImage(named: "category_\(data)")! as UIImage
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(image,
                                forBarMetrics: .Default)
        self.title = cateName
        //self.navigationController?.title = cateName
    }
    
    override func getPostFromAlamofire(url: String) {
        let url = URL_GET_CATEGORY_POST(data)
        print("url load data category \(url)")
        let nsUrl = NSURL(string: url)!
        
        Alamofire.request(.GET, nsUrl).responseJSON { response in
            if let res = response.result.value as? Dictionary<String, AnyObject> {
                if let jsons = res["data"] as? [Dictionary<String, AnyObject>] {
                    print("load new data")
                    self.indicator.stopAnimating()
                    self.posts = [Post]()
                    for json in jsons {
                        let post = Post(dictionary: json)
                        DataService.instance.addPost(post)
                        self.posts.insert(post, atIndex: 0)
                        self.tableView.reloadData()
                    }
                }
            } else {
                print(response)
            }
        }
    }
}

