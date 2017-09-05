//
//  SettingsVC.swift
//  SindredlGram
//
//  Created by Sindre Dahl Løken on 04.09.2017.
//  Copyright © 2017 Sindre Dahl Løken. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase
import SCLAlertView

class SettingsVC: UITableViewController {
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        self.tableView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SINDRE: Rad klikket: \(indexPath)")
        
        if indexPath == [2, 0] {
            // Sign out
            let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            print("SINDRE: ID Fjenret fra keychain \(keychainResult)")
            try! Auth.auth().signOut()
            performSegue(withIdentifier: "goToSignInFromSettings", sender: nil)
        } else if indexPath == [1, 0] {
            // Change username
            changeUsername()
        }
        
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func changeUsername() {
        // Username checking
        var currentUser: DatabaseReference!
        currentUser = DataService.ds.REF_USER_CURRENT
        //print("SINDRE: Tingen  vi får hentet brukernavn fra: \(currentUser)")
        currentUser.observeSingleEvent(of: .value, with: {(snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                
                if let usrName = dictionary["username"] as? String {
                    //Brukernavn finnes på konto
                    print("SINDRE: Current Brukernavn: \(usrName)")
                    
                    if let userID = Auth.auth().currentUser?.uid {
                        
                        // GET USERNAME FROM USER:
                        
                        let alert = SCLAlertView()
                        let txt = alert.addTextField("Skriv inn et brukernavn")
                        
                        alert.addButton("Gå videre") {
                            // Dette blir ikke kjørt før gå videre kanppen i popupen er trykket
                            print("SINDRE: Oppgitt brukernavn: \(String(describing: txt.text))")
                            
                            if let usrName = txt.text {
                                
                                if usrName == "" {
                                    //Tomt
                                    // Det er ikke noer her
                                    print("SINDRE: Ugyldig brukernavn!")
                                    let usernameErrorAlert = SCLAlertView()
                                    usernameErrorAlert.showError("Ugyldig brukernavn", subTitle: "Vennligst oppgi et brukernavn")
                                    
                                } else {
                                    // Ikke tomt!
                                    //Det er tekst her
                                    print("SINDRE: Brukernavn: \(usrName)")
                                    
                                    // SAVE USERNAME TO DB:
                                    DataService.ds.REF_USERS.child(userID).updateChildValues(["username": usrName])
                                    
                                }
                                
                                
                            } else {
                                //Noe annet rart txt.text finnes ikke... Skal ikke skje
                            }
                            
                        }
                        // Dette kjøres før man kan klikke på gå videre som så kjører complete signin med username
                        alert.showEdit("Endre brukernavn", subTitle: "Vennligst oppgi et nytt brukernavn. Nåværende brukernavn er: \(usrName)", closeButtonTitle: "Avbryt")
                        
                        
                        
                        
                    }
                    
                    
                    
                    
                } else {
                    // Ikke noe brukernavn eksisterer...
                    
                    
                }
                
            }
        })
    }

    
    
    

}
