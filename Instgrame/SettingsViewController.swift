//
//  SettingsViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/3/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func signoutClicked(_ sender: Any) {
        FIRAuth.sharedInstance.signout {
            let group = DispatchGroup()
            for postId in postsToUpdate {
                group.enter()
                FIRDatabase.sharedInstance.likeUnlikePost(postID: postId) {
                    group.leave()
                }
            }
            postsToUpdate.removeAll()
            group.notify(queue: .main, execute: {
                CurrentUser.sharedInstance.dispose()
                let mainStoryBoard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let controller = mainStoryBoard.instantiateViewController(withIdentifier: "NavController")
                UIApplication.shared.keyWindow?.rootViewController = controller
                self.navigationController?.popToRootViewController(animated: true)
                print("sign out!")
            })
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
