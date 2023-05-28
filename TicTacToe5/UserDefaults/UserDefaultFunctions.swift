//
//  UserDefaultFunctions.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import Foundation

func save<T: Identifiable & Codable>(items: [[T]], key: String) {
    let encoder = JSONEncoder()
    if let encoded = try? encoder.encode(items) {
        let defaults = UserDefaults.standard
        defaults.set(encoded, forKey: key)
    }
}
func load<T: Identifiable & Codable>(key: String) -> [[T]] {
    guard let data = UserDefaults.standard.object(forKey: key) as? Data else { return [] }
    
    let decoder = JSONDecoder()
    if let dataArray = try? decoder.decode([[T]].self, from: data) {
        return dataArray
    }
    
    return [[]]
}
