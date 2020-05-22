//
//  ChooseThemeViewController.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 22.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit

class ChooseThemeViewController: UIViewController {

    @IBOutlet weak var themesTableView: UITableView!
    
    var selectedThemes = [String]()
    var selectedThemesUpdater: SelectedThemesUpdater?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themesTableView.delegate = self
        themesTableView.dataSource = self
        DesignService.setAdminGradient(for: view)
    }
    
    @IBAction func backTapped(_ sender: UIButton) {
        Animations.swipeViewController(.fromLeft, for: view)
        var newThemes = ""
        for theme in selectedThemes {
            newThemes += theme
        }
        selectedThemesUpdater?.updateTheme(with: newThemes)
        dismiss(animated: false)
    }
}

extension ChooseThemeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        EGEInfo.egeSystemThemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("ThemeTableViewCell", owner: self, options: nil)?.first as! ThemeTableViewCell
        
        cell.themeName.text = EGEInfo.egeSystemThemes[indexPath.row]
        if selectedThemes.contains(EGEInfo.egeSystemThemes[indexPath.row]) {
            cell.tickImage.image = #imageLiteral(resourceName: "checked")
        }
        return cell
    }
}

extension ChooseThemeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (tableView.cellForRow(at: indexPath) as! ThemeTableViewCell).tickImage?.image == #imageLiteral(resourceName: "checked") {
            (tableView.cellForRow(at: indexPath) as! ThemeTableViewCell).tickImage?.image = nil
            selectedThemes = selectedThemes.filter({ $0 != EGEInfo.egeSystemThemes[indexPath.row] })
        } else {
            (tableView.cellForRow(at: indexPath) as! ThemeTableViewCell).tickImage?.image = #imageLiteral(resourceName: "checked")
            selectedThemes.append(EGEInfo.egeSystemThemes[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
