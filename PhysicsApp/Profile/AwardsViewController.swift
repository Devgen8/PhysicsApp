//
//  AwardsViewController.swift
//  PhysicsApp
//
//  Created by мак on 26/03/2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class AwardsViewController: UIViewController {

    @IBOutlet weak var awardsCollectionView: UICollectionView!
    
    var viewModel = AwardsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        awardsCollectionView.dataSource = self
        awardsCollectionView.delegate = self
        awardsCollectionView.collectionViewLayout = getCellsLayout()
        let nibCell = UINib(nibName: "AwardCollectionViewCell", bundle: nil)
        awardsCollectionView.register(nibCell, forCellWithReuseIdentifier: "AwardCollectionViewCell")
        
        prepareData()
        designScreenElements()
    }
    
    func prepareData() {
        viewModel.getUsersAwardsData()
        viewModel.getAwards { (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self.awardsCollectionView.reloadData()
                }
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
}

extension AwardsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.awards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AwardCollectionViewCell", for: indexPath) as! AwardCollectionViewCell
        if let name = viewModel.awards[indexPath.row].name {
            cell.awardNameLabel.text = name
            cell.awardImageView.image = viewModel.awardsImages[name]
            cell.lockView.alpha = viewModel.checkAwardAccess(name) ? 0 : 0.6
        }
        return cell
    }
}

extension AwardsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        Animations.swipeViewController(.fromRight, for: view)
        let awardDetailViewController = AwardDetailViewController()
        viewModel.transportData(to: awardDetailViewController.viewModel, from: indexPath.row)
        awardDetailViewController.modalPresentationStyle = .fullScreen
        present(awardDetailViewController, animated: true)
    }
}
