//
//  ProfileViewController.swift
//  TrainingApp
//
//  Created by мак on 18/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

@IBDesignable class ProfileViewController: UIViewController {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var testsHistoryButton: UIButton!
    @IBOutlet weak var changeButton: UIButton!
    //@IBOutlet weak var myAwardsButton: UIButton!
    //@IBOutlet weak var statsButton: UIButton!
    
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
                self.emailLabel.text = user.email
                self.passwordLabel.text = self.viewModel.getHiddenPassword()
            }
        }
        viewModel.getUsersPhoto { [weak self] (photo) in
            if let `self` = self, let photo = photo {
                self.userImage.image = photo
            }
        }
//        viewModel.getUsersRating { [weak self] (rating) in
//            if let rating = rating {
//                self?.ratingLabel.text = "Рейтинг: \(rating) место"
//            }
//        }
        if UserStatsCounter.shared.nextValue == 0 {
            ratingLabel.text = "Ожидаемый балл на ЕГЭ: \(UserStatsCounter.shared.srEGE)"
        } else {
            ratingLabel.text = "Ожидаемый балл на ЕГЭ: \(UserStatsCounter.shared.srEGE) - \(UserStatsCounter.shared.nextValue)"
        }
    }
    
    func designScreenElements() {
        DesignService.setGradient(for: view)
        userImage.layer.cornerRadius = 20
        ratingLabel.layer.cornerRadius = 10
        ratingLabel.textColor = UIColor(displayP3Red: 0, green: 0.57, blue: 0.85, alpha: 1)
        ratingLabel.clipsToBounds = true
        DesignService.designWhiteButton(logOutButton)
        logOutButton.layer.cornerRadius = 5
        DesignService.designWhiteButton(testsHistoryButton)
        DesignService.designWhiteButton(changeButton)
        changeButton.layer.cornerRadius = 5
        //DesignService.designWhiteButton(myAwardsButton)
        //DesignService.designWhiteButton(statsButton)
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        viewModel.eraseUserDefaults()
        viewModel.logOut()
        let welcomeViewController = WelcomeViewController()
        welcomeViewController.modalPresentationStyle = .fullScreen
        present(welcomeViewController, animated: true)
    }
    @IBAction func changeTapped(_ sender: UIButton) {
        let profileDataChangeViewController = ProfileDataChangeViewController()
        viewModel.transportData(to: profileDataChangeViewController.viewModel)
        profileDataChangeViewController.profileInfoUpdater = self
        present(profileDataChangeViewController, animated: true)
    }
    
    private func setUpUsersImage() {
         userImage.layer.cornerRadius = 10
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
        Animations.swipeViewController(.fromRight, for: view)
        testsHistoryViewController.modalPresentationStyle = .fullScreen
        present(testsHistoryViewController, animated: true)
    }
    
    //    @IBAction func myAwardsTapped(_ sender: UIButton) {
    //        Animations.swipeViewController(.fromRight, for: view)
//        let awardsViewController = AwardsViewController()
//        awardsViewController.modalPresentationStyle = .fullScreen
//        present(awardsViewController, animated: true)
//    }
//
//    @IBAction func statsTapped(_ sender: UIButton) {
//        Animations.swipeViewController(.fromRight, for: view)
//        let userStatsViewController = UserStatsViewController()
//        userStatsViewController.modalPresentationStyle = .fullScreen
//        present(userStatsViewController, animated: true)
//    }
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
