//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by alex_tr on 13.06.2024.
//
import UIKit

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ((UIAlertAction) -> Void)?
}
