//
//  NetworkRoutingProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий Мартынцов on 13.05.2024.
//

import Foundation

protocol NetworkRouting {
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void)
}
