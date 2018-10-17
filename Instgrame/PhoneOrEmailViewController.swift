//
//  PhoneOrEmailViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/1/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import FirebaseAuth
import TWMessageBarManager

class PhoneOrEmailViewController: UIViewController {

    
    @IBOutlet weak var emailField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func nextClicked(_ sender: Any) {
        FIRAuth.sharedInstance.checkEmailNotUsed(email: emailField.text!) {
            
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            controller.email = self.emailField.text
            self.navigationController?.pushViewController(controller, animated: true)
            
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
