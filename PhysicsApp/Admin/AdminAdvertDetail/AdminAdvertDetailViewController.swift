//
//  AdminAdvertDetailViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 31.08.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class AdminAdvertDetailViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var advertImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var urlStringTextField: UITextField!
    @IBOutlet weak var uploadButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    private var loaderView = AnimationView()
    
    private var keyboardHeight: CGFloat!
    private var isKeyboardHidden = true
    private var activeTextField: UITextField?
    
    var isCreating: Bool!
    var viewModel = AdminAdvertDetailViewModel()
    var advertUpdater: AdvertUpdater?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        urlStringTextField.delegate = self
        
        descriptionTextView.text = "Описание..."
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.delegate = self

        designScreenElements()
        addKeyboardDismissGesture()
        setUpUsersImage()
        
        if !isCreating {
            prepareData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addTextViewObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.heightAnchor.constraint(equalToConstant: descriptionTextView.frame.height).isActive = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addTextViewObservers() {
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        center.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func addKeyboardDismissGesture() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(returnTextView(gesture:))))
    }
    
    @objc func returnTextView(gesture: UIGestureRecognizer) {
        titleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
        urlStringTextField.resignFirstResponder()
    }
    
    @objc func keyboardDidShow(notification: Notification) {
        
        if activeTextField == titleTextField {
            return
        }
        
        if !isKeyboardHidden {
            return
        }
        
        isKeyboardHidden = false
        
        if keyboardHeight == nil, let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
        }
        
        // move if keyboard hide input field
        var yPosition: CGFloat = 0.0
        var objectHeight: CGFloat = 0.0
        if activeTextField != nil {
            yPosition = urlStringTextField.frame.origin.y
            objectHeight = urlStringTextField.frame.size.height
        } else {
            yPosition = descriptionTextView.frame.origin.y
            objectHeight = descriptionTextView.frame.size.height
        }
        let distanceToBottom = self.view.frame.size.height - yPosition - objectHeight
        let collapseSpace = keyboardHeight - distanceToBottom

        if collapseSpace < 0 {
            // no collapse
            return
        }

        // set new offset for scroll view
        UIView.animate(withDuration: 0.3, animations: {
            // scroll to the position above keyboard 10 points
            self.view.frame = CGRect(x: 0, y: 0 - (collapseSpace + 50), width: self.view.bounds.width, height: self.view.bounds.height)
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        }, completion: nil)
        UIView.animate(withDuration: 0.3) {
            self.isKeyboardHidden = true
            self.activeTextField = nil
        }
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.downloadPhotos { (isReady) in
            if isReady {
                self.titleTextField.text = self.viewModel.getAdvertTitle()
                self.advertImageView.image = self.viewModel.getAdvertImage()
                self.descriptionTextView.text = self.viewModel.getAdvertDescription()
                self.urlStringTextField.text = self.viewModel.getAdvertUrlString()
                self.descriptionTextView.textColor = .black
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
    
    func designScreenElements() {
        DesignService.setAdminGradient(for: view)
        advertImageView.layer.cornerRadius = 15
        descriptionTextView.layer.cornerRadius = 15
        DesignService.designBlueButton(uploadButton)
        DesignService.designRedButton(deleteButton)
        
        if isCreating {
            deleteButton.isHidden = true
        }
    }
    
    private func setUpUsersImage() {
        advertImageView.layer.cornerRadius = 15
        advertImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePickingPhoto)))
        advertImageView.isUserInteractionEnabled = true
    }
    
    private func presentNonActionAlert(title: String, message: String) {
        let testAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Понятно", style: .default, handler: nil)
        testAlertController.addAction(ok)
        self.present(testAlertController, animated: true)
    }
    
    @objc private func handlePickingPhoto() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: false)
    }
    
    @IBAction func uploadTapped(_ sender: UIButton) {
        showLoadingScreen()
        var newAdvert = Advert()
        newAdvert.name = titleTextField.text
        newAdvert.urlString = urlStringTextField.text
        newAdvert.describingText = descriptionTextView.text
        viewModel.uploadAdvert(newAdvert) { (error) in
            self.hideLodingScreen()
            if error == nil {
                self.advertUpdater?.updateAdverts(mode: self.isCreating ? .add : .edit, advertData: self.viewModel.getAdvert(), oldName: self.viewModel.getOldName())
                Animations.swipeViewController(.fromLeft, for: self.view)
                self.dismiss(animated: true)
            } else {
                self.presentNonActionAlert(title: "Не удалось загрузить", message: error ?? "")
            }
        }
    }
    
    @IBAction func deleteTapped(_ sender: UIButton) {
        showLoadingScreen()
        viewModel.deleteAdvert { (error) in
            self.hideLodingScreen()
            if error == nil {
                self.advertUpdater?.updateAdverts(mode: .delete, advertData: self.viewModel.getAdvert(), oldName: nil)
                Animations.swipeViewController(.fromLeft, for: self.view)
                self.dismiss(animated: true)
            } else {
                self.presentNonActionAlert(title: "Не удалось удалить", message: error ?? "")
            }
        }
    }
}

extension AdminAdvertDetailViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
}

extension AdminAdvertDetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Описание..."
            textView.textColor = UIColor.lightGray
        }
    }
}

extension AdminAdvertDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let originalImage = info[.originalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            advertImageView.image = selectedImage
            if let uploadData = selectedImage.pngData() {
                viewModel.updatePhotoData(with: uploadData)
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
