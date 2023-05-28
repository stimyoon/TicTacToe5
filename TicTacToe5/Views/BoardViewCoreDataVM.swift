//
//  BoardViewCoreDataVM.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import Foundation
import Combine

class BoardViewCoreDataVM: BoardViewVMProtocol {
    @Published private(set) var board: [[Tile]] = [[]]
    @Published private(set) var isXTurn = false
    
    private let ds = CoreDataService<TileEntity>(manager: PersistenceController.shared, entityName: "TileEntity")
    private var cancellables = Set<AnyCancellable>()


    init(){
        board = Array(repeating: Array(repeating: .none, count: 3), count: 3)

        ds.get()
            .map{ tileEntities in
                self.getUpdatedBoard(tileEntities: tileEntities, board: self.board)
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
        ds.deleteAll()
//        self.board = Array(repeating: Array(repeating: .none, count: 3), count: 3)
    }
}
