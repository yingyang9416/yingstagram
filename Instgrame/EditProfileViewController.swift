//
//  EditProfileViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/2/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var fullnameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var websiteField: UITextField!
    @IBOutlet weak var bioTextView: UITextView!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var genderField: UITextField!
    
    
    var cu: CurrentUser!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cu = CurrentUser.sharedInstance
    }
    
    override func viewWillAppear(_ animated: Bool) {
        cu = CurrentUser.sharedInstance
        imgView.sd_setImage(with: cu.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        fullnameField.text = cu.fullname
        usernameField.text = cu.username
        emailField.text = cu.email
        bioTextView.text = cu.bio
        websiteField.text = cu.website
        phoneField.text = cu.phoneNumber
        genderField.text = cu.gender
    }
    
    @IBAction func doneClicked(_ sender: Any) {
        let dict = ["Full Name": fullnameField.text, "Username": usernameField.text,"Website": websiteField.text, "Bio": bioTextView.text, "Email": emailField.text,"Phone Number": phoneField.text, "Gender": genderField.text]
        FIRDatabase.sharedInstance.updateUser(uid: cu.userId, userDictionary: dict) {
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func changePhotoClicked(_ sender: Any) {
        imagePicker.delegate = self
        if imagePicker.sourceType == .camera {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)
                
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            FIRDatabase.sharedInstance.uploadProfileImage(image: img) { (url, errMessage) in
                FIRDatabase.sharedInstance.updateUser(uid: self.cu.userId, userDictionary: ["Profile Image Url": "\(url!)"], completion: {
                    DispatchQueue.main.async {
                        self.imgView.sd_setImage(with: self.cu.profileImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
                    }
                })
            }
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        imagePicker.dismiss(animated: true, completion: nil)
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
