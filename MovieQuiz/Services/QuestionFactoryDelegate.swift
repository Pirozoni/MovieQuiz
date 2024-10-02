//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Надежда Пономарева on 30.09.2024.
//
protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
