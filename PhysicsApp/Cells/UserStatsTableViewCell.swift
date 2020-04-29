//
//  UserStatsTableViewCell.swift
//  PhysicsApp
//
//  Created by мак on 30/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class UserStatsTableViewCell: UITableViewCell {

    @IBOutlet weak var taskNumberLabel: UILabel!
    @IBOutlet weak var solvedNumberLabel: UILabel!
    @IBOutlet weak var accuracyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setRoundedBackground()
    }
    
    func setRoundedBackground() {
        let roundedView = UIView()
        roundedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(roundedView)
        contentView.sendSubviewToBack(roundedView)
        roundedView.backgroundColor = .white
        roundedView.layer.cornerRadius = 20
        roundedView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        roundedView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        roundedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
        roundedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10).isActive = true
    }
    
    func setupProgressBar(with color: UIColor, and percentage: Float) {
        let traceWidthConstant = contentView.frame.width - 40
        
        let progressViewTrace = ProgressBarView(color: .gray)
        progressViewTrace.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressViewTrace)
        progressViewTrace.backgroundColor = .clear
        progressViewTrace.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressViewTrace.widthAnchor.constraint(equalToConstant: traceWidthConstant).isActive = true
        progressViewTrace.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        progressViewTrace.topAnchor.constraint(equalTo: solvedNumberLabel.bottomAnchor, constant: 20).isActive = true
        
        let progressView = ProgressBarView(color: color)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(progressView)
        progressView.backgroundColor = .clear
        progressView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        progressView.widthAnchor.constraint(equalToConstant: traceWidthConstant * CGFloat(percentage)).isActive = true
        progressView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20).isActive = true
        progressView.topAnchor.constraint(equalTo: solvedNumberLabel.bottomAnchor, constant: 20).isActive = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
}
