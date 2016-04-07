//
//  DataApi.swift
//  FunEye1.2
//
//  Created by Lê Thanh Tùng on 3/25/16.
//  Copyright © 2016 Lê Thanh Tùng. All rights reserved.
//

import Foundation

let ACCESS_TOKEN_KEY = "ACCESS_TOKEN"
let USER_ID_KEY = "USER_ID"

var ACCESS_TOKEN :String!
var USER_ID :String!


let URL_MAIN_DOMAIN = "http://funeye.net:8000"

let URL_LOGIN_FACEBOOK = URL_MAIN_DOMAIN + "/oauth/fbmobile"
let URL_GET_NEW_FEED = URL_MAIN_DOMAIN + "/api/feed?page=1&access_token=\(ACCESS_TOKEN)"
let URL_GET_FRIEND_FOLLOW = URL_MAIN_DOMAIN + "/api/suggestfriends?access_token=\(ACCESS_TOKEN)"
let URL_GET_CATEGORIES = URL_MAIN_DOMAIN + "/api/categoryInfo?access_token=\(ACCESS_TOKEN)"
let URL_AVATAR_NIL = URL_MAIN_DOMAIN + "/img/logo-white.png"

func URL_GET_CATEGORY_POST(id: String) -> String {
    return URL_MAIN_DOMAIN + "/api/categories/"+id+"?page=1&sort=creared&access_token=\(ACCESS_TOKEN)"
}

func URL_GET_COMMENT_POST(post_id: String) -> String{
    return URL_MAIN_DOMAIN + "/api/articles/\(post_id)/comments?access_token=\(ACCESS_TOKEN)"
}

func URL_PUT_VIEW_POST(post_id: String) -> String {
    return URL_MAIN_DOMAIN + "/api/articles/\(post_id)/view?access_token=\(ACCESS_TOKEN)"
}

func URL_PUT_LIKE_POST(post_id: String, isLike: Bool) -> String {
    if isLike {
        return URL_MAIN_DOMAIN + "/api/articles/\(post_id)/like?access_token=\(ACCESS_TOKEN)"
    } else {
        return URL_MAIN_DOMAIN + "/api/articles/\(post_id)/unlike?access_token=\(ACCESS_TOKEN)"
    }
}

func URL_PUT_FOLLOW_FRIEND(friend_id: String, isFollow: Bool) -> String {
    if isFollow {
        return URL_MAIN_DOMAIN + "/api/follow/\(friend_id)?access_token=\(ACCESS_TOKEN)"
    } else {
        return URL_MAIN_DOMAIN + "/api/unfollow/\(friend_id)?access_token=\(ACCESS_TOKEN)"
    }
}

func URL_PUT_FOLLOW_TOPIC(topic: String, isFollow: Bool) -> String {
    if isFollow {
        return URL_MAIN_DOMAIN + "/api/followCategories/\(topic)?access_token=\(ACCESS_TOKEN)"
    } else {
        return URL_MAIN_DOMAIN + "/api/unfollowCategories/\(topic)?access_token=\(ACCESS_TOKEN)"
    }
}