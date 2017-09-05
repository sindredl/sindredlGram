//
//  Post.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 30.08.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

import Foundation
import Firebase

class Post {
    
    //Random comment: _ er common notation for private vars
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _postId: String!
    private var _postRef: DatabaseReference!
    private var _postedBy: String!
    
    var caption: String {
        return _caption
    }
    var imageUrl: String {
        return _imageUrl
    }
    var likes: Int {
        return _likes
    }
    var postId: String {
        return _postId
    }
    
    var postedBy: String {
        return _postedBy
    }
    
    init(caption: String, imageUrl: String, likes: Int) {
        self._caption = caption
        self._imageUrl = imageUrl
        self._likes = likes
        self._postedBy = postedBy
    }
    
    init(postID: String, postData: Dictionary<String, AnyObject>) {
        self._postId = postID
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        if let postedBy = postData["postedBy"] as? String {
            self._postedBy = postedBy
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postId)
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = likes - 1
        }
        
        _postRef.child("likes").setValue(_likes)
    }
    
    
    
    
    
}
