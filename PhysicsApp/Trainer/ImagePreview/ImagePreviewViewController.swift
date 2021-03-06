//
//  ImagePreviewViewController.swift
//  TrainingApp
//
//  Created by мак on 17/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class ImagePreviewViewController: UIViewController {
    
    @IBOutlet weak var closeButton: UIButton!
    var imageScrollView: ImageScrollView!
    @IBOutlet weak var wrightAnswerLabel: UILabel!
    
    var taskImage: UIImage?
    var wrightAnswer: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageScrollView = ImageScrollView(frame: view.bounds)
        view.addSubview(imageScrollView)
        setupImageScrollView()
        if let image = taskImage {
            imageScrollView.set(image: image)
        }
        view.bringSubviewToFront(closeButton)
        if wrightAnswer != nil {
            wrightAnswerLabel.text = "Ответ: " + wrightAnswer!
            view.bringSubviewToFront(wrightAnswerLabel)
        }
        
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.designCloseButton(closeButton)
    }
    
    func setupImageScrollView() {
        imageScrollView.translatesAutoresizingMaskIntoConstraints = false
        imageScrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageScrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageScrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageScrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
