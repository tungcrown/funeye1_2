//
//  PostCell.swift
//  funeye
//
//  Created by Lê Thanh Tùng on 3/22/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import CoreData

class PostCell: UITableViewCell {
    
    @IBOutlet weak var imgProfileUser: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblTimeCreate: UILabel!
    
    @IBOutlet weak var imgVideoThumb: UIImageView!
    @IBOutlet weak var lblCoutViews: UILabel!
    
    @IBOutlet weak var lblCountLikes: UILabel!
    @IBOutlet weak var lblCountComments: UILabel!
    
    @IBOutlet weak var uiviewVideo: UIView!
    
    @IBOutlet weak var lblCaptionVideo: UILabel!
    
    @IBOutlet weak var imgCommentButton: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    
    var player: AVPlayer!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imgProfileUser.layer.cornerRadius = imgProfileUser.frame.width / 2
        imgProfileUser.clipsToBounds = true
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(post: Post, indexPath: Int!) {
        lblCaptionVideo.text = post.caption
        lblUserName.text = post.userName
        lblTimeCreate.text = timeAgoSinceDateString(post.timeCreate)
        lblCoutViews.text = "\(post.views)"
        lblCountLikes.text = "\(post.likes)"
        lblCountComments.text = "\(post.comments)"
        
        DataService.instance.downloadAndSetImageFromUrl(post.userAvatar, imgView: imgProfileUser, imageCache: ViewController.imageCache)
        //print(post.videoThumb)
        DataService.instance.downloadAndSetImageFromUrl(post.videoThumb, imgView: imgVideoThumb, imageCache: ViewController.imageCacheVideo)
 
        if post.isLikePost {
            btnLike.setImage(UIImage(named: "loved"), forState: .Normal)
        } else {
            btnLike.setImage(UIImage(named: "love"), forState: .Normal)
        }
    }
}
