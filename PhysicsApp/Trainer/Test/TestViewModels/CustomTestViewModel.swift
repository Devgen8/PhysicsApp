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
    
    var name = ""
    var testAnswers = [String : String]()
    var tasks = [TaskModel]()
    var wrightAnswers = [String:(Double?, Double?, String?)]()
    var timeTillEnd = 14100
    let trainerReference = Firestore.firestore().collection("trainer")
    let userReference = Firestore.firestore().collection("users")
    
    func getTestTasks(completion: @escaping (Bool) -> ()) {
        tasks = []
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd-MM-yyyy HH:mm:ss"
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                
                let userFetchRequest: NSFetchRequest<User> = User.fetchRequest()
                let userResult = try context.fetch(userFetchRequest)
                
                for taskNumber in 1...32 {
                    var unsolvedTasks = [String]()
                    var solvedTasks = [String]()
                    if !userResult.isEmpty {
                        let user = userResult.first
                        unsolvedTasks = (user?.solvedTasks as! StatusTasks).unsolvedTasks["Задание №\(taskNumber)"] ?? []
                        solvedTasks = (user?.solvedTasks as! StatusTasks).solvedTasks["Задание №\(taskNumber)"] ?? []
                    }
                    var isTaskAdded = false
                    if let egeTasks = trainer?.egeTasks {
                        if let particularEgeTask = egeTasks.first(where: { ($0 as! EgeTask).name == "Задание №\(taskNumber)" }) as? EgeTask {
                            for probableTask in particularEgeTask.tasks ?? NSOrderedSet() {
                                if !unsolvedTasks.contains((probableTask as! TaskData).name ?? "") && !solvedTasks.contains((probableTask as! TaskData).name ?? "") {
                                    tasks.append(convertTasksDataToTask(probableTask as! TaskData))
                                    isTaskAdded = true
                                    break
                                }
                            }
                            if !isTaskAdded {
                                if particularEgeTask.tasks?.count == 0 {
                                    getTasksFromFirestore(number: taskNumber) { [weak self] (newTask) in
                                        guard let `self` = self else {
                                            return
                                        }
                                        self.tasks.append(newTask)
                                        if self.tasks.count == 32 {
                                            self.tasks = self.tasks.sorted(by: { self.getTaskPosition(taskName: $0.name ?? "") < self.getTaskPosition(taskName: $1.name ?? "") })
                                            self.name = "Пробник \(dateFormater.string(from: Date()))"
                                            self.createPlaceholdersForAnswers()
                                            self.fillInWrightAnswers()
                                            self.saveNewTestInCoreData()
                                            completion(true)
                                        }
                                    }
                                } else {
                                    let numberOfTasks = particularEgeTask.tasks?.count ?? 0
                                    let randomTaskNumber = Int.random(in: 0..<numberOfTasks)
                                    tasks.append(convertTasksDataToTask(particularEgeTask.tasks?[randomTaskNumber] as! TaskData))
                                }
                            }
                        }
                    }
                }
                if tasks.count == 32 {
                    self.tasks = self.tasks.sorted(by: { self.getTaskPosition(taskName: $0.name ?? "") < self.getTaskPosition(taskName: $1.name ?? "") })
                    self.name = "Пробник \(dateFormater.string(from: Date()))"
                    self.createPlaceholdersForAnswers()
                    self.fillInWrightAnswers()
                    self.saveNewTestInCoreData()
                    completion(true)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func createPlaceholdersForAnswers() {
        for task in tasks {
            testAnswers[task.name ?? ""] = ""
        }
    }
    
    func fillInWrightAnswers() {
        for task in tasks {
            wrightAnswers[task.name ?? ""] = (task.wrightAnswer, task.alternativeAnswer, task.stringAnswer)
        }
    }
    
    func saveNewTestInCoreData() {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
    
    func getTaskPosition(taskName: String) -> Int {
        let (themeName, _) = getTaskLocation(taskName: taskName)
        if let range = themeName.range(of: "№") {
            let numberString = String(themeName[range.upperBound...])
            return Int(numberString) ?? 0
        }
        return 0
    }
    
    func convertTasksDataToTask(_ taskData: TaskData) -> TaskModel {
        let chosenTask = TaskModel()
        chosenTask.name = taskData.name
        chosenTask.alternativeAnswer = taskData.alternativeAnswer
        chosenTask.wrightAnswer = taskData.wrightAnswer
        chosenTask.serialNumber = Int(taskData.serialNumber)
        chosenTask.stringAnswer = taskData.stringAnswer
        chosenTask.image = UIImage(data: taskData.image ?? Data())
        chosenTask.taskDescription = UIImage(data: taskData.taskDescription ?? Data())
        return chosenTask
    }
    
    func getTasksFromFirestore(number: Int, completion: @escaping (TaskModel) -> ()) {
        trainerReference.document("Задание №\(number)").collection("tasks").getDocuments { (snapshot, error) in
            guard error == nil else {
                print("Error reading tasks: \(String(describing: error?.localizedDescription))")
                return
            }
            if let documents = snapshot?.documents {
                var foundTasks = [TaskModel]()
                for document in documents {
                    let task = TaskModel()
                    task.serialNumber = document.data()[Task.serialNumber.rawValue] as? Int
                    task.wrightAnswer = document.data()[Task.wrightAnswer.rawValue] as? Double
                    task.alternativeAnswer = document.data()[Task.alternativeAnswer.rawValue] as? Double
                    task.stringAnswer = document.data()[Task.wrightAnswer.rawValue] as? String
                    task.succeded = document.data()[Task.succeded.rawValue] as? Int
                    task.failed = document.data()[Task.failed.rawValue] as? Int
                    task.name = "Задание №\(number)" + "." + "\(task.serialNumber ?? 0)"
                    foundTasks.append(task)
                }
                self.downloadPhotos(foundTasks) { (fullTasks) in
                    completion(fullTasks[Int.random(in: 0..<fullTasks.count)])
                }
            }
        }
    }
    
    func downloadPhotos(_ foundTasks: [TaskModel], completion: @escaping ([TaskModel]) -> ()) {
        var count = 0
        for task in foundTasks {
            let (themeName, taskNumber) = getTaskLocation(taskName: task.name ?? "")
            let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber).png")
            imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] data, error in
                guard let `self` = self, error == nil else {
                    print("Error downloading images: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    foundTasks.first(where: { $0.name == task.name })?.image = image
                    count += 1
                }
                if count == foundTasks.count {
                    self.downloadDescription(foundTasks) { (foundTasks) in
                        completion(foundTasks)
                    }
                }
            }
        }
    }
    
    func downloadDescription(_ foundTasks: [TaskModel], completion: @escaping ([TaskModel]) -> ()) {
        var count = 0
        for task in foundTasks {
            let (themeName, taskNumber) = getTaskLocation(taskName: task.name ?? "")
            let imageRef = Storage.storage().reference().child("trainer/\(themeName)/task\(taskNumber)description.png")
            imageRef.getData(maxSize: 1 * 2048 * 2048) { [weak self] (data, error) in
                guard let `self` = self, error == nil else {
                    print("Error downloading descriptions: \(String(describing: error?.localizedDescription))")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    foundTasks.first(where: { $0.name == task.name })?.taskDescription = image
                    count += 1
                }
                if count == foundTasks.count {
                    self.saveTasksToCoreData(foundTasks)
                    completion(foundTasks)
                }
            }
        }
    }
    
    func saveTasksToCoreData(_ foundTasks: [TaskModel]) {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fechRequest: NSFetchRequest<Trainer> = Trainer.fetchRequest()
                let result = try context.fetch(fechRequest)
                let trainer = result.first
                let newTasks = NSMutableOrderedSet()
                for task in foundTasks {
                    let newTask = TaskData(context: context)
                    if let alternativeAnswer = task.alternativeAnswer {
                        newTask.alternativeAnswer = alternativeAnswer
                    }
                    if let wrightAnswer = task.wrightAnswer {
                        newTask.wrightAnswer = wrightAnswer
                    }
                    if let serialNumber = task.serialNumber {
                        newTask.serialNumber = Int16(serialNumber)
                    }
                    newTask.stringAnswer = task.stringAnswer
                    newTask.image = task.image?.pngData()
                    newTask.taskDescription = task.taskDescription?.pngData()
                    newTask.name = task.name
                    newTasks.add(newTask)
                }
                let (theme, _) = getTaskLocation(taskName: foundTasks[0].name ?? "")
                (trainer?.egeTasks?.first(where: { ($0 as! EgeTask).name == theme}) as! EgeTask).tasks = newTasks
                
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func getTaskLocation(taskName: String) -> (String, String) {
        var themeNameSet = [Character]()
        var taskNumberSet = [Character]()
        var isDotFound = false
        for letter in taskName {
            if letter == "." {
                isDotFound = true
                continue
            }
            if isDotFound {
                taskNumberSet.append(letter)
            } else {
                themeNameSet.append(letter)
            }
        }
        let themeName = String(themeNameSet)
        let taskNumber = String(taskNumberSet)
        return (themeName, taskNumber)
    }
    
    func getTasksNumber() -> Int {
        return tasks.count
    }
    
    func saveUsersProgress(with time: Int) {
        if Auth.auth().currentUser?.uid != nil, let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext {
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
        viewModel.timeTillEnd = time
        viewModel.wrightAnswers = wrightAnswers
        viewModel.testAnswers = testAnswers
        var tasksImages = [String:UIImage]()
        for task in tasks {
            tasksImages[task.name ?? ""] = task.image
        }
        viewModel.tasksImages = tasksImages
        viewModel.name = name
        viewModel.testAnswersUpdater = self
        viewModel.tasks = tasks
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
    
    func deleteData() {
        var newAnswers = [String:String]()
        for index in 1...32 {
            newAnswers["Задание №\(index)"] = ""
        }
        testAnswers = newAnswers
        timeTillEnd = 14100
    }
}

extension CustomTestViewModel: TestAnswersUpdater {
    func deleteTestsAnswers() {
        deleteData()
    }
}
