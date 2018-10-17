//
//  AddPostViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/3/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SVProgressHUD
import TWMessageBarManager

class AddPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        hideKeyboardWhenTappedAround()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func addPhotoClicked(_ sender: Any) {
        if imagePicker.sourceType == .camera {
            imagePicker.sourceType = .camera
        } else {
            imagePicker.sourceType = .photoLibrary
        }
        present(imagePicker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]){
        if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imgView.image = img
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }

    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        imagePicker.dismiss(animated: true, completion: nil)
    }

    @IBAction func shareClicked(_ sender: Any) {
        if imgView.image == nil {
            TWMessageBarManager.sharedInstance().showMessage(withTitle: "ERROR", description: "Please upload an image", type: .error, duration: 3.0)
        } else {
            SVProgressHUD.show()
            FIRDatabase.sharedInstance.post(image: imgView.image!, postText: postTextView.text) {
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AddPostViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
