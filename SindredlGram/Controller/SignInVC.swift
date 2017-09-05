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
import SCLAlertView
import FacebookLogin

class SignInVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: FacyField!
    @IBOutlet weak var pwdField: FacyField!
    @IBOutlet weak var signInBtn: FancyBtn!
    
    var validUsername = false
    
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
            print("\(KEY_UID)")
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
                    let userData = ["provider": credential.provider]
                    self.completeSignIn(id: user.uid, userData: userData)
                }
                
            }
        })
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if emailField.text == "", pwdField.text == "" {
            emailField.layer.borderColor = UIColor.red.cgColor
            pwdField.layer.borderColor = UIColor.red.cgColor
            return
        } else {
            emailField.layer.borderColor = nil
            pwdField.layer.borderColor = nil
        }
        
        if let email = emailField.text, let password = pwdField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    //Signed in - Eksisterende bruker
                    print("SINDRE: E-POST bruker autentisert med Firebase!")
                    
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        self.completeSignIn(id: user.uid, userData: userData)
                    }
                    
                } else {
                    // Eksisterer ikke - Ny bruker opprettes
                    var newUsername: String!
                    // Get username from (new) user
                    let alert = SCLAlertView()
                    let txt = alert.addTextField("Skriv inn et brukernavn")
                    alert.addButton("Gå videre") {
                        // Dette blir ikke kjørt før gå videre kanppen i popupen er trykket
                        print("SINDRE: Oppgitt brukernavn: \(String(describing: txt.text))")
                        
                        if let usrName = txt.text {
                            
                            if usrName == "" {
                                //Tomt!
                                // Det er ikke noer her
                                self.validUsername = false
                                
                                print("SINDRE: Ugyldig brukernavn!")
                                let usernameErrorAlert = SCLAlertView()
                                usernameErrorAlert.showError("Ugyldig brukernavn", subTitle: "Vennligst oppgi et brukernavn")
                                
                                
                                
                            } else {
                                // Ikke tomt!
                                //Det er tekst her
                                self.validUsername = true
                                print("SINDRE: Brukernavn: \(usrName)")
                                newUsername = usrName
                                
                                
                                
                                Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                                    if error != nil {
                                        print("SINDRE: E-POST bruker kunne ikke autentiseres med Firebase")
                                    } else {
                                        print("SINDRE: NY BRUKER BLIR LAGET!")
                                        print("SINDRE: E-POST bruker Vellykket autentisert med Firebase!")
                                        
                                        if let userName = newUsername {
                                            if let user = user {
                                                let userData = ["provider": user.providerID, "username": userName]
                                                self.completeSignIn(id: user.uid, userData: userData)
                                            }
                                        } else {
                                            if let user = user {
                                                let userData = ["provider": user.providerID, "username": "UnknownUsername"]
                                                self.completeSignIn(id: user.uid, userData: userData)
                                            }
                                        }
                                        
                                    }
                                })
                                
                            }
                            
                            
                        } else {
                            //Noe annet rart txt.text finnes ikke... Skal ikke skje
                        }
                        
                    }
                    // Dette kjøres før man kan klikke på gå videre som så kjører complete signin med username
                    alert.showSuccess("Velkommen!", subTitle: "Vennligst oppgi et brukernavn. Dette vil bli ditt visningsnavn.", closeButtonTitle: "Avbryt")
                    
                    
                }
            })
        } else {
            // Ikke noe bruker og eller passord?
            print("SINDRE: Ikke noe bruker og eller passord??")
        }
    }
    
    func completeSignIn(id: String, userData: Dictionary<String, String>) {
        
        DataService.ds.createFirebaseDBUser(uid: id, userData: userData)
        
        let keychainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("SINDRE: Credentials ble lagret i keychain \(keychainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
    
    @IBAction func forgottenPwdTapped(_ sender: Any) {
        let alert = SCLAlertView()
        let txt = alert.addTextField("E-post addresse")
        alert.addButton("Tilbakestill passord") {
            if let email = txt.text {
                Auth.auth().sendPasswordReset(withEmail: "\(email)") { error in
                    // Your code here
                    if error == nil {
                        // En epost ble sendt
                        let alertController = UIAlertController(title: "Passord resatt", message: "En tilbakestillings epost har blitt sendt!", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                            alertController.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {
                        }
                        
                    } else {
                        // FEIL
                        let alertController = UIAlertController(title: "En feil oppstod", message: "Oppga du en gyldig epost addresse?", preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { action in
                            alertController.dismiss(animated: true, completion: nil)
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true) {
                        }
                    }
                }
            }
            
            
            
        }
        alert.showEdit("Glemt passord?", subTitle: "Oppgi din e-post addresse under.", closeButtonTitle: "Avbryt")
    }
    
}






