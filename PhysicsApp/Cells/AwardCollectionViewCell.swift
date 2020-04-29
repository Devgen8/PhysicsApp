//
//  AwardCollectionViewCell.swift
//  TrainingApp
//
//  Created by мак on 23/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class AwardCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var lockView: UIView!
    @IBOutlet weak var awardNameLabel: UILabel!
    @IBOutlet weak var awardImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lockView.layer.cornerRadius = 15
    }

}
