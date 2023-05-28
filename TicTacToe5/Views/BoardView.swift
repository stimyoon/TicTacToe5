//
//  BoardView.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

//
//  BoardView.swift
//  TicTacToe4
//
//  Created by Tim Yoon on 5/27/23.
//

import SwiftUI


protocol BoardViewVMProtocol: ObservableObject {
    var board: [[Tile]] { get }
    var isXTurn: Bool { get }
    func handleTap(row: Int, col: Int)
    func reset()
}


class BoardViewVM: BoardViewVMProtocol {
    @Published private(set) var board: [[Tile]] {
        didSet {
            save(items: board, key: key)
        }
    }
    @Published private(set) var isXTurn = false
    
    init(){
        self.board = load(key: key)
        if board.isEmpty {
            board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        }
    }
    
    // MARK: Public functions
    func handleTap(row: Int, col: Int) {
        guard board[row][col] == .none else { return }
        if isXTurn {
            board[row][col] = .x
            isXTurn = false
        }else{
            board[row][col] = .o
            isXTurn = true
        }
    }
    
    func reset() {
        print("Reset")
        for row in 0..<3 {
            for col in 0..<3 {
                board[row][col] = .none
            }
        }
    }
    
    // MARK: Private
    private let key = "TTTData5"
}

struct BoardView<VM: BoardViewVMProtocol>: View {
    @ObservedObject var vm: VM
    
    var body: some View {
        VStack{
            Text("Turn: \(vm.isXTurn ? "X" : "O")")
            ForEach(0..<3, id: \.self) { row in
                HStack {
                    ForEach(0..<3, id: \.self) { col in
                        Rectangle()
                            .fill(Color.teal.opacity(0.2))
                            .overlay{
                                Text(" \(vm.board[row][col].text)")
                                    .font(.system(size: 40))
                            }
                            .onTapGesture {
                                vm.handleTap(row: row, col: col)
                                print("Tapped \(row) \(col)")
                            }
                    }
                }
            }
            Button {
                vm.reset()
            } label: {
                Text("Reset")
            }
            .buttonStyle(.borderedProminent)

        }
    }
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView(vm: BoardViewVM())
    }
}
