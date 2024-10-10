//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Надежда Пономарева on 02.10.2024.

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func didFailToLoadData(with error: Error)
}
