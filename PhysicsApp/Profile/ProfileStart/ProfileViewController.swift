//
//  ProfileViewController.swift
//  TrainingApp
//
//  Created by мак on 18/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import FirebaseAuth
import VK_ios_sdk

@IBDesignable class ProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var testsHistoryButton: UIButton!
    @IBOutlet weak var supportButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var ringViewAroundPhoto: UIImageView!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var vkButton: UIButton!
    @IBOutlet weak var youtubeButton: UIButton!
    @IBOutlet weak var telegramButton: UIButton!
    
    var viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        prepareData()
        setUpUsersImage()
    }
    
    func prepareData() {
        viewModel.getUsersData { [weak self] (user) in
            if let `self` = self, let user = user {
                self.nameLabel.text = user.name
            }
        }
        viewModel.getUsersPhoto { [weak self] (photo) in
            if let `self` = self, let photo = photo {
                self.userImage.image = photo
            }
        }
        if UserStatsCounter.shared.nextValue == 0 {
            ratingLabel.text = "Ожидаемый балл на ЕГЭ: \(UserStatsCounter.shared.srEGE)"
        } else {
            ratingLabel.text = "Ожидаемый балл на ЕГЭ: \(UserStatsCounter.shared.srEGE) - \(UserStatsCounter.shared.nextValue)"
        }
    }
    
    func designScreenElements() {
        if Auth.auth().currentUser == nil {
            createDescriptionForUnAuth()
        }
        
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
        DesignService.designRedButton(logOutButton)
        DesignService.designBlueButton(testsHistoryButton)
        DesignService.designBlueButton(supportButton)
        
        ringViewAroundPhoto.layer.cornerRadius = ringViewAroundPhoto.frame.height * 0.5
        ringViewAroundPhoto.layer.borderWidth = 1
        ringViewAroundPhoto.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        
        userImage.layer.cornerRadius = userImage.frame.height * 0.5
    }
    
    func createDescriptionForUnAuth() {
        hideSomeScreenElements()
        
        // Description
        let textView = UITextView()
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: profileLabel.bottomAnchor, constant: 30).isActive = true
        textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30).isActive = true
        textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30).isActive = true
        textView.heightAnchor.constraint(equalToConstant: 280).isActive = true
        textView.font = UIFont(name: "Montserrat-Regular", size: 18)
        textView.text = "Привет! Зарегистрированным пользователям здесь доступна информация о своем профиле, а также история пробников! Зарегистрируйся через ВКонтакте и получи много крутых фишек, таких как cохранение прогресса, cтатистика по задачам, доступ к разделу задач с ошибками, сохранение ответов и времени в пробнике после выхода из приложения!"
        
        // Button text changing
        logOutButton.setTitle("ЗАРЕГИСТРИРОВАТЬСЯ", for: .normal)
    }
    
    func hideSomeScreenElements() {
        userImage.isHidden = true
        ringViewAroundPhoto.isHidden = true
        nameLabel.isHidden = true
        ratingLabel.isHidden = true
        testsHistoryButton.isHidden = true
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        viewModel.eraseUserDefaults()
        viewModel.logOut()
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.modalPresentationStyle = .fullScreen
        present(welcomeViewController, animated: true)
    }
    
    @IBAction func socialNetworkTapped(_ sender: UIButton) {
        var urlString = ""
        switch sender {
        case instagramButton: urlString = "instagram://user?username=ege.newton"
        case vkButton: urlString = "vk://vk.com/ege_newton"
        case youtubeButton: urlString = "youtube://youtube.com/channel/UCOX_zZTKMv7Y6mrBKeTSsyw"
        case telegramButton: urlString = "tg://resolve?domain=egenewton"
        default: break
        }
        if let appURL = URL(string: urlString), UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            switch sender {
            case instagramButton: urlString = "https://instagram.com/ege.newton"
            case vkButton: urlString = "https://vk.com/ege_newton"
            case youtubeButton: urlString = "https://www.youtube.com/channel/UCOX_zZTKMv7Y6mrBKeTSsyw"
            case telegramButton: urlString = "https://t.me/egenewton"
            default: break
            }
            if let safariURL = URL(string: urlString) {
                UIApplication.shared.open(safariURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    private func setUpUsersImage() {
        userImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        userImage.isUserInteractionEnabled = true
    }
    
    @objc private func handlePickingPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func testsHistoryTapped(_ sender: UIButton) {
        let testsHistoryViewController = TestsHistoryViewController()
        testsHistoryViewController.modalPresentationStyle = .fullScreen
        present(testsHistoryViewController, animated: true)
    }
    
    @IBAction func supportTapped(_ sender: UIButton) {
        let formSheetViewController = FormSheetViewController()
        formSheetViewController.modalPresentationStyle = .fullScreen
        present(formSheetViewController, animated: true)
    }
    
    @IBAction func closeTapped(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            userImage.image = selectedImage
            if let uploadData = selectedImage.pngData() {
                viewModel.updatePhotoData(with: uploadData)
            }
        }
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: ProfileInfoUpdater {
    func updateProfileInfo() {
        prepareData()
    }
}
