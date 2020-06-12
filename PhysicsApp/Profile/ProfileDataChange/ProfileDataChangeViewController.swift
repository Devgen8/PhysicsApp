//
//  ProfileDataChangeViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 14.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class ProfileDataChangeViewController: UIViewController {
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    var viewModel = ProfileDataChangeViewModel()
    var profileInfoUpdater: ProfileInfoUpdater?
    var activeTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        designScreenElements()
        getData()
        addTextFieldsObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addTextFieldsObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        let info = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let keyboardY = view.frame.size.height - keyboardSize.height
        let editingTextFieldY = activeTextField.frame.origin.y
        if view.frame.origin.y >= 0 {
            if editingTextFieldY > keyboardY - 190 {
                UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
                    self.view.frame = CGRect(x: 0, y: self.view.frame.origin.y - (editingTextFieldY - (keyboardY - 190)), width: self.view.bounds.width, height: self.view.bounds.height)
                }, completion: nil)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
    }
    
    func getData() {
        viewModel.prepareData { (name, email, password) in
            self.nameTextField.text = name
            self.emailTextField.text = email
            self.passwordTextField.text = password
            self.confirmPasswordTextField.text = password
        }
    }
    
    func designScreenElements() {
        DesignService.designCloseButton(closeButton)
        cancelButton.layer.cornerRadius = 15
        okButton.layer.cornerRadius = 15
        for textField in [emailTextField, nameTextField, passwordTextField, confirmPasswordTextField] {
            textField?.layer.borderWidth = 1
            textField?.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
            DesignService.createPadding(for: textField ?? UITextField())
            textField?.delegate = self
        }
        errorLabel.isHidden = true
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func okTapped(_ sender: UIButton) {
        viewModel.changeUserData(email: emailTextField.text ?? "",
                                 name: nameTextField.text ?? "",
                                 password: passwordTextField.text ?? "",
                                 confirmPassword: confirmPasswordTextField.text ?? "") { (error) in
                                    guard error == nil else {
                                        self.showError(error ?? "Произошла ошибка")
                                        return
                                    }
                                    self.profileInfoUpdater?.updateProfileInfo()
                                    self.dismiss(animated: true)
        }
    }
    
    func showError(_ error: String) {
        errorLabel.isHidden = false
        errorLabel.text = error
    }
}

extension ProfileDataChangeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}
