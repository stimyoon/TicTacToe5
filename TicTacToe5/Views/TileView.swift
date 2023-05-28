//
//  TileView.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import SwiftUI

enum Tile: Int16, Identifiable, Codable, CaseIterable {
    var id: Self {
        self
    }
    case none, x, o
    var text: String {
        switch self {
        case .none:
            return ""
        case .x:
            return "X"
        case .o:
            return "O"
        }
    }
}
struct TileView: View {
    let tile: Tile
    var text: String {
        tile.text
    }
    var body: some View {
        Rectangle()
            .fill(Color.teal.opacity(0.2))
            .overlay{
                Text(text)
            }
    }
}

struct TileView_Previews: PreviewProvider {
    static var previews: some View {
        TileView(tile: Tile.x)
    }
}
