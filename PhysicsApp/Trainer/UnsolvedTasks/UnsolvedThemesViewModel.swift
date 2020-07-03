//
//  UnsolvedThemesViewModel.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit
import CoreData

class UnsolvedThemesViewModel {
    
    //MARK: Fields
    
    private var themesUnsolvedTasks = [String:[String]]()
    private var sortType: TasksSortType?
    private var themesKeys = [String]()
    
    var unsolvedTasks = [String:[String]]()
    var unsolvedTasksUpdater: UnsolvedTaskUpdater?
    
    //MARK: Interface
    
    func setThemesUnsolvedTasks(_ newThemes: [String:[String]]) {
        themesUnsolvedTasks = newThemes
    }
    
    func setSortType(_ newSortType: TasksSortType) {
        sortType = newSortType
    }
    
    func transportData(to viewModel: TasksListViewModel, from index: Int) {
        viewModel.setTheme(themesKeys[index])
        viewModel.setUnsolvedTasks(unsolvedTasks)
        viewModel.setThemeUnsolvedTasks(themesUnsolvedTasks)
        viewModel.setLookingForUnsolvedTasks(true)
        viewModel.unsolvedTaskUpdater = self
        viewModel.setSortType(sortType)
        viewModel.setThemeTasks(themesUnsolvedTasks[themesKeys[index]] ?? [])
    }
}

extension UnsolvedThemesViewModel: DataConstructer {
    
    func getItemsCount() -> Int {
        sortThemes()
        if let sort = sortType {
            if sort == .tasks {
                for themeName in unsolvedTasks.keys {
                    if unsolvedTasks[themeName]?.count == 0 {
                        unsolvedTasks[themeName] = nil
                    }
                }
                return unsolvedTasks.keys.count
            }
            if sort == .themes {
                for themeName in themesUnsolvedTasks.keys {
                    if themesUnsolvedTasks[themeName]?.count == 0 {
                        themesUnsolvedTasks[themeName] = nil
                    }
                }
                return themesUnsolvedTasks.keys.count
            }
        }
        return 0
    }
    
    func sortThemes() {
        var currentUnsolvedTasks = [String:[String]]()
        if let sort = sortType {
            if sort == .tasks {
                currentUnsolvedTasks = unsolvedTasks
            }
            if sort == .themes {
                currentUnsolvedTasks = themesUnsolvedTasks
            }
        }
        themesKeys = currentUnsolvedTasks.keys.sorted(by: {
            if let sort = sortType, sort == .tasks {
                return getTaskPosition(taskName: $0) < getTaskPosition(taskName: $1)
            }
            if let sort = sortType, sort == .themes {
                return $0 > $1
            }
            return true
        })
    }
    
    func getTaskPosition(taskName: String) -> Int {
        let (themeName, _) = NamesParser.getTaskLocation(taskName: taskName)
        if let range = themeName.range(of: "№") {
            let numberString = String(themeName[range.upperBound...])
            return Int(numberString) ?? 0
        }
        return 0
    }
    
    func constructData(for row: Int) -> String {
        if let sort = sortType {
            if sort == .tasks {
                let theme = themesKeys[row]
                return "\(theme)(\(unsolvedTasks[theme]?.count ?? 0))"
            }
            if sort == .themes {
                let theme = themesKeys[row]
                return "\(theme)(\(themesUnsolvedTasks[theme]?.count ?? 0))"
            }
        }
        return ""
    }
}

extension UnsolvedThemesViewModel: UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String : [String]], and solvedTasks: [String : [String]]?) {
        self.unsolvedTasks = unsolvedTasks
        if let sort = sortType {
            if sort == .themes {
                var realUnsolvedTasks = [String:[String]]()
                if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
                    let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                    
                    do {
                        if let user = try context.fetch(userFetchRequest).first {
                            let statusTasks = user.solvedTasks as! StatusTasks
                            realUnsolvedTasks = statusTasks.unsolvedTasks
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    var newThemesUnsolvedTasks = [String:[String]]()
                    for themeTasksPair in themesUnsolvedTasks {
                        let key = themeTasksPair.key
                        for taskName in themesUnsolvedTasks[key] ?? [] {
                            let (taskNumber, _) = NamesParser.getTaskLocation(taskName: taskName)
                            if realUnsolvedTasks[taskNumber]?.contains(taskName) ?? false {
                                if newThemesUnsolvedTasks[key] == nil {
                                    newThemesUnsolvedTasks[key] = [taskName]
                                } else {
                                    newThemesUnsolvedTasks[key]?.append(taskName)
                                }
                            }
                        }
                    }
                    themesUnsolvedTasks = newThemesUnsolvedTasks
                }
            }
        }
    }
}
