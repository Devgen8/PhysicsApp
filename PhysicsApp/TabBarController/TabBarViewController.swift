//
//  TabBarViewController.swift
//  TrainingApp
//
//  Created by мак on 13/02/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.windows.first?.rootViewController = self
        setupTabBarItems()
        designTabBar()
    }
    
    func setupTabBarItems() {
        let normalTitleFont = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.regular)
        let selectedTitleFont = UIFont(name: "Montserrat-Regular", size: 12)
        
        let normalTitleColor = UIColor.black
        let selectedTitleColor = #colorLiteral(red: 0.118398197, green: 0.5486055017, blue: 0.8138075471, alpha: 1)
        
        let trainerItem = UITabBarItem(title: "ТРЕНАЖЕР", image: #imageLiteral(resourceName: "картинка тренажер экран 9").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "картинка тренажер экран 9").withRenderingMode(.alwaysOriginal))
        trainerItem.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont ?? UIFont.systemFont(ofSize: 12), NSAttributedString.Key.foregroundColor: selectedTitleColor], for: .selected)
        trainerItem.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont, NSAttributedString.Key.foregroundColor: normalTitleColor], for: .normal)
        let trainerViewController = TrainerViewController()
        trainerViewController.tabBarItem = trainerItem
        
        viewControllers = [trainerViewController]
    }
    
    func designTabBar() {
        tabBar.tintColor = .clear
        tabBar.backgroundImage = UIImage()
    }
}
