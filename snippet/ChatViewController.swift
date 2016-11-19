//
//  ViewController.swift
//  chatchat
//
//  Created by Jennifer Zeller on 9/28/16.
//  Copyright © 2016 Alex. All rights reserved.
//

import UIKit
import SocketIO

class ChatViewController: UIViewController,UITextViewDelegate{
    
    @IBAction func updateButton(_ sender: UIButton) {
        self.socket.emit("username", withItems: [self.usernameField.text!.replacingOccurrences(of: "\n", with: "<br>")])
        self.usernameField.text = ""
    }
    @IBAction func pasteButton(_ sender: UIButton) {
        if let pastingText = pasteBoard.string{
            sendField.text = sendField.text + pastingText + "\n"

        }
    }
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var chatView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var sendField: UITextView!
    
    let socket = SocketIOClient(socketURL: URL(string: "http://192.168.1.150:8080")!, config: [.log(true), .forcePolling(true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KOKeyboardRow.apply(to: sendField)
        sendField.autocorrectionType = .no
        sendField.autocapitalizationType = .none
        sendField.becomeFirstResponder()
        sendField.delegate = self
        addHandlers()
        self.socket.connect()
        self.chatView.layoutManager.allowsNonContiguousLayout = false
        chatView.isEditable = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let bottom = chatView.contentSize.height
        
        chatView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true) // Scrolls to end
        
    }
    
    @IBAction func sendButton(_ sender: UIButton) {
        self.socket.emit("chat message", withItems: [self.sendField.text!.replacingOccurrences(of: "\n", with: "<br>").replacingOccurrences(of: "\t", with: "  ")])
        self.sendField.text = ""
    }
    
    func addHandlers() {
        self.socket.on("connect") {data, ack in
            // self?.chatView.text?.appendContentsOf(replaced + "\n")
        }
        
        self.socket.on("chat message") {[weak self] data, ack in
            if let value = data.first as? String {
                let replaced = (value as NSString).replacingOccurrences(of: "<br>", with: "\n")
                self?.chatView.text?.append(replaced + "\n\n")
                let stringLength:Int = self!.chatView.text.characters.count
                self!.chatView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
            }
        }
        
        self.socket.on("total users") {[weak self] data, ack in
            if let value = data.first as? String {
                let replaced = (value as NSString).replacingOccurrences(of: "<br>", with: "\n")
                self?.chatView.text?.append(replaced + "\n\n")
                let stringLength:Int = self!.chatView.text.characters.count
                self!.chatView.scrollRangeToVisible(NSMakeRange(stringLength-1, 0))
            }
        }
    }
}

