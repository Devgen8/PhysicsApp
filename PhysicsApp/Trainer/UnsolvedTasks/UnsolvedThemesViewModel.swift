//
//  UnsolvedThemesViewModel.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import Foundation

class UnsolvedThemesViewModel {
    var unsolvedTasks = [String:[String]]()
    var themesUnsolvedTasks = [String:[String]]()
    var unsolvedTasksUpdater: UnsolvedTaskUpdater?
    var sortType: TasksSortType?
}

extension UnsolvedThemesViewModel: DataConstructer {
    
    func getItemsCount() -> Int {
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
    
    func constructData(for row: Int) -> String {
        if let sort = sortType {
            if sort == .tasks {
                let theme = Array<String>(unsolvedTasks.keys)[row]
                return "\(theme)(\(unsolvedTasks[theme]?.count ?? 0))"
            }
            if sort == .themes {
                let theme = Array<String>(themesUnsolvedTasks.keys)[row]
                return "\(theme)(\(themesUnsolvedTasks[theme]?.count ?? 0))"
            }
        }
        return ""
    }
}

extension UnsolvedThemesViewModel: UnsolvedTaskUpdater {
    func updateUnsolvedTasks(with unsolvedTasks: [String : [String]], and solvedTasks: [String : [String]]?) {
        self.unsolvedTasks = unsolvedTasks
    }
}
