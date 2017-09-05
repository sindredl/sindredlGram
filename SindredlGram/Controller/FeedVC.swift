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
import SCLAlertView

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageAdd: CircleView!
    @IBOutlet weak var captionField: FacyField!
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var veivheyhey: UIView!
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    
    var printUser: String!
    var hasUsername = false
    var currentUser: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let retrievedString: String? = KeychainWrapper.standard.string(forKey: KEY_UID)
        print("SINDRE: Keychain string: \(retrievedString)")
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        //veivheyhey.addSubview(blurEffect)
        //view.addSubview(blurEffectView)
        
        
        //Listener initialization
        DataService.ds.REF_POSTS.observe(.value, with: {(snapshot) in
            //Will update the snapshot.value object whenever changes occur - in realtime
            self.posts = [] // This is where you add it to fix the problem
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
            self.posts.reverse()
            self.tableView.reloadData()
        })
        
        //Fjerne keyboard
        self.captionField.delegate = self
        
        // Username checking
        currentUser = DataService.ds.REF_USER_CURRENT
        //print("SINDRE: Tingen  vi får hentet brukernavn fra: \(currentUser)")
        currentUser.observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                
                if let usrName = dictionary["username"] as? String {
                    //Brukernavn finnes på konto
                    self.hasUsername = true
                    print("SINDRE: Brukernavn: \(usrName)")
                } else {
                    // Ikke noe brukernavn på konto
                    self.hasUsername = false
                    if let userID = Auth.auth().currentUser?.uid {
                        
                        // GET USERNAME FROM USER:
                        var newUsername: String!
                        var validUsername = false
                        
                        let alert = SCLAlertView()
                        let txt = alert.addTextField("Skriv inn et brukernavn")
                        
                        alert.addButton("Gå videre") {
                            // Dette blir ikke kjørt før gå videre kanppen i popupen er trykket
                            print("SINDRE: Oppgitt brukernavn: \(String(describing: txt.text))")
                            
                            if let usrName = txt.text {
                                
                                if usrName == "" {
                                    //Tomt
                                    // Det er ikke noer her
                                    validUsername = false
                                    
                                    print("SINDRE: Ugyldig brukernavn!")
                                    let usernameErrorAlert = SCLAlertView()
                                    usernameErrorAlert.showError("Ugyldig brukernavn", subTitle: "Vennligst oppgi et brukernavn")
                                    
                                } else {
                                    // Ikke tomt!
                                    //Det er tekst her
                                    validUsername = true
                                    print("SINDRE: Brukernavn: \(usrName)")
                                    newUsername = usrName
                                    
                                    // SAVE USERNAME TO DB:
                                    DataService.ds.REF_USERS.child(userID).updateChildValues(["username": usrName])
                                    
                                    
                                }
                                
                                
                            } else {
                                //Noe annet rart txt.text finnes ikke... Skal ikke skje
                            }
                            
                        }
                        // Dette kjøres før man kan klikke på gå videre som så kjører complete signin med username
                        alert.showSuccess("Velkommen!", subTitle: "Vennligst oppgi et brukernavn. Dette vil bli ditt visningsnavn.", closeButtonTitle: "Avbryt")
                        
                    }
                    
                    
                    
                }
                
            }
        })
        // /Tezt
        
        
    }
    
    // Remove keyboard when pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
                
            } else {
                cell.configureCell(post: post)
                
            }
            return cell
            
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
        var postedBy: String!
        if let userID = Auth.auth().currentUser?.uid {
            postedBy = userID
        } else {
            postedBy = "UnknownUsername"
        }
        
        let post: Dictionary<String, Any> = [
            "caption": captionField.text as Any,
            "imageUrl": imgUrl,
            "likes": 0,
            "postedBy": postedBy
        ]
        
        let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
        firebasePost.setValue(post)
        
        captionField.text = ""
        imageSelected = false
        imageAdd.image = UIImage(named: "add-image")
        
        self.posts.reverse()
        tableView.reloadData()
        
    }
    
    
    
    
    @IBAction func settingsTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToSettings", sender: nil)
    }
    
    
    @IBAction func signOutTapped(_ sender: Any) {
        print("SINDRE: Sing out TAPPED")
        
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("SINDRE: ID Fjenret fra keychain \(keychainResult)")
        
        try! Auth.auth().signOut()
        
        performSegue(withIdentifier: "goToSignIn", sender: nil)
    }
    

}
