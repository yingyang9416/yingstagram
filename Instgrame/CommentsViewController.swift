//
//  CommentsViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/8/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage
import SVProgressHUD

protocol postIdProtocol{
    func getpostId(postId: String)
}

class CommentsViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var editorView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var textField: UITextField!
    
    
    var postId: String?
    var commentList = [Comment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbView.tableFooterView = UIView(frame: .zero)
        fetchAndReload()
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        //moveView(view: editorView, moveDistance: -250)
        moveUpEditor()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        moveDownEditor()
        return true
    }
    
    @IBAction func backBtnClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnClicked(_ sender: Any) {
        FIRDatabase.sharedInstance.addComment(postID: self.postId!, content: textField.text!) {
            textField.text = ""
            self.fetchAndReload()
        }
    }
    
    func moveUpEditor(){
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 290
            self.view.layoutIfNeeded()
        }
    }
    
    func moveDownEditor(){
        UIView.animate(withDuration: 0.3) {
            self.bottomConstraint.constant = 20
            self.view.layoutIfNeeded()
        }
    }


    
    func fetchAndReload(){
        SVProgressHUD.show()
        FIRDatabase.sharedInstance.fetchPostCommentList(postID: postId!) { (commentList, err) in
            SVProgressHUD.dismiss()
            if err == nil {
                self.commentList = commentList!
                DispatchQueue.main.async {
                    self.tbView.reloadData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension CommentsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
        let comment = commentList[indexPath.row]
        cell.imgView.sd_setImage(with: comment.userImageUrl, placeholderImage: UIImage(named: "iconuser"), options: SDWebImageOptions(rawValue: 0), completed: nil)
        cell.contentLb.text = comment.content
        cell.timeLb.text = comment.timestamp.readableTime
        cell.usernameBtn.setTitle(comment.username, for: .normal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
}
