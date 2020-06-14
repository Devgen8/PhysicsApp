//
//  AdminSettingViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 13.06.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class AdminSettingViewController: UIViewController {
    
    var adminIdTableView: UITableView!
    var adminLabel: UILabel!
    var backButton: UIButton!
    var addButton: UIButton!
    var loaderView: AnimationView!
    var viewModel = AdminSettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designScreenElements()
        prepareData()
    }
    
    func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(100)?.removeFromSuperview()
    }
    
    func setAnimation() {
        loaderView.animation = Animation.named("17694-cube-grid")
        loaderView.loopMode = .loop
        loaderView.isHidden = false
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 100
        view.addSubview(blurEffectView)
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getAdminsList { (isReady) in
            if isReady {
                self.hideLodingScreen()
                self.adminIdTableView.reloadData()
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        createAdminLabel()
        createAddButton()
        createBackButton()
        createTableView()
        createLoaderView()
    }
    
    func createLoaderView() {
        let width: CGFloat = 120
        let height: CGFloat = 120
        loaderView = AnimationView()
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loaderView)
        loaderView.heightAnchor.constraint(equalToConstant: height).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: width).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        view.bringSubviewToFront(loaderView)
    }
    
    func createAddButton() {
        addButton = UIButton()
        addButton.setImage(#imageLiteral(resourceName: "plus"), for: .normal)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(addButton)
        addButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc func addButtonTapped() {
        let testAlertController = UIAlertController(title: "Новый админ", message: "Введите id из 8 цифр", preferredStyle: .alert)
        testAlertController.addTextField { (textField) in
            textField.placeholder = "id админа"
            textField.keyboardType = .numberPad
        }
        let add = UIAlertAction(title: "Добавить", style: .default) { (_) in
            self.viewModel.addId(testAlertController.textFields?.first?.text ?? "")
            self.adminIdTableView.reloadData()
        }
        let cancel = UIAlertAction(title: "Отменить", style: .cancel, handler: nil)
        testAlertController.addAction(add)
        testAlertController.addAction(cancel)
        
        present(testAlertController, animated: true)
    }
    
    func createTableView() {
        adminIdTableView = UITableView()
        adminIdTableView.delegate = self
        adminIdTableView.dataSource = self
        adminIdTableView.separatorStyle = .none
        adminIdTableView.backgroundColor = .clear
        adminIdTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adminIdTableView)
        adminIdTableView.topAnchor.constraint(equalTo: adminLabel.bottomAnchor, constant: 5).isActive = true
        adminIdTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        adminIdTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        adminIdTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    func createBackButton() {
        backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backButton)
        backButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 70).isActive = true
        backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        backButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }
    
    @objc func backTapped() {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: false)
    }
    
    func createAdminLabel() {
        adminLabel = UILabel()
        adminLabel.font = UIFont(name: "BlackDiamond", size: 45)
        adminLabel.text = "Администраторы"
        adminLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(adminLabel)
        adminLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 45).isActive = true
        adminLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    func animateCopyLabel(url: String) {
        let copyLabel = UILabel()
        copyLabel.text = "Скопировано \(url)"
        copyLabel.textAlignment = .center
        copyLabel.font = UIFont(name: "Montserrat-Medium", size: 18)
        copyLabel.alpha = 0
        copyLabel.layer.cornerRadius = 10
        copyLabel.clipsToBounds = true
        copyLabel.backgroundColor = .white
        copyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(copyLabel)
        copyLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        copyLabel.heightAnchor.constraint(equalToConstant: 60).isActive = true
        copyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        copyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        UIView.animate(withDuration: 2.5) {
            copyLabel.alpha = 1
        }
        UIView.animate(withDuration: 2.5) {
            copyLabel.alpha = 0
        }
    }
}

extension AdminSettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        UIPasteboard.general.string = (viewModel.getId(for: indexPath.row))
        animateCopyLabel(url: viewModel.getId(for: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteId(for: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension AdminSettingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getIdsNumbers()
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
        decorativeView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Montserrat-Bold", size: 20)
        cell.textLabel?.text = viewModel.getId(for: indexPath.row)
        
        return cell
    }
}
