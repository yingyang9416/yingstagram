//
//  PwdResetViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/2/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import FirebaseAuth
import TWMessageBarManager

class PwdResetViewController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func sendLinkClicked(_ sender: Any) {
        FIRAuth.sharedInstance.sendPwdResetLink(email: emailField.text!)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
