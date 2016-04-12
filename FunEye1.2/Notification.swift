//
//  File.swift
//  FunEye
//
//  Created by Lê Thanh Tùng on 4/9/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

class Notification {
    
    private var _id: String!
    private var _userSenderId: String!
    private var _userSenderName: String!
    private var _userSenderAvatar: String!
    
    private var _postId: String?
    private var _postThumb: String?
    
    private var _type: String!
    private var _timeCreate: String!
    
    var id: String {
        return _id
    }
    
    var userSenderId: String {
        return _userSenderId
    }
    
    var userSenderName: String {
        return _userSenderName
    }
    
    var userSenderAvatar: String {
        return _userSenderAvatar
    }
    
    var posId: String? {
        return _postId
    }
    
    var postThumb: String? {
        return _postThumb
    }
    
    var type: String {
        return _type
    }
    
    var timeCreate: String {
        return _timeCreate
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        if let id = dictionary["_id"] as? String {
            self._id = id
        }
        
        if let type = dictionary["type"] as? String {
            self._type = type
        }
        
        if let timeCreate = dictionary["created"] as? String {
            self._timeCreate = timeCreate
        }
        
        if let from = dictionary["actorId"] as? Dictionary<String, AnyObject> {
            if let userName = from["username"] as? String {
                self._userSenderName = userName
            }
            
            if let userId = from["id"] as? String {
                self._userSenderId = userId
            }
            
            if let userAvatar = from["avatar"] as? String {
                self._userSenderAvatar = userAvatar
            } else {
                self._userSenderAvatar = "https://graph.facebook.com/tungcrown2016/picture"
            }
            
        }
        
        if let from = dictionary["articleId"] as? Dictionary<String, AnyObject> {
            if let postId = from["id"] as? String {
                self._postId = postId
            }
            
            if let postThumb = from["videothumb"] as? String {
                self._postThumb = postThumb
            } else {
                self._postThumb = "https://graph.facebook.com/tungcrown2016/picture"
            }
            
        }
    }
    
}