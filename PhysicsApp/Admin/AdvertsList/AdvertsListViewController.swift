//
//  AdvertsListViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class AdvertsListViewController: UIViewController {

    @IBOutlet weak var advertsTableView: UITableView!
    var loaderView = AnimationView()
    
    var viewModel = AdvertsListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        advertsTableView.delegate = self
        advertsTableView.dataSource = self
        
        designScreenElements()
        prepareData()
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getAdverts { (isReady) in
            if isReady {
                self.advertsTableView.reloadData()
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
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: false)
    }
    
    @IBAction func addTapped(_ sender: UIButton) {
        let adminAdvertDetailViewController = AdminAdvertDetailViewController()
        adminAdvertDetailViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        adminAdvertDetailViewController.isCreating = true
        adminAdvertDetailViewController.advertUpdater = self
        present(adminAdvertDetailViewController, animated: false)
    }
}

extension AdvertsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getAdvertsNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        let decorativeView = UIView()
        cell.contentView.addSubview(decorativeView)
        decorativeView.translatesAutoresizingMaskIntoConstraints = false
        decorativeView.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 5).isActive = true
        decorativeView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 5).isActive = true
        decorativeView.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -5).isActive = true
        decorativeView.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -5).isActive = true
        decorativeView.layer.cornerRadius = 15
        decorativeView.backgroundColor = .white
        cell.textLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        cell.textLabel?.text = viewModel.getAdvertName(for: indexPath.row)
        cell.textLabel?.textColor = .black
        
        return cell
    }
}

extension AdvertsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteAdvert(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let adminAdvertDetailViewController = AdminAdvertDetailViewController()
        adminAdvertDetailViewController.modalPresentationStyle = .fullScreen
        Animations.swipeViewController(.fromRight, for: view)
        adminAdvertDetailViewController.isCreating = false
        adminAdvertDetailViewController.advertUpdater = self
        adminAdvertDetailViewController.viewModel.setAdvert(viewModel.getAdvert(for: indexPath.row))
        present(adminAdvertDetailViewController, animated: false)
    }
}

extension AdvertsListViewController: AdvertUpdater {
    func updateAdverts(mode: EditingMode, advertData: Advert, oldName: String?) {
        switch mode {
        case .add:
            viewModel.addAdvert(advertData)
        case .edit:
            viewModel.editAdvert(oldName: oldName ?? "", newAdvert: advertData)
        case .delete:
            viewModel.deleteAdvert(advertData)
        }
        advertsTableView.reloadData()
    }
}
