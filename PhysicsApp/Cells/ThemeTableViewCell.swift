//
//  ThemeTableViewCell.swift
//  TrainingApp
//
//  Created by мак on 16/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class ThemeTableViewCell: UITableViewCell {

    @IBOutlet weak var decorativeView: UIView!
    @IBOutlet weak var themeName: UILabel!
    @IBOutlet weak var tickImage: UIImageView!
    @IBOutlet var themesImages: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        designScreenElements()
        selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func designScreenElements() {
        decorativeView.layer.cornerRadius = 30
    }
    
    func setupStatsLines(mistakesProgress: Float, successProgress: Float, fullWidth: CGFloat, semiSuccessProgress: Float? = nil) {
        decorativeView.backgroundColor = .gray
        let decorativeWidth = fullWidth
        
        let mistakesProgressView = ProgressBarView(color: .systemRed)
        mistakesProgressView.translatesAutoresizingMaskIntoConstraints = false
        decorativeView.addSubview(mistakesProgressView)
        mistakesProgressView.backgroundColor = .clear
        mistakesProgressView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        mistakesProgressView.widthAnchor.constraint(equalToConstant: decorativeWidth * CGFloat(mistakesProgress)).isActive = true
        mistakesProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor).isActive = true
        mistakesProgressView.centerYAnchor.constraint(equalTo: decorativeView.centerYAnchor).isActive = true
        
        if let semiSuccessProgress = semiSuccessProgress {
            let semiSuccessProgressView = ProgressBarView(color: .yellow)
            semiSuccessProgressView.translatesAutoresizingMaskIntoConstraints = false
            decorativeView.addSubview(semiSuccessProgressView)
            semiSuccessProgressView.backgroundColor = .clear
            semiSuccessProgressView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
            semiSuccessProgressView.widthAnchor.constraint(equalToConstant: decorativeWidth * CGFloat(semiSuccessProgress)).isActive = true
            semiSuccessProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor).isActive = true
            semiSuccessProgressView.centerYAnchor.constraint(equalTo: decorativeView.centerYAnchor).isActive = true
        }
        
        let successProgressView = ProgressBarView(color: .systemGreen)
        successProgressView.translatesAutoresizingMaskIntoConstraints = false
        decorativeView.addSubview(successProgressView)
        successProgressView.backgroundColor = .clear
        successProgressView.heightAnchor.constraint(equalToConstant: contentView.frame.height).isActive = true
        successProgressView.widthAnchor.constraint(equalToConstant: decorativeWidth * CGFloat(successProgress)).isActive = true
        successProgressView.leadingAnchor.constraint(equalTo: decorativeView.leadingAnchor).isActive = true
        successProgressView.centerYAnchor.constraint(equalTo: decorativeView.centerYAnchor).isActive = true
        
        
        decorativeView.bringSubviewToFront(themeName)
    }
    
}
