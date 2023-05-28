//
//  TicTacToe5App.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import SwiftUI

@main
struct TicTacToe5App: App {
    let persistenceController = PersistenceController.shared
//    @StateObject var vm = BoardViewVM()
    @StateObject var vm = BoardViewCoreDataVM()
    var body: some Scene {
        WindowGroup {
            BoardView(vm: vm)
//                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
