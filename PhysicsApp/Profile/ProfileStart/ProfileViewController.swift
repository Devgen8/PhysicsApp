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
import AuthenticationServices
import CryptoKit
import Lottie

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
    @IBOutlet weak var tiktokButton: UIButton!
    @IBOutlet weak var appleRegistartionButton: ASAuthorizationAppleIDButton!
    private var loaderView = AnimationView()
    @IBOutlet weak var signInAskingStackView: UIStackView!
    
    private var isDataReady = false
    var viewModel = ProfileViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        designScreenElements()
        prepareData()
        setUpUsersImage()
        prepareAppleSignInButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let sdkInstance = VKSdk.initialize(withAppId: "7379630")
        sdkInstance?.register(self)
        sdkInstance?.uiDelegate = self
    }
    
    func prepareData() {
        showLoadingScreen()
        isDataReady = false
        viewModel.getUsersData { [weak self] (user) in
            if let `self` = self, let user = user {
                self.nameLabel.text = user.name
                if self.isDataReady == false {
                    self.isDataReady = true
                } else {
                    self.hideLodingScreen()
                }
            } else {
                self?.hideLodingScreen()
            }
        }
        viewModel.getUsersPhoto { [weak self] (photo) in
            if let `self` = self, let photo = photo {
                self.userImage.image = photo
                if self.isDataReady == false {
                    self.isDataReady = true
                } else {
                    self.hideLodingScreen()
                }
            } else {
                self?.hideLodingScreen()
            }
        }
        if UserStatsCounter.shared.nextValue == 0 {
            ratingLabel.text = "Ожидаемый балл на ЕГЭ: \(UserStatsCounter.shared.srEGE)"
        } else {
            ratingLabel.text = "Ожидаемый балл на ЕГЭ: \(UserStatsCounter.shared.srEGE) - \(UserStatsCounter.shared.nextValue)"
        }
    }
    
    func prepareAppleSignInButton() {
        appleRegistartionButton.addTarget(self, action: #selector(signInWithAppleTapped), for: .touchUpInside)
    }
    
    @objc func signInWithAppleTapped() {
        let dataRequest = ASAuthorizationAppleIDProvider().createRequest()
        dataRequest.requestedScopes = [.fullName]
        let nonce = randomNonceString()
        dataRequest.nonce = sha256(nonce)
        currentNonce = nonce
        let authController = ASAuthorizationController(authorizationRequests: [dataRequest])
        authController.delegate = self
        authController.presentationContextProvider = self
        authController.performRequests()
    }
    
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
    
    // Unhashed nonce.
    fileprivate var currentNonce: String?

    @available(iOS 13, *)
    func startSignInWithAppleFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }

    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
      }.joined()

      return hashString
    }
    
    func designScreenElements() {
        DesignService.setWhiteBackground(for: view)
        DesignService.designCloseButton(closeButton)
        if Auth.auth().currentUser?.uid == nil {
            DesignService.designBlueButton(logOutButton)
            logOutButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: 2, bottom: 10, right: 2)
            logOutButton.imageView?.contentMode = .scaleAspectFit
            logOutButton.setImage(#imageLiteral(resourceName: "картинка вк экран 11"), for: .normal)
            appleRegistartionButton.layer.borderWidth = 1
            appleRegistartionButton.layer.borderColor = UIColor.black.cgColor
            appleRegistartionButton.layer.cornerRadius = 15
            
            userImage.image = #imageLiteral(resourceName: "photo-placeholder")
            nameLabel.text = ""
        } else {
            DesignService.designRedButton(logOutButton)
            logOutButton.setTitle("ВЫЙТИ", for: .normal)
            logOutButton.setImage(nil, for: .normal)
            logOutButton.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 16)
            appleRegistartionButton.isHidden = true
        }
        DesignService.designBlueButton(testsHistoryButton)
        DesignService.designBlueButton(supportButton)
        
        ringViewAroundPhoto.layer.cornerRadius = ringViewAroundPhoto.frame.height * 0.5
        ringViewAroundPhoto.layer.borderWidth = 1
        ringViewAroundPhoto.layer.borderColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        
        userImage.layer.cornerRadius = userImage.frame.height * 0.5
        
        if Auth.auth().currentUser?.uid != nil {
            signInAskingStackView.isHidden = true
        }
    }
    
    @IBAction func logOutTapped(_ sender: UIButton) {
        if logOutButton.titleLabel?.text == "ВЫЙТИ" {
            showExitAlertController()
        } else {
            let sdkInstance = VKSdk.initialize(withAppId: "7379630")
                    sdkInstance?.register(self)
                    sdkInstance?.uiDelegate = self
                    let scope = ["photos"]
                    VKSdk.wakeUpSession(scope, complete: { (state, error) in
                        VKSdk.forceLogout()
                        VKSdk.authorize(scope, with: .disableSafariController)
                        if error != nil {
                            if error != nil {
                                print(error!)
                            }
                        }
                    })
        }
    }
    
    @IBAction func signInInfoTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Зачем мне регистрация?", message: "Зарегистрируйся, чтобы не потерять данные, или войди в учетную запись, чтобы восстановить старые. ", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Хорошо", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func showExitAlertController() {
        let alertController = UIAlertController(title: "Вы уверены?", message: "Выход из аккаунта удалит прогресс приложения с телефона, но Вы всегда сможете его восстановить, авторизовавшись", preferredStyle: .alert)
        let exitAction = UIAlertAction(title: "Выйти", style: .destructive) { (_) in
            self.viewModel.eraseUserDefaults()
            self.viewModel.logOut()
            let chooseSubjectViewController = ChooseSubjectViewController()
            chooseSubjectViewController.modalPresentationStyle = .fullScreen
            self.present(chooseSubjectViewController, animated: true)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(exitAction)
        present(alertController, animated: true)
    }
    
    @IBAction func socialNetworkTapped(_ sender: UIButton) {
        var urlString = ""
        switch sender {
        case instagramButton: urlString = "instagram://user?username=egenewton"
        case vkButton: urlString = "vk://vk.com/ege_newton"
        case youtubeButton: urlString = "youtube://youtube.com/channel/UCOX_zZTKMv7Y6mrBKeTSsyw"
        case telegramButton: urlString = "tg://resolve?domain=egenewton"
        case tiktokButton: urlString = "tiktok://vm.tiktok.com/ZSPNPrwK"
        default: break
        }
        if let appURL = URL(string: urlString), UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            switch sender {
            case instagramButton: urlString = "https://instagram.com/egenewton"
            case vkButton: urlString = "https://vk.com/ege_newton"
            case youtubeButton: urlString = "https://www.youtube.com/channel/UCOX_zZTKMv7Y6mrBKeTSsyw"
            case telegramButton: urlString = "https://t.me/egenewton"
            case tiktokButton: urlString = "https://vm.tiktok.com/ZSPNPrwK"
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
    
    private func showError(_ error: String) {
        let alertController = UIAlertController(title: "Ошибка авторизации", message: error, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func createBlurEffect() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView.tag = 50
        blurEffectView.backgroundColor = .white
        view.addSubview(blurEffectView)
    }
    
    private func setAnimation() {
        loaderView.animation = Animation.named("lf30_editor_cg3gHF")
        loaderView.loopMode = .loop
        loaderView.isHidden = false
        view.addSubview(loaderView)
        loaderView.translatesAutoresizingMaskIntoConstraints = false
        loaderView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loaderView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loaderView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        loaderView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        view.bringSubviewToFront(loaderView)
        loaderView.play()
    }
    
    private func showLoadingScreen() {
        createBlurEffect()
        setAnimation()
    }
    
    private func hideLodingScreen() {
        loaderView.isHidden = true
        view.viewWithTag(50)?.removeFromSuperview()
        designScreenElements()
    }
    
    @objc private func handlePickingPhoto() {
        if Auth.auth().currentUser?.uid != nil {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        }
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

extension ProfileViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: login callback was recived, but no request was sent")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch user token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            Auth.auth().signIn(with: credential) { [weak self] (authDataResult, error) in
                if let `self` = self {
                    self.showLoadingScreen()
                    self.viewModel.saveUsersName(appleIDCredential.fullName?.givenName ?? "") { (isReady) in
                        self.hideLodingScreen()
                        self.prepareData()
                    }
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        showError(error.localizedDescription)
    }
}

extension ProfileViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}

extension ProfileViewController: VKSdkDelegate {
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        showLoadingScreen()
        if result.token != nil && result.error == nil {
            viewModel.authUser(with: result) { (error, isAdmin) in
                guard error == nil else {
                    self.showError(error ?? "")
                    return
                }
                if isAdmin {
                    let rootViewController = MainAdminViewController()
                    rootViewController.modalPresentationStyle = .fullScreen
                    self.hideLodingScreen()
                    self.present(rootViewController, animated: true)
                } else {
                    self.viewModel.saveUsersDataInFirestore(result)
                }
                self.hideLodingScreen()
                self.prepareData()
            }
        } else {
            showError("Не удалось авторизоваться")
            hideLodingScreen()
        }
    }
    
    func vkSdkUserAuthorizationFailed() {
        print("vkSdkUserAuthorizationFailed")
    }
}

extension ProfileViewController: VKSdkUIDelegate {
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true)
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        print("Not presenting")
    }
}
