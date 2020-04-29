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
    @IBOutlet weak var taskImageView: UIImageView!
    @IBOutlet weak var usersAnswerLabel: UILabel!
    @IBOutlet weak var wrightAnswerLabel: UILabel!
    @IBOutlet weak var isCorrectImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setRoundedBackground()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

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
    }
    
    func setupCorrectionBar(with color: UIColor) {
        let traceWidthConstant = contentView.frame.width
        
        let progressViewTrace = ProgressBarView(color: color)
        progressViewTrace.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(progressViewTrace)
        progressViewTrace.backgroundColor = .clear
        progressViewTrace.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressViewTrace.widthAnchor.constraint(equalToConstant: traceWidthConstant).isActive = true
        progressViewTrace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25).isActive = true
        progressViewTrace.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10).isActive = true
        
        contentView.bringSubviewToFront(taskName)
    }
    
}
