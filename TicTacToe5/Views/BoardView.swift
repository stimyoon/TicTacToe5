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
import Combine

protocol BoardViewVMProtocol: ObservableObject {
    var board: [[Tile]] { get }
    var isXTurn: Bool { get }
    func handleTap(row: Int, col: Int)
    func reset()
}

class BoardViewCoreDataVM: BoardViewVMProtocol {
    @Published private(set) var board: [[Tile]] = [[]]
    @Published private(set) var isXTurn = false
    
    let ds = CoreDataService<TileEntity>(manager: PersistenceController.shared, entityName: "TileEntity")
    private var cancellables = Set<AnyCancellable>()
    @Published private var tileEntities: [TileEntity] = []

    init(){
        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
        ds.get()
            .sink { error in
                fatalError()
            } receiveValue: { tileEntities in
                self.tileEntities = tileEntities
            }
            .store(in: &cancellables)
        
        $board
            .combineLatest($tileEntities) { board, tileEntities in
                self.getUpdatedBoard(tileEntities: tileEntities, board: board)
            }
            .sink { error in
                fatalError()
            } receiveValue: { [weak self] tiles in
                self?.board = tiles
            }
            .store(in: &cancellables)
        
        ds.get()
            .map{ (tileEntities)->Bool in
                if tileEntities.count % 2 == 1 {
                    return false
                }else {
                    return true
                }
            }
            .sink(receiveCompletion: { error in
                fatalError()
            }, receiveValue: { [weak self] isXTurn in
                self?.isXTurn = isXTurn
            })
            .store(in: &cancellables)
    }
    
    private func getUpdatedBoard(tileEntities: [TileEntity], board: [[Tile]]) -> [[Tile]] {
        var board = board
        for tileEntity in tileEntities {
            let row = Int(tileEntity.row)
            let col = Int(tileEntity.col)
            board[row][col] = Tile(rawValue: tileEntity.tileValue)!
        }
        return board
    }
    
    // MARK: Public functions
    func handleTap(row: Int, col: Int) {
        guard board[row][col] == .none else { return }
        let tileEntity = ds.create()
        
        tileEntity.row = Int16(row)
        tileEntity.col = Int16(col)
        
        if isXTurn {
            tileEntity.tileValue = Tile.x.rawValue
            isXTurn = false
        }else{
            tileEntity.tileValue = Tile.o.rawValue
            isXTurn = true
        }
        ds.add(tileEntity)
    }
    
    func reset() {
        print("Reset")
        for tileEntity in tileEntities {
            ds.delete(tileEntity)
        }
        self.board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
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
    private let key = "TTTData4"
}

struct BoardView<VM: BoardViewVMProtocol>: View {
    @ObservedObject var vm: VM
    
    var body: some View {
        VStack{
            ForEach(0..<3, id: \.self) { row in
                HStack {
                    ForEach(0..<3, id: \.self) { col in
                        Rectangle()
                            .fill(Color.teal.opacity(0.2))
                            .overlay{
                                Text("item \(vm.board[row][col].text)")
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
