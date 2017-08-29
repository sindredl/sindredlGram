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
import SwiftKeychainWrapper

class SignInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: FacyField!
    @IBOutlet weak var pwdField: FacyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Fjerne keyboard
        self.emailField.delegate = self
        self.pwdField.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            print("SINDRE: ID Funnet i keychain!")
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    }
    
    // Remove keyboard when pressing return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
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
        
        
    }
    
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("SINDRE: Kunne ikke autentisere med Firebase - \(String(describing: error))")
            } else {
                print("SINDRE: Vellykket autentisert med Firebase!")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
                
            }
        })
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let password = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    //Signed in
                    print("SINDRE: E-POST bruker autentisert med Firebase!")
                    
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                    
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("SINDRE: E-POST bruker kunne ikke autentiseres med Firebase")
                        } else {
                            print("SINDRE: E-POST bruker Vellykket autentisert med Firebase!")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                            }
                            
                        }
                    })
                }
            })
        }
    }
    
    func completeSignIn(id: String) {
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("SINDRE: Credentials ble lagret i keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}






