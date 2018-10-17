//
//  ChatViewController.swift
//  Instgrame
//
//  Created by Steven Yang on 8/14/18.
//  Copyright © 2018 Ying Yang. All rights reserved.
//

import UIKit
import SDWebImage

class ChatViewController: ViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tbView: UITableView!
    @IBOutlet weak var textField: UITextField!
    var receiver: PublicUser?
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tbView.tableFooterView = UIView(frame: .zero)
        FIRDatabase.sharedInstance.fetchMessage(receiverId: (receiver?.userID)!) { (message, err) in
            if err == nil {
                self.messages.append(message!)
                DispatchQueue.main.async {
                    self.tbView.reloadData()
                }
            }
        }
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func sendClicked(_ sender: Any) {
        FIRDatabase.sharedInstance.sendMessage(receiverId: (receiver?.userID)!, content: textField.text!)
    }
    
    @IBAction func backClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return messages.count
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        if message.incoming {
            let cell = tableView.dequeueReusableCell(withIdentifier: "IncomingMessageCell") as! IncomingMessageCell
            cell.contentLb.text = message.text
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "OutgoingMessageCell") as! OutgoingMessageCell
            cell.textLb.text = message.text
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
