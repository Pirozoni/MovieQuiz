//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Надежда Пономарева on 02.10.2024.
import Foundation

protocol AlertPresenterDelegate: AnyObject {
    func show(quiz result: AlertModel)
}
