//
//  WelcomeViewController.swift
//  TrainingApp
//
//  Created by мак on 12/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import VK_ios_sdk
import Lottie

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loaderView: AnimationView!
    
    var viewModel = WelcomeViewModel()
    
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
        errorLabel.isHidden = true
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
    
    // vk authorization
    @IBAction func signInTapped(_ sender: UIButton) {
        let sdkInstance = VKSdk.initialize(withAppId: "7379630")
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
        let scope = ["email", "photos",]
        VKSdk.wakeUpSession(scope, complete: { (state, error) in
            if state == .authorized && error == nil && VKSdk.accessToken() != nil {
                VKSdk.authorize(scope, with: .disableSafariController)
            } else if state == .initialized {
                VKSdk.authorize(scope, with: .disableSafariController)
            } else {
                if error != nil {
                    print(error!)
                }
            }
        })
    }
    
    //anonimus auth
    @IBAction func signUpTapped(_ sender: UIButton) {
        let trainerViewController = TrainerViewController()
        trainerViewController.modalPresentationStyle = .fullScreen
        present(trainerViewController, animated: true)
    }
    
    func showError(_ error: String) {
           removeLoadingScreen()
           errorLabel.isHidden = false
           errorLabel.text = error
    }
}

extension WelcomeViewController: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        addLoadingScreen()
        if result.token != nil && result.error == nil {
            viewModel.authUser(with: result) { (error, isAdmin) in
                guard error == nil else {
                    self.showError(error ?? "")
                    return
                }
                var rootViewController = UIViewController()
                if isAdmin {
                    rootViewController = MainAdminViewController()
                } else {
                    rootViewController = TrainerViewController()
                    self.viewModel.saveUsersDataInFirestore(result)
                }
                rootViewController.modalPresentationStyle = .fullScreen
                self.removeLoadingScreen()
                self.present(rootViewController, animated: true)
            }
        } else {
            showError("Не удалось авторизоваться")
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
}

extension WelcomeViewController: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("Not presenting")
    }
}
