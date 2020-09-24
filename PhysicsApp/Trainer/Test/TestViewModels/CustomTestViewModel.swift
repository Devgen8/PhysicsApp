//
//  CustomTestViewModel.swift
//  PhysicsApp
//
//  Created by Evgeny Kamaev on 11.05.2020.
//  Copyright © 2020 Devgen. All rights reserved.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class CustomTestViewModel: TestViewModel {
    
    //MARK: Fields
    
    private var tasks = [TaskModel]()
    private var wrightAnswers = [String:(String?, Bool?)]()
    private var timeTillEnd = 14100
    private let trainerReference = Firestore.firestore().collection("trainer")
    private let userReference = Firestore.firestore().collection("users")
    
    var name = ""
    var testAnswers = [String : String]()
    
    //MARK: Interface
    
    func getTestTasks(completion: @escaping (Bool) -> ()) {
        completion(true)
//        tasks = []
//        let dateFormater = DateFormatter()
//        dateFormater.dateFormat = "dd-MM-yyyy HH:mm:ss"
//        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
//            do {
//                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
//                let result = try context.fetch(fechRequest)
//                let trainer = result.first
//
//                let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
//                let userResult = try context.fetch(userFetchRequest)
//
//                for taskNumber in 1...32 {
//                    var unsolvedTasks = [String]()
//                    var solvedTasks = [String]()
//                    if !userResult.isEmpty {
//                        let user = userResult.first
//                        unsolvedTasks = (user?.solvedTasks as! StatusTasks).unsolvedTasks["Задание №\(taskNumber)"] ?? []
//                        solvedTasks = (user?.solvedTasks as! StatusTasks).solvedTasks["Задание №\(taskNumber)"] ?? []
//                    }
//                    var isTaskAdded = false
//                    if let egeTasks = trainer?.egeTasks {
//                        if let particularEgeTask = egeTasks.first(where: { ($0 as! EgeTask).name == "Задание №\(taskNumber)" }) as? EgeTask {
//                            for probableTask in particularEgeTask.tasks ?? NSOrderedSet() {
//                                if !unsolvedTasks.contains((probableTask as! TaskData).name ?? "") && !solvedTasks.contains((probableTask as! TaskData).name ?? "") {
//                                    let newTask = convertTasksDataToTask(probableTask as! TaskData)
//                                    if newTask.image == nil {
//                                        self.downloadPhotos(newTask) { (taskWithPhoto) in
//                                            newTask.image = taskWithPhoto.image
//                                            newTask.taskDescription = taskWithPhoto.taskDescription
//                                            self.tasks.append(newTask)
//                                        }
//                                    } else {
//                                        tasks.append(newTask)
//                                    }
//                                    isTaskAdded = true
//                                    break
//                                }
//                            }
//                            if !isTaskAdded {
//                                if particularEgeTask.tasks?.count == 0, let numberOfTasks = (particularEgeTask.themes as? ThemesInEgeTask)?.egeTaskThemes.count {
//                                    var lookingNumber = 0
//                                    for number in 1...numberOfTasks {
//                                        if !unsolvedTasks.contains("Задание №\(taskNumber).\(number)") && !solvedTasks.contains("Задание №\(taskNumber).\(number)") {
//                                            lookingNumber = number
//                                        }
//                                    }
//                                    if lookingNumber == 0 {
//                                        lookingNumber = Int.random(in: 1...numberOfTasks)
//                                    }
//                                    getTasksFromFirestore(taskName: "Задание №\(taskNumber).\(lookingNumber)") { [weak self] (newTask) in
//                                        guard let `self` = self else {
//                                            return
//                                        }
//                                        self.tasks.append(newTask)
//                                        if self.tasks.count == 32 {
//                                            self.tasks = self.tasks.sorted(by: { self.getTaskPosition(taskName: $0.name ?? "") < self.getTaskPosition(taskName: $1.name ?? "") })
//                                            self.name = "Мой пробник \(dateFormater.string(from: Date()))"
//                                            self.createPlaceholdersForAnswers()
//                                            self.fillInWrightAnswers()
//                                            self.saveNewTestInCoreData()
//                                            completion(true)
//                                        }
//                                    }
//                                } else {
//                                    let numberOfTasks = particularEgeTask.tasks?.count ?? 0
//                                    let randomTaskNumber = Int.random(in: 0..<numberOfTasks)
//                                    let newTask = convertTasksDataToTask(particularEgeTask.tasks?[randomTaskNumber] as! TaskData)
//                                    if newTask.image == nil {
//                                        self.downloadPhotos(newTask) { (taskWithPhoto) in
//                                            newTask.image = taskWithPhoto.image
//                                            newTask.taskDescription = taskWithPhoto.taskDescription
//                                            self.tasks.append(newTask)
//                                        }
//                                    } else {
//                                        tasks.append(newTask)
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//                if tasks.count == 32 {
//                    self.tasks = self.tasks.sorted(by: { self.getTaskPosition(taskName: $0.name ?? "") < self.getTaskPosition(taskName: $1.name ?? "") })
//                    self.name = "Мой пробник \(dateFormater.string(from: Date()))"
//                    self.createPlaceholdersForAnswers()
//                    self.fillInWrightAnswers()
//                    self.saveNewTestInCoreData()
//                    completion(true)
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
    }
    
    func getTasksNumber() -> Int {
        return tasks.count
    }
    
    func getTestName() -> String {
        return name
    }
    
    func saveUsersProgress(with time: Int) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                if trainer?.tests?.first(where: { ($0 as! Test).name == name }) != nil {
                    (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).time = Int64(time)
                    (trainer?.tests?.first(where: { ($0 as! Test).name == name }) as! Test).testObject = TestObject(testTasks: tasks, usersAnswers: testAnswers)
                    
                    try context.save()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func isTestFinished() -> Bool {
        let finishedTests = UserDefaults.standard.value(forKey: "finishedTests") as? [String] ?? []
        return finishedTests.contains(name)
    }
    
    func transportData(to viewModel: CPartTestViewModel, with time: Int) {
        viewModel.setTimeTillEnd(time)
        viewModel.setwrightAnswers(wrightAnswers)
        viewModel.setTestAnswers(testAnswers)
        var tasksImages = [String:UIImage]()
        for task in tasks {
            tasksImages[task.name ?? ""] = task.image
        }
        viewModel.setTasksImages(tasksImages)
        viewModel.setName(name)
        viewModel.testAnswersUpdater = self
        viewModel.setTasks(tasks)
    }
    
    func getPhotoForTask(_ index: Int) -> UIImage {
        return tasks[index].image ?? UIImage()
    }
    
    func getTimeTillEnd() -> Double {
        return Double(timeTillEnd)
    }
    
    func getFirstQuestionAnswer() -> String? {
        return testAnswers[tasks[0].name ?? ""]
    }
    
    func getUsersAnswer(for taskIndex: Int) -> String {
        return testAnswers[tasks[taskIndex].name ?? ""] ?? ""
    }
    
    func writeAnswerForTask(_ index: Int, with answer: String) {
        testAnswers[tasks[index].name ?? ""] = answer
    }
    
    func getNextTaskIndex(after index: Int) -> Int {
        return index + 1
    }
    
    func getMaxRatio() -> CGFloat {
        var maxRatio: CGFloat = 0
        for task in tasks {
            if (task.image?.size.height ?? 0) / (task.image?.size.width ?? 1) > maxRatio {
                maxRatio = (task.image?.size.height ?? 0) / (task.image?.size.width ?? 1)
            }
        }
        return maxRatio
    }
    
    func getTimeString(from allSeconds: Int) -> String {
        var hours = "\(allSeconds / 3600)"
        if hours.count == 1 {
            hours = "0" + hours
        }
        var minutes = "\((allSeconds % 3600) / 60)"
        if minutes.count == 1 {
            minutes = "0" + minutes
        }
        var seconds = "\((allSeconds % 3600) % 60)"
        if seconds.count == 1 {
            seconds = "0" + seconds
        }
        return "\(hours) : \(minutes) : \(seconds)"
    }
    
    func setTasks(_ newTasks: [TaskModel]) {
        tasks = newTasks
    }
    
    func setTimeTillEnd(_ newTime: Int) {
        timeTillEnd = newTime
    }
    
    func setWrightAnswers(_ newWrightAnswers: [String:(String?, Bool?)]) {
        wrightAnswers = newWrightAnswers
    }
    
    func setTestName(_ newName: String) {
        name = newName
    }
    
    func setTestAnswers(_ newTestAnswers: [String:String]) {
        testAnswers = newTestAnswers
    }
    
    //MARK: Private section
    
    private func createPlaceholdersForAnswers() {
        for task in tasks {
            testAnswers[task.name ?? ""] = ""
        }
    }
    
    private func fillInWrightAnswers() {
        for task in tasks {
            wrightAnswers[task.name ?? ""] = (task.wrightAnswer, task.alternativeAnswer)
        }
    }
    
    private func getTaskPosition(taskName: String) -> Int {
        let (themeName, _) = NamesParser.getTaskLocation(taskName: taskName)
        if let range = themeName.range(of: "№") {
            let numberString = String(themeName[range.upperBound...])
            return Int(numberString) ?? 0
        }
        return 0
    }
    
    private func convertTasksDataToTask(_ taskData: TaskData) -> TaskModel {
        let chosenTask = TaskModel()
        chosenTask.name = taskData.name
        chosenTask.alternativeAnswer = taskData.alternativeAnswer
        chosenTask.wrightAnswer = taskData.wrightAnswer
        chosenTask.serialNumber = Int(taskData.serialNumber)
        chosenTask.image = UIImage(data: taskData.image ?? Data())
        chosenTask.taskDescription = UIImage(data: taskData.taskDescription ?? Data())
        return chosenTask
    }
    
    // Firestore and Storage
    
    func getTasksFromFirestore(taskName lookingName: String, completion: @escaping (TaskModel) -> ()) {
        let (themeName, serialNumber) = NamesParser.getTaskLocation(taskName: lookingName)
        trainerReference.document(themeName).collection("tasks").whereField("serialNumber", isEqualTo: Int(serialNumber) ?? 1).getDocuments { (snapshot, error) in
            guard error == nil else {
                print("Error reading tasks: \(String(describing: error?.localizedDescription))")
                return
            }
            if let document = snapshot?.documents.first {
                let task = TaskModel()
                task.serialNumber = document.data()[Task.serialNumber.rawValue] as? Int
                task.wrightAnswer = document.data()[Task.wrightAnswer.rawValue] as? String
                task.alternativeAnswer = document.data()[Task.alternativeAnswer.rawValue] as? Bool
                task.succeded = document.data()[Task.succeded.rawValue] as? Int
                task.failed = document.data()[Task.failed.rawValue] as? Int
                task.name = lookingName
                self.downloadPhotos(task) { (newTask) in
                    completion(newTask)
                }
            }
        }
    }
    
    func downloadPhotos(_ foundTask: TaskModel, completion: @escaping (TaskModel) -> ()) {
        let (themeName, taskNumber) = NamesParser.getTaskLocation(taskName: foundTask.name ?? "")
        let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber).png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { [weak self] data, error in
            guard let `self` = self, error == nil else {
                print("Error downloading images: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                foundTask.image = image
                self.downloadDescription(foundTask) { (newTask) in
                    completion(newTask)
                }
            }
        }
    }
    
    func downloadDescription(_ foundTask: TaskModel, completion: @escaping (TaskModel) -> ()) {
        let (themeName, taskNumber) = NamesParser.getTaskLocation(taskName: foundTask.name ?? "")
        let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber)description.png")
        imageRef.getData(maxSize: 4 * 2048 * 2048) { (data, error) in
            guard error == nil else {
                print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                return
            }
            if let data = data, let image = UIImage(data: data) {
                foundTask.taskDescription = image
                completion(foundTask)
            }
        }
    }
    
    // Core Data
    
    private func saveNewTestInCoreData() {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let newTest = Test(context: context)
                let allTests = trainer?.tests?.mutableCopy() as! NSMutableSet
                newTest.name = name
                newTest.time = Int64(timeTillEnd)
                newTest.testObject = TestObject(testTasks: tasks, usersAnswers: testAnswers)
                allTests.add(newTest)
                trainer?.tests = allTests
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
//    private func saveTaskToCoreData(_ foundTasks: TaskModel) {
//        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
//            do {
//                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
//                let result = try context.fetch(fechRequest)
//                let trainer = result.first
//                let newTasks = NSMutableOrderedSet()
//                for task in foundTasks {
//                    let newTask = TaskData(context: context)
//                    if let alternativeAnswer = task.alternativeAnswer {
//                        newTask.alternativeAnswer = alternativeAnswer
//                    }
//                    if let wrightAnswer = task.wrightAnswer {
//                        newTask.wrightAnswer = wrightAnswer
//                    }
//                    if let serialNumber = task.serialNumber {
//                        newTask.serialNumber = Int16(serialNumber)
//                    }
//                    newTask.image = task.image?.pngData()
//                    newTask.taskDescription = task.taskDescription?.pngData()
//                    newTask.name = task.name
//                    newTasks.add(newTask)
//                }
//                let (theme, _) = NamesParser.getTaskLocation(taskName: foundTasks[0].name ?? "")
//                (trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks = newTasks
//
//                try context.save()
//            } catch {
//                print(error.localizedDescription)
//            }
//        }
//    }
    
    private func deleteData() {
        var newAnswers = [String:String]()
        for index in 1...32 {
            newAnswers["Задание №\(index)"] = ""
        }
        testAnswers = newAnswers
        timeTillEnd = 14100
    }
    
    // Unused methods
    
    func setTaskImages(_ newTaskImages: [String:UIImage]) { }
    
    func setTaskDescriptions(_ newTaskDescriptions: [String:UIImage]) { }
    
    func getCompletion() -> Float { return 0 }
}

extension CustomTestViewModel: TestAnswersUpdater {
    func deleteTestsAnswers() {
        deleteData()
    }
}
