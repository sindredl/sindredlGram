//
//  PostCell.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 29.08.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

import UIKit
import Firebase
import Gifu

class PostCell: UITableViewCell, GIFAnimatable {
    public lazy var animator: Animator? = {
        return Animator(withDelegate: self)
    }()
    
    override public func display(_ layer: CALayer) {
        updateImageIfNeeded()
    }
    
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var postImg: UIImageView!
    @IBOutlet weak var caption: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    @IBOutlet weak var likeImg: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    var post: Post!
    var likesRef: DatabaseReference!
    var usernameRef: DatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(likeTapped))
        tap.numberOfTapsRequired = 1
        likeImg.addGestureRecognizer(tap)
        likeImg.isUserInteractionEnabled = true
        
        
//        let animatedImageView = GIFImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
//        animatedImageView.animate(withGIFNamed: "mugen")
//        postImg animat
//
        
    }
    
    
    
    
    func configureCell(post: Post, img: UIImage? = nil) {
        self.post = post
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postId)
        //usernameRef = DataService.ds.REF_USER_CURRENT.child("username")
        usernameRef = DataService.ds.REF_USERS.child(post.postedBy)
        usernameRef.observeSingleEvent(of: .value, with: {(snapshot) in
            
            if let dict = snapshot.value as? [String: AnyObject] {
               if let usrName = dict["username"] as? String {
                self.usernameLbl.text = usrName
               } else {
                self.usernameLbl.text = "UknownUsername"
                }
            }
        })
        
        
        self.caption.text = post.caption
        self.likesLbl.text = "\(post.likes)"
        //self.usernameLbl.text = "\(postedByUsername)"
        
        if img != nil {
            //Image is in cache
            self.postImg.image = img
            self.blurView.isHidden = true
        } else {
            //Image not in cahce - download it
            let ref = Storage.storage().reference(forURL: post.imageUrl)
            ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("SINDRE: Kunne ikke laste ned bilde fra Firebase Storage...")
                } else {
                    //print("SINDRE: Bilde lastet ned fra Firebase storage vellykket!")
                    self.blurView.isHidden = true
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
                
            })
        }
        
        
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            // Check if post is liked or not
            if let _ = snapshot.value as? NSNull {
                self.likeImg.image = UIImage(named: "empty-heart")
            } else {
                self.likeImg.image = UIImage(named: "filled-heart")
            }
            
        })
        
    }
    
    func likeTapped(sender: UITapGestureRecognizer) {
        likesRef.observeSingleEvent(of: .value, with: {(snapshot) in
            // Like an image - if it is liked - unlike it
            
            if let _ = snapshot.value as? NSNull {
                
                self.likeImg.image = UIImage(named: "filled-heart")
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
                
            } else {
                
                self.likeImg.image = UIImage(named: "empty-heart")
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
            
        })
    }
    
    
    
}






