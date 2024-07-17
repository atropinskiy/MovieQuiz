//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by alex_tr on 13.06.2024.
//
import UIKit
import Foundation

class AlertPresenter: AlertPresenterProtocol {
    weak var delegate: UIViewController?
    init(delegate: UIViewController) {
        self.delegate = delegate
    }
    
    func showAlert(quiz alertModel: AlertModel) {
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Game results"
        let action = UIAlertAction(
            title: alertModel.buttonText,
            style: .default,
            handler: alertModel.completion
        )
        alert.addAction(action)
        
        delegate?.present(alert, animated: true, completion: nil)
    }
    
}
