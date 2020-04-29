//
//  AnswerChooserViewModel.swift
//  TrainingApp
//
//  Created by мак on 22/03/2020.
//  Copyright © 2020 мак. All rights reserved.
//

import UIKit

class AnswerChooserViewModel {
    var questions = [BattleModel]()
    var taskNumber = 0
    var userAnswers = [Bool]()
    var opponentsAnswers = [Bool]()
    var computerAnswer: String?
    var opponentsName: String?
    var numberOfPlays: Int?
    
    func generateOpponentsAnswer() {
        let randomIndex = Int.random(in: 1...100)
        let wrightAnswer = questions[taskNumber].wrightAnswer
        if questions[taskNumber].possibility ?? 100 > randomIndex {
            computerAnswer = "\(wrightAnswer ?? 0)"
            updateOpponentsAnswers(with: true)
        } else {
            let possibleAnswers = questions[taskNumber].answers?.filter({ $0 != wrightAnswer })
            computerAnswer = "\(possibleAnswers?[Int.random(in: 0..<(possibleAnswers?.count ?? 0))] ?? 0)"
            updateOpponentsAnswers(with: false)
        }
    }
    
    func getQuestionImage() -> UIImage? {
        return questions[taskNumber].image
    }
    
    func getAnswers() -> [Float] {
        return questions[taskNumber].answers ?? []
    }
    
    func updateUserAnswers(with answer: Bool) {
        userAnswers += [answer]
    }
    
    func updateOpponentsAnswers(with answer: Bool) {
        opponentsAnswers += [answer]
    }
    
    func checkAnswer(_ answer: String) -> Bool {
        return Float(answer) == questions[taskNumber].wrightAnswer ?? 0
    }
    
    func checkOpponentsAnswer() -> Bool {
        return opponentsAnswers[taskNumber]
    }
    
    func updateQuestionNumber() {
        taskNumber += 1
    }
    
    func getOpponentsName() -> String? {
        return opponentsName
    }
 }
