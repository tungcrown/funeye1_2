//
//  ProfileVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 4/7/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {
    
    var userId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userId != nil {
            print(userId)
        }
    }
}
