//
//  WelcomeViewController.swift
//  TrainingApp
//
//  Created by мак on 12/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import VK_ios_sdk

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    var userEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let sdkInstance = VKSdk.initialize(withAppId: "7379630")
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(signInButton)
        DesignService.designWhiteButton(signUpButton)
    }
    
    @IBAction func signInTapped(_ sender: UIButton) {
        let signInViewController = SignInViewController()
        signInViewController.modalPresentationStyle = .fullScreen
        present(signInViewController, animated: true)
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let signUpViewController = SignUpViewController()
        signUpViewController.modalPresentationStyle = .fullScreen
        present(signUpViewController, animated: true)
    }
}

extension WelcomeViewController: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        if result.token != nil && result.error == nil {
            if let email = result.token.email {
                self.userEmail = email
            }
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
}

extension WelcomeViewController: VKSdkUIDelegate {
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
