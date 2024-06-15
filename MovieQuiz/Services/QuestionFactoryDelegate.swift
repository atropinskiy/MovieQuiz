//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by alex_tr on 13.06.2024.
//

import Foundation

protocol QuestionFactoryDelegate: AnyObject {               // 1
    func didReceiveNextQuestion(question: QuizQuestion?)    // 2
} 
