//
//  MoviesLoadingProtocol.swift
//  MovieQuiz
//
//  Created by Дмитрий Мартынцов on 13.05.2024.
//

import Foundation

protocol MoviesLoading {
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void)
}
