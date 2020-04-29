//
//  MixesViewController.swift
//  PhysicsApp
//
//  Created by мак on 05/04/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import FirebaseFirestore

class MixesViewController: UIViewController {

    @IBOutlet weak var mixesCollectionView: UICollectionView!
    
    var viewModel = MixesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mixesCollectionView.dataSource = self
        mixesCollectionView.delegate = self
        mixesCollectionView.collectionViewLayout = getCellsLayout()
        let nibCell = UINib(nibName: "AwardCollectionViewCell", bundle: nil)
        mixesCollectionView.register(nibCell, forCellWithReuseIdentifier: "AwardCollectionViewCell")
        designScreenElements()
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
    }
    
    @IBAction func profileTapped(_ sender: UIButton) {
        present(ProfileViewController(), animated: true)
    }
    
    func getCellsLayout() -> UICollectionViewFlowLayout {
        let itemSize = UIScreen.main.bounds.width / 2 - 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize)
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        return layout
    }
}

extension MixesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mixViewController = MixViewController()
        mixViewController.viewModel = DayMixViewModel()
        mixViewController.viewModel?.mixName = viewModel.mixes[indexPath.row]
        mixViewController.modalPresentationStyle = .fullScreen
        present(mixViewController, animated: true)
    }
}

extension MixesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.mixes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AwardCollectionViewCell", for: indexPath) as! AwardCollectionViewCell
        cell.lockView.isHidden = true
        cell.awardImageView.image = #imageLiteral(resourceName: "badge")
        cell.awardNameLabel.text = viewModel.mixes[indexPath.row]
        return cell
    }
}
