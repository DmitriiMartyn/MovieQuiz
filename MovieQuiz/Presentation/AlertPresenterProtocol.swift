//
//  AlertProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий Мартынцов on 24.04.2024.
//

import Foundation

protocol AlertPresenterProtocol: AnyObject {
    var delegate: AlertPresenterDelegate? { get set }
    func show(alertModel: AlertModel)
}
