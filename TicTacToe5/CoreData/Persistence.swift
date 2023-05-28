//
//  Persistence.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import Foundation
//
//  Persistence.swift
//  Todo2
//
//  Created by Tim Yoon on 8/8/22.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let context = result.container.viewContext
        for index in 0..<5 {
            
        }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Coredata preview error while saving: \(nsError), \(nsError.userInfo)")
        }
        return result
    }()
    
    let container: NSPersistentCloudKitContainer
    let context : NSManagedObjectContext

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "TicTacToe")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
    
        container.persistentStoreDescriptions.first!.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        context = container.viewContext
        context.undoManager = UndoManager()
    }
    func save(){
        do{
            try container.viewContext.save()
        }catch let error {
            print("Error saving Core Data. \(error.localizedDescription)")
        }
    }
    func undo(){
        context.undo()
    }
    func redo(){
        context.redo()
    }
    func beginUndoGrouping(){
        context.undoManager?.beginUndoGrouping()
    }
    func endUndoGrouping(){
        context.undoManager?.endUndoGrouping()
    }
}
