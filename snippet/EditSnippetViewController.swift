//
//  snippetEditViewController.swift
//  snippet
//
//  Created by Elliot Young on 9/28/16.
//  Copyright © 2016 Elliot Young. All rights reserved.
//

import UIKit

class EditSnippetViewController: UIViewController, UITextViewDelegate{
    @IBOutlet weak var textViewText: UITextView!
    @IBOutlet weak var copiedToClipBoardView: UIView!
    @IBOutlet weak var titleTextField: UITextField!
    weak var editSnippetDelegate: EditSnippetDelegate?
    weak var cancelButtonDelegate: CancelButtonDelegate?
    var recievedSnippetTextToEdit:String?
    var recievedSnippetTitleToEdit:String?
    var prevCount = 0
    var tabs = [Int]()
    weak var snippetToEdit:Snippets?
    override func viewDidLoad() {
        super.viewDidLoad()
        KOKeyboardRow.apply(to: textViewText)
        textViewText.autocorrectionType = .no
        textViewText.autocapitalizationType = .none
        textViewText.becomeFirstResponder()
        textViewText.delegate = self
        copiedToClipBoardView.alpha = 0
        if recievedSnippetTextToEdit != nil{
            textViewText.text = recievedSnippetTextToEdit
            titleTextField.text = recievedSnippetTitleToEdit
        }
        super.viewDidLayoutSubviews()
        self.automaticallyAdjustsScrollViewInsets = false
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //
    //UI ACTIONS
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        if textViewText.text != ""{
            if recievedSnippetTextToEdit != nil{
                //Edits existing snippet
                editSnippetDelegate?.editSnippetDelegate(textViewText.text, editedSnippetTitle:titleTextField.text!, snippetToEdit: snippetToEdit!)
                print("Edited Snippet")
            }
            else{
                //Adds new snippet to core data if an existing note was not passed.
                editSnippetDelegate?.editSnippetDelegate(textViewText.text, newSnippetTitle: titleTextField.text!)
                print("Created Snippet")
                
            }
        }
        cancelButtonDelegate!.cancelButtonPressedFrom(self)
    }
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        cancelButtonDelegate!.cancelButtonPressedFrom(self)

    }
    @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
        animateCopiedToClipBoardView()
        pasteBoard.string = textViewText.text
    }
    //UI ACTIONS
    //
    //
    //ANIMATE FUNCTIONS
    func animateCopiedToClipBoardView(){
        copiedToClipBoardView.alpha = 1
        UIView.animate(withDuration: 1,
                                   delay: 0.5,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 10.0,
                                   options: [],
                                   animations: ({
                                    self.copiedToClipBoardView.alpha = 0
                                   }), completion: nil)
    }
    //ANIMATE FUNCTIONS
    //
    //
    //PHIL'S FUNCTIONS TO AUTO CLOSE BRACKETS
    //
    func textViewDidChange(_ textView: UITextView) {
        let newCount = textView.text.characters.count
        if newCount < prevCount {
            prevCount = newCount
            return
        }
            
        let lastChar = lastNChars(1, textView: textView) as String!
        
        var needToUpdateCursor = true
        
        switch lastChar {
        case ?"{":
            textViewText.insertText("}")
        case ?"(":
            textViewText.insertText(")")
        case ?"[":
            textViewText.insertText("]")
            //        case "\n":
            //            needToUpdateCursor = false
            //            let last2Char = lastNChars(2, textView: textView) as String!
            //            tabs.insert(tabs[getCursorLine(textViewText) - 2], atIndex: getCursorLine(textViewText) - 1)
            //            switch last2Char {
            //            case "{\n", "(\n", "[\n":
            //                tabs[getCursorLine(textViewText) - 1] += 1
            //                for _ in 0..<tabs[getCursorLine(textViewText) - 1] {
            //                    textViewText.insertText("\t")
            //                }
            //
            //                textViewText.insertText("\n")
            //                for _ in 0..<tabs[getCursorLine(textViewText) - 2] - 1 {
            //                    textViewText.insertText("\t")
            //                }
            //                updateCursor(tabs[getCursorLine(textViewText) - 1])
            //                print("Moving back", tabs[getCursorLine(textViewText) - 1])
            //            default:
            //                break
            //            }
            //        case "\n":
            //            needToUpdateCursor = false
            //            updateTabs(textViewText)
            //            let i = tabs[getCursorLine(textViewText) - 2]
            //            var indents = ""
            //
            //            let last2Char = lastNChars(2, textView: textView) as String!
            //            switch last2Char {
            //            case "{\n", "(\n", "[\n":
            //                for _ in 0...i {
            //                    indents += "\t"
            //                }
            //                indents += "\n"
            //                for _ in 0..<i {
            //                    indents += "\t"
            //                }
            //                textViewText.insertText(indents)
            //                updateCursor(i + 1)
            //            default:
            //                for _ in 0..<i {
            //                    print("increasing indents")
            //                    indents += "\t"
            //                }
            //                if indents.characters.count > 0 {
            //                    textViewText.insertText(indents)
            //                }
        //            }
        default:
            needToUpdateCursor = false
        }
        
        if needToUpdateCursor {
            updateCursor(1)
        }
        
        prevCount = textView.text.characters.count
    }
    
    func getCursorLine(_ textView: UITextView) -> Int {
        let selectedRange = textView.selectedTextRange!
        let startPosition: UITextPosition = textView.beginningOfDocument
        let cursorPosition = textView.offset(from: startPosition, to: selectedRange.start)
        let chars = textView.text as String
        let startOfIndex = chars.characters.index(chars.startIndex, offsetBy: 0)
        let endOfIndex = chars.characters.index(chars.startIndex, offsetBy: cursorPosition)
        let lastChars = chars.substring(with: startOfIndex ..< endOfIndex)
        
        let tok = lastChars.components(separatedBy: "\n")
        
        return tok.count
    }
    
    func updateTabs(_ textView:UITextView) {
        let lines = textView.text.components(separatedBy: "\n")
        
        var temp = [Int]()
        for line in lines {
            temp.append(line.components(separatedBy: "\t").count - 1)
        }
        tabs = temp
    }
    
    
    func lastNChars(_ n: Int, textView: UITextView) -> String? {
        if let selectedRange = textView.selectedTextRange {
            let startPosition: UITextPosition = textView.beginningOfDocument
            let cursorPosition = textView.offset(from: startPosition, to: selectedRange.start)
            let chars = textView.text as String
            var lastNChars: Int!
            if n > cursorPosition {
                lastNChars = cursorPosition
            } else {
                lastNChars = n
            }
            let startOfIndex = chars.characters.index(chars.startIndex, offsetBy: cursorPosition - lastNChars)
            let endOfIndex = chars.characters.index(chars.startIndex, offsetBy: cursorPosition)
            let lastChars = chars.substring(with: startOfIndex ..< endOfIndex)
            return lastChars
        }
        return nil
    }
    
    func updateCursor(_ offset: Int) {
        if let selectedRange = textViewText.selectedTextRange {
            if let newPosition = textViewText.position(from: selectedRange.start, in: UITextLayoutDirection.left, offset: offset) {
                textViewText.selectedTextRange = textViewText.textRange(from: newPosition, to: newPosition)
            }
        }
    }
    //PHIL'S FUNCTIONS TO AUTO CLOSE BRACKETS
    //
}
