//
//  FeedVC.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 29.08.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FacyField!
    
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
        //Listener initialization
        DataService.ds.REF_POSTS.observe(.value, with: {(snapshot) in
            //Will update the snapshot.value object whenever changes occur - in realtime
            
            if let snapshots = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshots {
                    print("SNAP: \(snap)")
                    
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postID: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            
            self.tableView.reloadData()
        })
        
    }
    
    // Table View
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
                return cell
            } else {
                cell.configureCell(post: post)
                return cell
            }
            
        } else {
            return PostCell()
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageAdd.image = image
            imageSelected = true
        } else {
            print("SINDRE: Bildet som ble valgt er ikke gyldig!!!")
        }
        
        // Dismiss then image picker when an image is selected
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postBtnTapped(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
            print("SINDRE: Bildetekst må fylles ut!")
            return
        }
        guard let img = imageAdd.image, imageSelected == true else {
            print("SINDRE: Et bilde må være valgt!")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).putData(imgData, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    print("SINDRE: Kunne ikke laste opp bilde til firebase storage!!")
                } else {
                    print("SINDRE: Opplasting av bilde til firebase storage vellykket!")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    
                    
                    if let url = downloadURL {
                        print("SINDRE: Vi er rett før postToFirebase blir kalt")
                        self.postToFirebase(imgUrl: url)
                    }
                    
                }
            })
        }
    }
  /*
    func postToFirebase(imgUrl: String) {
        print("SINDRE: Vi er helt i toppen av postToFirebase")
        let post: Dictionary<String, Any> = [
            "caption": captionField.text! as String,
            "imageUrl": imgUrl as String,
            "likes": 0 as Int
        ]
        print("SINDRE: Vi er rett over childByAutoId")
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        print("SINDRE: Vi er rett over setValue på firebasePost")
        firebasePost.setValue(post)
        print("SINDRE: firebasePost ble kjørt! =)")
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
    }
     */
    
    func postToFirebase(imgUrl: String) {
        
        let post: Dictionary<String, Any> = [
            "caption": captionField.text as Any,
            "imageUrl": imgUrl,
            "likes": 0
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        tableView.reloadData()
        
    }
 
    
    @IBAction func signOutTapped(_ sender: Any) {
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("SINDRE: ID Fjenret fra keychain \(keychainResult)")
        
        try! Auth.auth().signOut()
        
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    

}
