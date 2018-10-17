//
//  LoginViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/1/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import FirebaseAuth
import TWMessageBarManager
import GoogleSignIn
import FirebaseMessaging
import SVProgressHUD
import FBSDKCoreKit
import FBSDKLoginKit
import FacebookCore
import FacebookLogin


class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate{
    

    

    @IBOutlet weak var logoView: UIImageView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logoView.image = UIImage(named: "insLogo")
        loginBtn.layer.cornerRadius = 5
        navigationController?.isNavigationBarHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginClicked(_ sender: Any) {
        SVProgressHUD.show()
        FIRAuth.sharedInstance.loginUser(email: emailField.text!, password: pwdField.text!) { (currUser, errorMessage) in
            SVProgressHUD.dismiss()
            if currUser != nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showTabBar", sender: nil)
                }
            }
        }
    }
    
    @IBAction func googleLoginClicked(_ sender: Any) {
        SVProgressHUD.show()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func fbloginClicked(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(readPermissions: [.publicProfile, .email], viewController: self) { (result) in
            switch result {
            case .success(grantedPermissions: _, declinedPermissions: _, token: _):
                self.signinFB()
                print("siginin FB")
            case .failed:
                print("FB Failed")
            case .cancelled:
                print("cancelled")
            default: break
            }
        }
    }
    
    
    func signinFB(){
        FIRAuth.sharedInstance.signupWithFB { (currUser, err) in
            if err == nil {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "showTabBar", sender: nil)
                }
            }
        }
        
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        SVProgressHUD.dismiss()
        if error == nil {
            FIRAuth.sharedInstance.signupWithGoogle(user: user) { (currUser, err) in
                if err == nil {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "showTabBar", sender: nil)
                    }
                }
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("receieved on VC level")
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
