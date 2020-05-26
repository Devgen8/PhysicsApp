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
        
        let mixesViewController = MixesViewController()
        let mixItem = UITabBarItem(title: "Подборка", image: #imageLiteral(resourceName: "person1x").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "growth1x").withRenderingMode(.alwaysOriginal))
        mixItem.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont, NSAttributedString.Key.foregroundColor: selectedTitleColor], for: .selected)
        mixItem.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont, NSAttributedString.Key.foregroundColor: normalTitleColor], for: .normal)
        mixesViewController.tabBarItem = mixItem
        
        let battleItem = UITabBarItem(title: "Битва", image: #imageLiteral(resourceName: "sword1x").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "war1x").withRenderingMode(.alwaysOriginal))
        battleItem.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont, NSAttributedString.Key.foregroundColor: selectedTitleColor], for: .selected)
        battleItem.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont, NSAttributedString.Key.foregroundColor: normalTitleColor], for: .normal)
        let battleViewController = BattleViewController()
        battleViewController.tabBarItem = battleItem
        
        let trainerItem = UITabBarItem(title: "ТРЕНАЖЕР", image: #imageLiteral(resourceName: "картинка тренажер экран 9").withRenderingMode(.alwaysOriginal), selectedImage: #imageLiteral(resourceName: "картинка тренажер экран 9").withRenderingMode(.alwaysOriginal))
        trainerItem.setTitleTextAttributes([NSAttributedString.Key.font: selectedTitleFont, NSAttributedString.Key.foregroundColor: selectedTitleColor], for: .selected)
        trainerItem.setTitleTextAttributes([NSAttributedString.Key.font: normalTitleFont, NSAttributedString.Key.foregroundColor: normalTitleColor], for: .normal)
        let trainerViewController = TrainerViewController()
        trainerViewController.tabBarItem = trainerItem
        
        viewControllers = [trainerViewController]
    }
    
    func designTabBar() {
        tabBar.tintColor = .clear
        tabBar.backgroundImage = UIImage()
    }
    
//    func setupTabBarItems() {
//        let homeViewController = UINavigationController(rootViewController: HomeViewController())
//        homeViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "house").withRenderingMode(.alwaysOriginal), tag: 0)
//        homeViewController.navigationBar.topItem?.title = "Home"
//
//        let recipesViewController = UINavigationController(rootViewController: RecipesViewController())
//        recipesViewController.tabBarItem = UITabBarItem(title: "", image:  #imageLiteral(resourceName: "recipe").withRenderingMode(.alwaysOriginal), tag: 1)
//        recipesViewController.navigationBar.topItem?.title = "Recipes"
//
//        let shoppingListViewController = UINavigationController(rootViewController: ShoppingListViewController())
//        shoppingListViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "checklist").withRenderingMode(.alwaysOriginal), tag: 2)
//        shoppingListViewController.navigationBar.topItem?.title = "Shopping list"
//
//        let profileViewController = UINavigationController(rootViewController: ProfileViewController())
//        profileViewController.tabBarItem = UITabBarItem(title: "", image: #imageLiteral(resourceName: "user").withRenderingMode(.alwaysOriginal), tag: 3)
//        profileViewController.navigationBar.topItem?.title = "Profile"
//
//        viewControllers = [homeViewController, recipesViewController, shoppingListViewController, profileViewController]
//    }
}
