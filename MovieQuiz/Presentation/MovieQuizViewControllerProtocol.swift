//
//  MovieQuizViewControllerProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий Мартынцов on 17.05.2024.
//

import Foundation

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepViewModel)
    func show(quiz result: QuizResultsViewModel)
    
    func highlightImageBorder(isCorrectAnswer: Bool)
    func blockButton(isBlocked: Bool)
    
    func showLoadingIndicator()
    func hideLoadingIndicator()
    
    func showNetworkError(message: String)
} 
