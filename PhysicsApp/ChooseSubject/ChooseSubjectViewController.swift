//
//  ChooseSubjectViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 30.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class ChooseSubjectViewController: UIViewController {

    @IBOutlet weak var advertsCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var physicsButton: UIButton!
    @IBOutlet weak var mathButton: UIButton!
    @IBOutlet weak var russianButton: UIButton!
    @IBOutlet weak var ITButton: UIButton!
    var loaderView = AnimationView()
    
    var viewModel = ChooseSubjectViewModel()
    var timer = Timer()
    var currentPageNumber = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // collection view
        advertsCollectionView.dataSource = self
        advertsCollectionView.delegate = self
        advertsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "advertCell")
        advertsCollectionView.collectionViewLayout = getCellsLayout()
        
        designScreenElements()
        prepareData()
    }
    
    @objc func changeAdvert() {
        currentPageNumber %= viewModel.getAdvertsNumber()
        var customIndexPath = IndexPath.init(row: currentPageNumber, section: 0)
        if let hjh = advertsCollectionView.cellForItem(at: customIndexPath) {
            customIndexPath = advertsCollectionView.indexPath(for: hjh) ?? IndexPath()
        }
        advertsCollectionView.scrollToItem(at: customIndexPath, at: .centeredHorizontally, animated: true)
        pageControl.currentPage = currentPageNumber
        currentPageNumber += 1
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designBlueButton(physicsButton)
        DesignService.designGrayButton(mathButton)
        DesignService.designGrayButton(russianButton)
        DesignService.designGrayButton(ITButton)
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getAdverts { (isReady) in
            if isReady {
//                DispatchQueue.main.async {
//                    self.timer = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(self.changeAdvert), userInfo: nil, repeats: true)
//                }
                // page control
                self.pageControl.numberOfPages = self.viewModel.getAdvertsNumber()
                self.pageControl.currentPage = 0
                self.advertsCollectionView.reloadData()
                self.hideLodingScreen()
            }
        }
    }
    
    func createWhiteBackground() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        blurEffectView.backgroundColor = .white
        view.addSubview(blurEffectView)
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("lf30_editor_cg3gHF")
        loaderView.loopMode = .loop
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func showLoadingScreen() {
        createWhiteBackground()
        setAnimation()
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    func getCellsLayout() -> UICollectionViewFlowLayout {
        let itemWidth = UIScreen.main.bounds.width - 20
        let itemHeight = itemWidth * 200 / 340
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }
    
    @IBAction func physicsTapped(_ sender: UIButton) {
        let trainerViewController = TrainerViewController()
        trainerViewController.modalPresentationStyle = .fullScreen
        present(trainerViewController, animated: true)
    }
}

extension ChooseSubjectViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAdvert = viewModel.getAdvert(for: indexPath.row)
        let advertDetailViewController = AdvertDetailViewController()
        advertDetailViewController.viewModel.setAdvert(selectedAdvert)
        advertDetailViewController.modalPresentationStyle = .fullScreen
        present(advertDetailViewController, animated: true)
    }
}

extension ChooseSubjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.getAdvertsNumber()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "advertCell", for: indexPath)
        let advertImage = UIImageView()
        advertImage.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(advertImage)
        advertImage.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 5).isActive = true
        advertImage.topAnchor.constraint(equalTo: cell.topAnchor, constant: 5).isActive = true
        advertImage.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -5).isActive = true
        advertImage.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
        advertImage.image = viewModel.getAdvertImage(for: indexPath.row)
        advertImage.layer.cornerRadius = 25
        advertImage.clipsToBounds = true
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentPageNumber = indexPath.row
        pageControl.currentPage = currentPageNumber
    }
}
