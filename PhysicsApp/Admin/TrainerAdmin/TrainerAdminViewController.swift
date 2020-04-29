//
//  TrainerAdminViewController.swift
//  TrainingApp
//
//  Created by мак on 24/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class TrainerAdminViewController: UIViewController {

    @IBOutlet weak var themePicker: UIPickerView!
    @IBOutlet weak var uploadImageView: UIImageView!
    @IBOutlet weak var wrightAnswerTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    
    var viewModel = TrainerAdminViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themePicker.dataSource = self
        themePicker.delegate = self
        designScreenElements()
        preparePickerData()
    }
    
    func preparePickerData() {
        viewModel.getThemes { [weak self] (isReady) in
            if isReady {
                DispatchQueue.main.async {
                    self?.themePicker.reloadAllComponents()
                }
            }
        }
    }
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        DesignService.designWhiteButton(uploadButton)
        themePicker.layer.cornerRadius = 15
        setUpUsersImage()
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: true)
    }
    
    @IBAction func uploadTapped(_ sender: UIButton) {
    }
    
    private func setUpUsersImage() {
        uploadImageView.layer.cornerRadius = 15
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        uploadImageView.isUserInteractionEnabled = true
    }
    
    @objc private func handlePickingPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
}

extension TrainerAdminViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let pickerLabel = UILabel()
        pickerLabel.font = UIFont(name: "Montserrat", size: 25)
        pickerLabel.textAlignment = .center
        pickerLabel.text = viewModel.getTheme(for: row)
        pickerLabel.textColor = .black

        return pickerLabel
    }
}

extension TrainerAdminViewController: UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getThemesNumber()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
}

extension TrainerAdminViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
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
            uploadImageView.image = selectedImage
            if let uploadData = selectedImage.pngData() {
                viewModel.updatePhotoData(with: uploadData)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
