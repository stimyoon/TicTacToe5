//
//  DataServiceProtocol.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import Foundation

//
//  Dataservice.swift
//  TrayTracker5
//
//  Created by Tim Yoon on 9/4/22.
//

import Foundation
import Combine

protocol DataServiceProtocol {
    associatedtype ItemType: Identifiable
    func get()->AnyPublisher<[ItemType], Error>
    func add(_ item: ItemType)
    func delete(_ item: ItemType)
    func delete(indexSet: IndexSet)
    func update(_ item: ItemType)
    func create()->ItemType
    func getObject(by: ItemType.ID)->ItemType?
}

class MockDataService<T: Identifiable> : DataServiceProtocol {
    typealias ItemType = T
    
    @Published private(set) var items : [T] = []
    var makeItem : ()->T

    init(makeItem: @escaping ()->T){
        self.makeItem = makeItem
    }
    func get()->AnyPublisher<[T], Error> {
        $items.tryMap({$0}).eraseToAnyPublisher()
    }
    
    func add(_ item: T){
        items.append(item)
    }
    func delete(_ item: T){
        guard let index = items.firstIndex(where: {$0.id == item.id}) else { return }
        items.remove(at: index)
    }
    func delete(indexSet: IndexSet) {
        items.remove(atOffsets: indexSet)
    }
    func update(_ item: T){
        guard let index = items.firstIndex(where: {$0.id == item.id}) else { return }
        items[index] = item
    }
    func create()->T{
        makeItem()
    }
    func getObject(by id: T.ID)->T? {
        guard let index = items.firstIndex(where: {$0.id == id}) else { return nil }
        return items[index]
    }
    
}
