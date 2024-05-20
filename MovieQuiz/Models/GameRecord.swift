//
//  GameRecord.swift
//  MovieQuiz
//
//  Created by Дмитрий Мартынцов on 26.04.2024.
//

import Foundation

struct GameRecord: Codable {
    let correct: Int
    let total: Int
    let date: Date

    func isBetter(_ another: GameRecord) -> Bool {
        return correct < another.correct
    }

    func toString() -> String {
        return "\(correct)/\(total) (\(date.dateTimeString)"
    }
}
