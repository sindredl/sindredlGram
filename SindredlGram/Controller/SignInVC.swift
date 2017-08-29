//
//  ViewController.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 27.08.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FacyField!
    @IBOutlet weak var pwdField: FacyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func facebookLoginBtnPress(_ sender: Any) {
//        let loginManager = FBSDKLoginManager()
//        loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
//            switch loginResult {
//            case .failed(let error):
//                print(error)
//            case .cancelled:
//                print("User cancelled login.")
//            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
//                print("Logged in!")
//                let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.authenticationToken)
//                self.firebaseAuth(credential)
//
//            }
//        }
//    }
    
    @IBAction func FacebookBtnPressed(_ sender: AnyObject) {
        
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("SINDRE: Kunne ikke auntetisere med facebook - \(error)")
            } else if result?.isCancelled == true {
                print("SINDRE: Bruker kansellerte facebook autentisering")
            } else {
                print("SINDRE: Auntentisering med Facebook vellykket!")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                
                self.firebaseAuth(credential)
            }
        }
        
        //        Jess sin kode:
//
//        let facebookLogin = FBSDKLoginManager()
//
//        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
//            if error != nil {
//                print("JESS: Unable to authenticate with Facebook - \(error)")
//            } else if result?.isCancelled == true {
//                print("JESS: User cancelled Facebook authentication")
//            } else {
//                print("JESS: Successfully authenticated with Facebook")
//                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//                self.firebaseAuth(credential)
//            }
//        }
        
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("SINDRE: Kunne ikke autentisewre med Firebase - \(error)")
            } else {
                print("SINDRE: Vellykket autentisert med Firebase!")
            }
        })
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let password = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    //Signed in
                    print("SINDRE: E-POST bruker autentisert med Firebase!")
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("SINDRE: E-POST bruker kunne ikke autentiseres med Firebase")
                        } else {
                            print("SINDRE: E-POST bruker Vellykket autentisert med Firebase!")
                        }
                    })
                }
            })
        }
    }
    

}






