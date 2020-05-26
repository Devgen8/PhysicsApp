//
//  SignInViewController.swift
//  TrainingApp
//
//  Created by мак on 12/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import VK_ios_sdk
import Lottie

class SignInViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var loaderView: AnimationView!
    
    var userEmail = ""
    
    var viewModel = SignInViewModel()
    var signUpViewModel = SignUpViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(signInButton)
        DesignService.designWhiteButton(vkButton)
        vkButton.imageEdgeInsets = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        errorLabel.isHidden = true
        loaderView.isHidden = true
        
        emailTextField.layer.borderWidth = 1
        passwordTextField.layer.borderWidth = 1
        
        emailTextField.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        passwordTextField.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("17694-cube-grid")
        loaderView.loopMode = .loop
        view.bringSubviewToFront(loaderView)
        loaderView.play()
        loaderView.isHidden = false
    }
    
    func removeLoadingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    func addLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        addLoadingScreen()
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text else {
                self.showError("Please fill in all fields")
                return
        }
        viewModel.authorizeUser(email: email, password: password) { [weak self] (userEmail) in
            guard let self = self else { return }
            if userEmail != nil {
                var mainViewController = UIViewController()
                if userEmail == "nastena020300@ya.ru" {
                    mainViewController = MainAdminViewController()
                } else {
                    mainViewController = TabBarViewController()
                }
                mainViewController.modalPresentationStyle = .fullScreen
                self.removeLoadingScreen()
                self.present(mainViewController, animated: true)
            } else {
                self.showError("There is no such a user. Sign up, please")
            }
        }
    }
    
    func showError(_ error: String) {
        removeLoadingScreen()
        errorLabel.isHidden = false
        errorLabel.text = error
    }
    @IBAction func vkTapped(_ sender: UIButton) {
        let sdkInstance = VKSdk.initialize(withAppId: "7379630")
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
        let scope = ["freinds", "email"]
        VKSdk.wakeUpSession(scope, complete: { (state, error) in
            if state == .authorized && error == nil && VKSdk.accessToken() != nil {
                print("vk authorized")
            } else if state == .initialized {
                print("vk initialized")
                VKSdk.authorize(scope, with: .disableSafariController)
            } else {
                if error != nil {
                    print(error!)
                }
            }
        })
    }
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension SignInViewController: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        addLoadingScreen()
        if result.token != nil && result.error == nil {
            if let email = result.token.email {
                self.userEmail = email
                var letters = [Character]()
                for letter in email {
                    if letter != "@" {
                        letters.append(letter)
                    } else {
                        break
                    }
                }
                let name = String(letters)
                while letters.count < 10 {
                    letters.append("1")
                }
                let password = String(letters)
                signUpViewModel.createUser(name: name, email: email, password: password, confirmPassword: password) { (error, userEmail) in
                    guard error == nil else {
                        self.viewModel.authorizeUser(email: email, password: password) { (email) in
                            guard email != nil else {
                                self.showError("Не удалось авторизоваться")
                                return
                            }
                            let tabBarViewController = TabBarViewController()
                            tabBarViewController.modalPresentationStyle = .fullScreen
                            self.removeLoadingScreen()
                            self.present(tabBarViewController, animated: true)
                            return
                        }
                        return
                    }
                    let tabBarViewController = TabBarViewController()
                    tabBarViewController.modalPresentationStyle = .fullScreen
                    self.removeLoadingScreen()
                    self.present(tabBarViewController, animated: true)
                }
            }
        } else {
            showError("Не удалось авторизоваться")
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
}

extension SignInViewController: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true)
//        if (self.presentedViewController != nil) {
//            self.dismiss(animated: true, completion: {
//                print("hide current modal controller if presents")
//                self.present(controller, animated: true, completion: {
//                    print("SFSafariViewController opened to login through a browser")
//                })
//            })
//        } else {
//            self.present(controller, animated: true, completion: {
//                print("SFSafariViewController opened to login through a browser")
//            })
//        }
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("Not presenting")
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
