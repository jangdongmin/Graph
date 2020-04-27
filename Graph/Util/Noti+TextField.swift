//
//  Noti+TextField.swift
//  Graph
//
//  Created by Paul Jang on 2020/04/07.
//  Copyright © 2020 jdm. All rights reserved.
//

import Foundation
import UIKit

class CustomTextField: UITextField {
    static var CustomTextFieldIdentifier = "GetTextFieldValue"
    static var BeginEditingTextFieldIdentifier = "beginEditingTextField"
    static var toolbarHeight: CGFloat = 50
    
    public var identifier: String = ""
    public var index: Int = 0
//    public var customRect: CGRect!
    
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
      
        self.delegate = self
        addDoneButtonOnKeyboard()
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CustomTextField.toolbarHeight))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction(){
        self.resignFirstResponder()
    }
}

extension CustomTextField: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomTextField.BeginEditingTextFieldIdentifier), object: self)
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        NotificationCenter.default.post(name: Notification.Name(rawValue: CustomTextField.CustomTextFieldIdentifier), object: self)
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isFirstResponder {
            textField.resignFirstResponder()
        }
        return true
    }
}
