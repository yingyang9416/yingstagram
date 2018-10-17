//
//  FIRAuth.swift
//  Instgrame
//
//  Created by Steven Yang on 8/2/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import TWMessageBarManager
import FirebaseMessaging
import GoogleSignIn
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit




class FIRAuth: NSObject{
    static let sharedInstance = FIRAuth()
    private override init(){}
    
    //private lazy var currentUser = CurrentUser.sharedInstance

    typealias SigninHandler = (CurrentUser?, String?) -> ()
    typealias SignupHandler = (CurrentUser?, String?) -> ()
    
    
    func checkEmailNotUsed(email: String, completion: @escaping ()->()){
        Auth.auth().fetchProviders(forEmail: email) { (providerArr, error) in
            if let err = error {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: err.localizedDescription, type: .error, duration: 5.0)
            }else{
                if providerArr == nil {
                    completion()
                } else {
                    TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: "This email has already used by another account", type: .error, duration: 5.0)
                }
            }
        }
    }
    
    func loginUser(email: String, password: String, completion: @escaping SigninHandler){
        Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
            if error == nil {
                FIRDatabase.sharedInstance.fetchCurrentUserData(completion: { (currUser, errMessage) in
                    CurrentUser.sharedInstance = currUser
                    // CurrentUser.sharedInstance = currUser
                    //self.currentUser = currUser
                    completion(currUser, nil)
                })
            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: error?.localizedDescription, type: .error, duration: 5.0)
                completion(nil, error?.localizedDescription)
            }
        }
        
    }
    
    func signupUser(email: String, password: String, userDictionary: [String: Any], completion: @escaping SignupHandler){
        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
            if let err = error {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: err.localizedDescription, type: .error, duration: 5.0)
                completion(nil, err.localizedDescription)
            } else {
                let id = authResult?.user.uid
                let dict = userDictionary
                
                FIRDatabase.sharedInstance.updateUser(uid: id!, userDictionary: dict, completion: {
                    FIRDatabase.sharedInstance.addPublicUser(uid: id!)
                    FIRDatabase.sharedInstance.fetchCurrentUserData(completion: { (currUser, errMessage) in
                        CurrentUser.sharedInstance = currUser
                        //self.currentUser = currUser
                        completion(currUser, nil)
                    })
                })
            }
        }
    }
    
    
    func signupWithGoogle(user: GIDGoogleUser, completion: @escaping SignupHandler){
        guard let authentication = user.authentication else{ return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (authRedsult, err) in
            if err == nil {
                let googleUser = authRedsult?.user
                FIRDatabase.sharedInstance.checkUserIdExists(userId: (googleUser?.uid)!, completion: { (res) -> (Void) in
                    if res {
                        FIRDatabase.sharedInstance.fetchCurrentUserData(completion: { (currUser, err) in
                            CurrentUser.sharedInstance = currUser
                            completion(currUser, nil)
                        })
                    } else {
                        let urlStr = (googleUser?.photoURL == nil) ? "" : "\((googleUser?.photoURL)!)"
                        let dict = ["Email": googleUser?.email, "Full Name": googleUser?.displayName ?? "", "Username":googleUser?.email, "Profile Image Url": urlStr]
                        FIRDatabase.sharedInstance.updateUser(uid: (googleUser?.uid)!, userDictionary: dict, completion: {
                            
                            FIRDatabase.sharedInstance.fetchCurrentUserData(completion: { (currUser, err) in
                                CurrentUser.sharedInstance = currUser
                                Messaging.messaging().subscribe(toTopic: currUser.userId)
                                completion(currUser, nil)

                            })
                        })
                    }
                })
                
            }
        }
    }
    
    func signupWithFB(completion: @escaping SignupHandler){
        let credential = FacebookAuthProvider.credential(withAccessToken: (AccessToken.current?.authenticationToken)!)
        Auth.auth().signInAndRetrieveData(with: credential) { (authRes, err) in
            if err == nil {
                FIRDatabase.sharedInstance.checkUserIdExists(userId: (authRes?.user.uid)!, completion: { (exists) -> (Void) in
                    if exists {
                        FIRDatabase.sharedInstance.fetchCurrentUserData(completion: { (currUser, err) in
                            if err == nil {
                                CurrentUser.sharedInstance = currUser
                                completion(currUser, nil)
                            }
                        })
                    } else {
                        let email = authRes?.user.email ?? ""
                        let fullName = authRes?.user.displayName ?? ""
                        let userName = authRes?.user.displayName ?? ""
                        let urlStr = (authRes?.user.photoURL == nil) ? "" : "\((authRes?.user.photoURL)!)"
                        let dict = ["Email": email, "Full Name": fullName, "Username":userName, "Profile Image Url": urlStr]
                        FIRDatabase.sharedInstance.updateUser(uid: (authRes?.user.uid)!, userDictionary: dict, completion: {
                            FIRDatabase.sharedInstance.fetchCurrentUserData(completion: { (currUser, err) in
                                CurrentUser.sharedInstance = currUser
                                Messaging.messaging().subscribe(toTopic: currUser.userId)
                                completion(currUser, nil)
                            })
                        })

                    }
                })
                print("FB signin")
            }
        }

    }
    
    func sendPwdResetLink(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error != nil {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: error?.localizedDescription, type: .error, duration: 5.0)

            } else {
                TWMessageBarManager.sharedInstance().showMessage(withTitle: "Test", description: "Check your email", type: .success, duration: 5.0)
            }
        }
    }
    
    func signout(completion:()->()){
        do {
            try Auth.auth().signOut()
            //CurrentUser.sharedInstance = CurrentUser()
            AllPublicPosts.dispose()
            completion()
        }catch{
            
        }
    }
    
    
    
    
    
}
