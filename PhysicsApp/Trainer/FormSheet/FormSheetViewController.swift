//
//  FormSheetViewController.swift
//  TrainingApp
//
//  Created by мак on 17/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class FormSheetViewController: UIViewController {

    @IBOutlet weak var mistakeTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var themeTextField: UITextField!
    @IBOutlet weak var closeButton: UIButton!
    
    private var keyboardHeight: CGFloat!
    private var isKeyboardHidden = true
    private var isActiveTextField = false
    
    var viewModel = FormSheetViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        showMessageTheme()
        addTextViewObservers()
        addKeyboardDismissGesture()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func showMessageTheme() {
        if let taskName = viewModel.getTaskName() {
            themeTextField.text = "Ошибка в \(taskName)"
        }
    }
    
    func addTextViewObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addKeyboardDismissGesture() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        themeTextField.resignFirstResponder()
        mistakeTextView.resignFirstResponder()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if isActiveTextField {
            isActiveTextField = false
            return
        }
        
        if !isKeyboardHidden {
            return
        }
        
        isKeyboardHidden = false
        
        if keyboardHeight == nil, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        
        // move if keyboard hide input field
        let distanceToBottom = self.view.frame.size.height - (mistakeTextView.frame.origin.y) - (mistakeTextView.frame.size.height)
        let collapseSpace = keyboardHeight - distanceToBottom

        if collapseSpace < 0 {
            // no collapse
            return
        }

        // set new offset for scroll view
        UIView.animate(withDuration: 0.3, animations: {
            // scroll to the position above keyboard 10 points
            self.view.frame = CGRect(x: 0, y: 0 - (collapseSpace + 10), width: self.view.bounds.width, height: self.view.bounds.height)
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        UIView.animate(withDuration: 0.3) {
            self.isKeyboardHidden = true
        }
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
        themeTextField.delegate = self
        mistakeTextView.delegate = self
        
        sendButton.layer.cornerRadius = 15
        cancelButton.layer.cornerRadius = 15
        mistakeTextView.layer.cornerRadius = 20
        
        themeTextField.layer.borderWidth = 1
        themeTextField.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        
        mistakeTextView.layer.borderWidth = 1
        mistakeTextView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        mistakeTextView.layer.cornerRadius = 0
        
        DesignService.createPadding(for: themeTextField)
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func sendTapped(_ sender: UIButton) {
        viewModel.sendMessage(theme: themeTextField.text ?? "", text: mistakeTextView.text)
        dismiss(animated: true)
    }
}

extension FormSheetViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isActiveTextField = true
    }
}

extension FormSheetViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
