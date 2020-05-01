//
//  MainAdminViewController.swift
//  TrainingApp
//
//  Created by мак on 24/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class MainAdminViewController: UIViewController {

    @IBOutlet weak var trainerButton: UIButton!
    @IBOutlet weak var statsButton: UIButton!
    @IBOutlet weak var messagesButton: UIButton!
    @IBOutlet weak var quitButton: UIButton!
    
    var viewModel = MainAdminViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        trainerButton.backgroundColor = .white
        trainerButton.layer.cornerRadius = 10
        statsButton.backgroundColor = .white
        statsButton.layer.cornerRadius = 10
        messagesButton.backgroundColor = .white
        messagesButton.layer.cornerRadius = 10
        DesignService.designWhiteButton(quitButton)
    }
    
    @IBAction func trainerTapped(_ sender: UIButton) {
        let trainerAdminViewController = TrainerAdminViewController()
        trainerAdminViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(trainerAdminViewController, animated: true)
    }
    @IBAction func statsTapped(_ sender: UIButton) {
        let adminStatsViewController = AdminStatsViewController()
        adminStatsViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(adminStatsViewController, animated: true)
    }
    
    @IBAction func messagesTapped(_ sender: UIButton) {
        let adminMessagesViewController = AdminMessagesViewController()
        adminMessagesViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        present(adminMessagesViewController, animated: true)
    }
    
    @IBAction func quitTapped(_ sender: UIButton) {
        viewModel.logOut()
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.modalPresentationStyle = .fullScreen
        present(welcomeViewController, animated: true)
    }
}
