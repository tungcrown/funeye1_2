//
//  TabBarController.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/10/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class TabBarController: UITabBarController {
    
    let socket = SocketIOClient(socketURL: NSURL(string: "http://funeye.net:8080")!, options: [.Log(false), .ForcePolling(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSocketIO()
    }
    
    func setupSocketIO() {
        socket.on("notification") {data, ack in
            let tabItems = self.tabBar.items! as [UITabBarItem]
            tabItems[3].badgeValue = "1"
        }
        
        socket.on("connect") {data, ack in
            self.socket.emit("username", USER_ID)
        }
        socket.connect()
    }
}
