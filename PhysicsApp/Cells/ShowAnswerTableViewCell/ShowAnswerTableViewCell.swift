//
//  TableViewCell.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 03.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class ShowAnswerTableViewCell: UITableViewCell {

    @IBOutlet weak var decorativeView: UIView!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        designDecorativeView()
    }
    
    func designDecorativeView() {
        decorativeView.layer.cornerRadius = 15
        decorativeView.layer.borderWidth = 1
        decorativeView.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
