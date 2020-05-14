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
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    var viewModel = ProfileDataChangeViewModel()
    var profileInfoUpdater: ProfileInfoUpdater?

    override func viewDidLoad() {
        super.viewDidLoad()

        designScreenElements()
        createBlurEffect()
        getData()
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
        DesignService.designBlueButton(cancelButton)
        DesignService.designBlueButton(okButton)
        mainView.clipsToBounds = true
        mainView.layer.cornerRadius = 20
        errorLabel.isHidden = true
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
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
