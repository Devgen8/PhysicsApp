//
//  TestResultTaskTableViewCell.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 19.04.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class TestResultTaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskName: UILabel!
    @IBOutlet weak var usersAnswerLabel: UILabel!
    @IBOutlet weak var wrightAnswerLabel: UILabel!
    @IBOutlet weak var extendButton: UIButton!
    @IBOutlet weak var userPointsLabel: UILabel!
    @IBOutlet weak var correctionLabel: UILabel!
    
    var taskImageView = UIImageView()
    var descriptionImageView = UIImageView()
    var imageOpener: ImageOpener?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        setRoundedBackground()
        setupRoundedButton()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setupRoundedButton() {
        extendButton.layer.cornerRadius = 0.5 * extendButton.bounds.size.width
        extendButton.imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
    }
    
    func setRoundedBackground() {
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(roundedView)
        roundedView.tag = 100
        contentView.sendSubviewToBack(roundedView)
        roundedView.backgroundColor = .white
        roundedView.layer.cornerRadius = 20
        roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        roundedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
        roundedView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        roundedView.layer.borderWidth = 1
    }
    
    func setImages(mainRatio: CGFloat, descriptionRatio: CGFloat) {
        contentView.addSubview(taskImageView)
        taskImageView.translatesAutoresizingMaskIntoConstraints = false
        taskImageView.topAnchor.constraint(equalTo: userPointsLabel.bottomAnchor, constant: 25).isActive = true
        taskImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11).isActive = true
        taskImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -11).isActive = true
        taskImageView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 22) * mainRatio).isActive = true
        taskImageView.clipsToBounds = true
        taskImageView.isUserInteractionEnabled = true
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        taskImageView.addGestureRecognizer(imageTapGesture)
        
        contentView.addSubview(descriptionImageView)
        descriptionImageView.translatesAutoresizingMaskIntoConstraints = false
        descriptionImageView.topAnchor.constraint(equalTo: taskImageView.bottomAnchor, constant: 5).isActive = true
        descriptionImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 11).isActive = true
        descriptionImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -11).isActive = true
        descriptionImageView.heightAnchor.constraint(equalToConstant: (UIScreen.main.bounds.width - 22) * descriptionRatio).isActive = true
        descriptionImageView.clipsToBounds = true
        descriptionImageView.isUserInteractionEnabled = true
        let descriptionTapGesture = UITapGestureRecognizer(target: self, action: #selector(descriptionTapped))
        descriptionImageView.addGestureRecognizer(descriptionTapGesture)
    }
    
    @objc func imageTapped() {
        imageOpener?.openImage(taskImageView.image ?? UIImage())
    }
    
    @objc func descriptionTapped() {
        imageOpener?.openImage(descriptionImageView.image ?? UIImage())
    }
    
}
