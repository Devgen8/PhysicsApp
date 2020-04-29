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
    var wrightAnswer: Double?
    var alternativeAnswer: Double?
    var stringAnswer: String?
    var succeded: Int?
    var failed: Int?
    var theme: String?
    
    public func encode(with coder: NSCoder) {
        coder.encode(name, forKey: "name")
        coder.encode(serialNumber, forKey: "serialNumber")
        coder.encode(image?.pngData(), forKey: "image")
        coder.encode(wrightAnswer, forKey: "wrightAnswer")
        coder.encode(alternativeAnswer, forKey: "alternativeAnswer")
        coder.encode(stringAnswer, forKey: "stringAnswer")
        coder.encode(succeded, forKey: "succeded")
        coder.encode(failed, forKey: "failed")
        coder.encode(theme, forKey: "theme")
    }
    
    public override init() {
        super.init()
    }
    
    init(name: String?,
         serialNumber: Int?,
         image: Data?,
         wrightAnswer: Double?,
         alternativeAnswer: Double?,
         stringAnswer: String?,
         succeded: Int?,
         failed: Int?,
         theme: String?) {
        self.name = name
        self.serialNumber = serialNumber
        self.image = UIImage(data: image ?? Data())
        self.wrightAnswer = wrightAnswer
        self.alternativeAnswer = alternativeAnswer
        self.stringAnswer = stringAnswer
        self.succeded = succeded
        self.failed = failed
        self.theme = theme
    }
    
    public required convenience init?(coder: NSCoder) {
        let decodedName = coder.decodeObject(forKey: "name") as? String
        let decodedSerialNumber = coder.decodeObject(forKey: "serialNumber") as? Int
        let decodedImage = coder.decodeObject(forKey: "image") as? Data
        let decodedWrightanswer = coder.decodeObject(forKey: "wrightAnswer") as? Double
        let decodedAlternativeAnswer = coder.decodeObject(forKey: "alternativeAnswer") as? Double
        let decodedStringAnswer = coder.decodeObject(forKey: "stringAnswer") as? String
        let decodedSucceded = coder.decodeObject(forKey: "succeded") as? Int
        let decodedFailed = coder.decodeObject(forKey: "failed") as? Int
        let decodedTheme = coder.decodeObject(forKey: "serialNumber") as? String
        
        self.init(name: decodedName,
        serialNumber: decodedSerialNumber,
        image: decodedImage,
        wrightAnswer: decodedWrightanswer,
        alternativeAnswer: decodedAlternativeAnswer,
        stringAnswer: decodedStringAnswer,
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
