//
//  AlertPresenterDelegate.swift
//  MovieQuiz
//
//  Created by Дмитрий Мартынцов on 24.04.2024.
//

import Foundation
import UIKit

protocol AlertPresenterDelegate: AnyObject {
    func show(alert: UIAlertController)
}
