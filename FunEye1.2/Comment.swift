//
//  Comment.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/31/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

class Comment {
    private var _id: String!
    private var _userName: String!
    private var _userId: String!
    private var _caption: String!
    private var _timeCreate: String!
    private var _userAvatar: String!
    
    var userName: String {
        return _userName
    }
    
    var id: String {
        return _id
    }
    
    var userId: String {
        return _userId
    }
    
    var caption: String {
        if _caption != nil {
            return _caption
        } else {
            return " "
        }
    }
    
    var userAvatar: String {
        return _userAvatar
    }
    
    var timeCreate: String {
        return _timeCreate
    }
    init(dictionary: Dictionary<String, AnyObject>) {
        if let id = dictionary["_id"] as? String {
            self._id = id
        }
        
        if let from = dictionary["from"] as? Dictionary<String, AnyObject> {
            if let userName = from["username"] as? String {
                self._userName = userName
            }
            
            if let userId = from["id"] as? String {
                self._userId = userId
            }
            
            if let userAvatar = from["avatar"] as? String {
                self._userAvatar = userAvatar
            } else {
                self._userAvatar = "https://graph.facebook.com/tungcrown2016/picture"
            }
            
        }
        
        if let timeCreate = dictionary["created"] as? String {
            self._timeCreate = timeCreate
        }
        
        if let caption = dictionary["content"] as? String {
            self._caption = caption
        }
    }
}
