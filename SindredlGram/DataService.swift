//
//  DataService.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 30.08.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

// Reference to our database (Firrbase)

import Foundation
import Firebase

let DB_BASE = Database.database().reference()
class DataService {
    
    //Singleton - Instanse av en klasse som er globalt tilgjengelig - kun en instance
    static let ds = DataService()
    
    private var _REF_BASE = DB_BASE
    private var _REF_POSTS = DB_BASE.child("posts")
    private var _REF_USERS = DB_BASE.child("users")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    func createFirebaseDBUser(uid: String, userData: Dictionary<String, String>) {
        REF_USERS.child(uid).updateChildValues(userData)
    }
    
}










