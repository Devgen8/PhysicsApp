//
//  TaskModel.swift
//  TrainingApp
//
//  Created by мак on 18/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

public class TaskModel:NSObject, NSCoding {
    var name: String?
    var serialNumber: Int?
    var image: UIImage?
    var taskDescription: UIImage?
    var wrightAnswer: String?
    var alternativeAnswer: Bool?
    var succeded: Int?
    var failed: Int?
    var theme: String?
    
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(serialNumber, forKey: "serialNumber")
        coder.encode(image?.pngData(), forKey: "image")
        coder.encode(wrightAnswer, forKey: "wrightAnswer")
        coder.encode(alternativeAnswer, forKey: "alternativeAnswer")
        coder.encode(succeded, forKey: "succeded")
        coder.encode(failed, forKey: "failed")
        coder.encode(theme, forKey: "theme")
        coder.encode(taskDescription?.pngData(), forKey: "taskDescription")
    }
    
    public override init() {
        super.init()
    }
    
    init(name: String?,
         serialNumber: Int?,
         image: Data?,
         taskDescription: Data?,
         wrightAnswer: String?,
         alternativeAnswer: Bool?,
         succeded: Int?,
         failed: Int?,
         theme: String?) {
        self.name = name
        self.serialNumber = serialNumber
        self.image = UIImage(data: image ?? Data())
        self.taskDescription = UIImage(data: taskDescription ?? Data())
        self.wrightAnswer = wrightAnswer
        self.alternativeAnswer = alternativeAnswer
        self.succeded = succeded
        self.failed = failed
        self.theme = theme
    }
    
    public required convenience init?(coder: NSCoder) {
        let decodedName = coder.decodeObject(forKey: "name") as? String
        let decodedSerialNumber = coder.decodeObject(forKey: "serialNumber") as? Int
        let decodedImage = coder.decodeObject(forKey: "image") as? Data
        let decodedTaskDescription = coder.decodeObject(forKey: "taskDescription") as? Data
        let decodedWrightanswer = coder.decodeObject(forKey: "wrightAnswer") as? String
        let decodedAlternativeAnswer = coder.decodeObject(forKey: "alternativeAnswer") as? Bool
        let decodedSucceded = coder.decodeObject(forKey: "succeded") as? Int
        let decodedFailed = coder.decodeObject(forKey: "failed") as? Int
        let decodedTheme = coder.decodeObject(forKey: "serialNumber") as? String
        
        self.init(name: decodedName,
        serialNumber: decodedSerialNumber,
        image: decodedImage,
        taskDescription: decodedTaskDescription,
        wrightAnswer: decodedWrightanswer,
        alternativeAnswer: decodedAlternativeAnswer,
        succeded: decodedSucceded,
        failed: decodedFailed,
        theme: decodedTheme)
    }
}

enum Task: String {
    case serialNumber = "serialNumber"
    case image = "image"
    case wrightAnswer = "wrightAnswer"
    case alternativeAnswer = "alternativeAnswer"
    case succeded = "succeded"
    case failed = "failed"
}

enum DataOperationsMode {
    case mix
    case trainer
}
