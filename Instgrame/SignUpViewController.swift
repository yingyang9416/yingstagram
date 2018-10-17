//
//  SignUpViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/1/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import FirebaseAuth
import TWMessageBarManager
import FirebaseMessaging


class SignUpViewController: UIViewController {

    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        if var fullname = fullnameField.text, let password = pwdField.text {
            let dict = ["Full Name": fullname, "Email": email!, "Username": email!]
            FIRAuth.sharedInstance.signupUser(email: email!, password: pwdField.text!, userDictionary: dict) { (currUser, errorMessage) in
                if currUser != nil {
                    CurrentUser.sharedInstance = currUser!
                    Messaging.messaging().subscribe(toTopic: (currUser?.userId)!)
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showTabBarBySignUp", sender: nil)
                        print(currUser?.userId)

                    }
                }
            }
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
