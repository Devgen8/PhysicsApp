//
//  AdminMessagesViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class AdminMessagesViewController: UIViewController {

    @IBOutlet weak var messagesTableView: UITableView!
    @IBOutlet weak var loaderView: AnimationView!
    
    var viewModel = AdminMessagesViewModel()
    var selectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getMessages { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.messagesTableView.reloadData()
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
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
        loaderView.isHidden = false
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: false)
    }
    
    @IBAction func sortChanges(_ sender: UISegmentedControl) {
        var type = MessageSortTypes.profile
        switch sender.selectedSegmentIndex {
        case 0: type = .profile
        case 1: type = .tasks
        default: type = .all
        }
        viewModel.changeSortType(for: type) { (isReady) in
            if isReady {
                self.messagesTableView.reloadData()
            }
        }
    }
    
}

extension AdminMessagesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedRow == indexPath.row {
            return 280
        }
        else{
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        if selectedRow == indexPath.row {
            selectedRow = -1
        } else {
            selectedRow = indexPath.row
        }
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteMessage(for: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension AdminMessagesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfMessages()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("MessageTableViewCell", owner: self, options: nil)?.first as! MessageTableViewCell
        cell.emailLabel.text = viewModel.getUsersEmail(for: indexPath.row)
        cell.messageTextLabel.text = viewModel.getMessageText(for: indexPath.row)
        cell.themeLabel.text = viewModel.getMessageTheme(for: indexPath.row)
        
        return cell
    }
    
    
}
