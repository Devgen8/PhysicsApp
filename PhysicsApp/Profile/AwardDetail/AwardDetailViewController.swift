//
//  AwardDetailViewController.swift
//  PhysicsApp
//
//  Created by мак on 26/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AwardDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var awardImageView: UIImageView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var viewModel = AwardDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareData()
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    func prepareData() {
        nameLabel.text = viewModel.getName()
        awardImageView.image = viewModel.getImage()
        let progress = viewModel.getAwardLimit()
        progressBar.progress = Float(viewModel.usersProgress ?? 0) / Float(progress)
        progressLabel.text = "\(viewModel.usersProgress ?? 0)/\(progress)"
        descriptionLabel.text = viewModel.getDescription()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
}
