//
//  ChooseTestsNameViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 04.09.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import Lottie

class ChooseTestsNameViewController: UIViewController {

    @IBOutlet weak var testNamesTableView: UITableView!
    var loaderView = AnimationView()
    
    var viewModel = ChooseTestNameViewModel()
    var testNameUpdater: TestNameUpdater?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testNamesTableView.dataSource = self
        testNamesTableView.delegate = self
        DesignService.setAdminGradient(for: view)
        prepareData()
    }
    
    func prepareData() {
        showLoadingScreen()
        viewModel.getTestNames { (isReady) in
            if isReady {
                self.testNamesTableView.reloadData()
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
}

extension ChooseTestsNameViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.getTestsNumber()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        
        cell.themeName.text = viewModel.getTestName(for: indexPath.row)
        return cell
    }
}

extension ChooseTestsNameViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        Animations.swipeViewController(.fromLeft, for: view)
        dismiss(animated: false)
        testNameUpdater?.setSelectedTestName(viewModel.getTestName(for: indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
