//
//  AlertPresenter.swift
//  MovieQuiz
//
//  Created by Надежда Пономарева on 02.10.2024.
import UIKit

class AlertPresenter {
    weak var delegate: UIViewController?
    init(delegate: MovieQuizViewController?) {
        self.delegate = delegate
    }
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert
        )
        let action = UIAlertAction(
            title: result.buttonText,
            style: .default
        ) { _ in result.completion()
                }
                
        alert.addAction(action)
        delegate?.present(alert, animated: true, completion: nil)
    }
}
