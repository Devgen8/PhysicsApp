//
//  AskAuthViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 02.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AskAuthViewController: UIViewController {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var authButton: UIButton!
    
    var profileViewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.designCloseButton(closeButton)
        authButton.layer.cornerRadius = 15
    }
    
    func updateKeyInfo() {
        UserDefaults.standard.set(false, forKey: "isUserInformedAboutAuth")
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        updateKeyInfo()
        dismiss(animated: true)
    }
    
    @IBAction func authTapped(_ sender: UIButton) {
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.modalPresentationStyle = .fullScreen
        profileViewModel.eraseUserDefaults()
        present(welcomeViewController, animated: true)
    }
}
