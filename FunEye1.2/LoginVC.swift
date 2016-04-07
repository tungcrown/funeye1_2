//
//  LoginVC.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/30/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class LoginVC: UIViewController {

    @IBOutlet weak var uivBackground: UIView!
    @IBOutlet weak var uivLogin: MaterialView!
    
    
    private var video: Video!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playVideoBackground()
        
        
        //self.view.addSubview(FBSDKLoginButton.init(frame: CGRectMake(0,0,180,40)))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.uivLogin.alpha = 0
        
        if NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY) != nil {
            ACCESS_TOKEN = NSUserDefaults.standardUserDefaults().valueForKey(ACCESS_TOKEN_KEY)! as! String
            video.stopVideo()
            performSegueWithIdentifier("FirstFollowVC", sender: nil)
        }
        
        UIView.animateWithDuration(1.5) {
            self.uivLogin.alpha = 0.9
        }
    }
    
    func playVideoBackground() {
        if let path = NSBundle.mainBundle().pathForResource("beach", ofType: "mp4") {
            let urlVideo = NSURL(fileURLWithPath: path)
            video = Video(pathVideo: urlVideo, UIViewVideo: uivBackground, loop: true)
            video.isMuteVideo = true
        } else {
            print("Can't load path Video!")
        }
    }
    
    @IBAction func btnLoginFacebook(sender: UIButton) {
        let Facebooklogin = FBSDKLoginManager()
        
        Facebooklogin.logInWithReadPermissions(["email", "public_profile", "user_friends"]) { (FbResult: FBSDKLoginManagerLoginResult!, FbError: NSError!) in
            
            if FbError != nil {
                print("Facebook Login fail \(FbError)")
            } else {
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                let userFbId = FBSDKAccessToken.currentAccessToken().userID
                
                print("Successfully login with Facebook user_id \(userFbId) accessToken \(accessToken)")
                
                FBSDKGraphRequest(graphPath: "me?fields=id,name,email,gender", parameters: nil).startWithCompletionHandler({ (connection: FBSDKGraphRequestConnection!, fbResult: AnyObject!, error: NSError!) in
                    
                    if error != nil {
                        print(error.debugDescription)
                    } else {
                        print(fbResult)
                        let urlPost = URL_LOGIN_FACEBOOK
                        Alamofire.request(.POST, urlPost, parameters: ["accessToken": accessToken, "data" : fbResult]).responseJSON { response in
                            
                            if let res = response.result.value as? Dictionary<String, AnyObject> {
                                    print("data login \(res)")
                                    ACCESS_TOKEN = res["token"] as? String
                                
                                    let uid = res["id"] as! Int
                                    USER_ID = "\(uid)"
                                
                                    print("userFunEyeID \(USER_ID)")
                                    NSUserDefaults.standardUserDefaults().setObject(ACCESS_TOKEN!, forKey: ACCESS_TOKEN_KEY)
                                    NSUserDefaults.standardUserDefaults().setObject(USER_ID!, forKey: USER_ID_KEY)
                                
                                    NSUserDefaults.standardUserDefaults().synchronize()
                                    
                                    dispatch_async(dispatch_get_main_queue()) {
                                        [unowned self] in
                                        self.video.stopVideo()
                                        self.performSegueWithIdentifier("FirstFollowVC", sender: USER_ID)
                                    }
                                
                            } else {
                                print("response \(response)")
                            }
                        }
                    }
                })
            }
        }
    }
    
    

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "FirstFollowVC" {
            if let FirstFollowVC = segue.destinationViewController as? FirstFollowVC {
                if let user_id = sender as? String {
                    FirstFollowVC.user_id = user_id
                }
            }
        }
    }

}
