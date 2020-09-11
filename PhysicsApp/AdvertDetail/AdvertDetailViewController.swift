//
//  AdvertDetailViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AdvertDetailViewController: UIViewController {

    @IBOutlet weak var advertTitleLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var advertImageView: UIImageView!
    @IBOutlet weak var textDescriptionTextView: UITextView!
    @IBOutlet weak var detailButton: UIButton!
    
    var viewModel = AdvertDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        designScreenElements()
        fillInData()
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(detailButton)
        DesignService.designCloseButton(closeButton)
        advertImageView.layer.cornerRadius = 25
        textDescriptionTextView.backgroundColor = .white
    }
    
    func fillInData() {
        advertTitleLabel.text = viewModel.getAdvertTitle()
        advertImageView.image = viewModel.getAdvertImage()
        textDescriptionTextView.text = viewModel.getAdvertDescription()
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func detailTapped(_ sender: UIButton) {
        let urlString = viewModel.getAdvertUrlString() ?? ""
        if let safariURL = URL(string: urlString) {
            UIApplication.shared.open(safariURL, options: [:], completionHandler: nil)
        }
    }
}
