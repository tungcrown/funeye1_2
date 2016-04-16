//
//  NotificationCell.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/9/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var messageTxt: UITextView!
    @IBOutlet weak var imgVideoThumb: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgAvatar.layer.cornerRadius = imgAvatar.frame.width / 2
        imgAvatar.clipsToBounds = true
    }

    
    func configureCell(notification: Notification) {
        DataService.instance.downloadAndSetImageFromUrl(notification.userSenderAvatar, imgView: imgAvatar, imageCache: ViewCommentVC.imageCache)
        let postThumb = notification.postThumb
        if postThumb != nil {
            DataService.instance.downloadAndSetImageFromUrl(postThumb!, imgView: imgVideoThumb, imageCache: ViewCommentVC.imageCache)
        }
        
        let str = "\(notification.userSenderName) vua \(notification.type) video cua ban"
        let textClickLength = notification.userSenderName.characters.count
        let myString = NSMutableAttributedString(string: str)
        let myRange = NSRange(location: 0, length: textClickLength) // range of "Swift"
        if notification.posId != nil {
            
            let notiId = notification.userSenderId
            let multipleAttributes = [
                NSForegroundColorAttributeName: UIColor.darkTextColor(),
                //NSForegroundColorAttributeName: UIFont(name:"HelveticaNeue-Bold", size: 16.0),
                NSFontAttributeName: UIFont.boldSystemFontOfSize(14.0),
                "MyCustomAttributeName": notiId]
            
            myString.addAttributes(multipleAttributes, range: myRange)
            messageTxt.attributedText = myString
        
        } else {
            print("post nil")
        }
    
    }
}
