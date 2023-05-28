//
//  CoreDataService.swift
//  TicTacToe5
//
//  Created by Tim Yoon on 5/28/23.
//

import Foundation

//
//  SurgeonCoreDataService.swift
//  TrayTracker4
//
//  Created by Tim Yoon on 9/4/22.
//

import Foundation
import CoreData
import Combine

class CoreDataService<Entity: Identifiable & NSManagedObject> : NSObject, NSFetchedResultsControllerDelegate, ObservableObject, DataServiceProtocol {
    
    private var fetchRequest : NSFetchRequest<Entity>
    private var entityName : String
    
    @Published private var entities : [Entity] = []
    
    let manager : PersistenceController
    private var cancellables = Set<AnyCancellable>()
    private var fetchedResultsController: NSFetchedResultsController<Entity>
    private var sortDescriptors : [NSSortDescriptor]
    private var predicate: NSPredicate?
    
    private func fetch(){
        do {
            entities = try manager.context.fetch(fetchRequest)
        } catch let error {
            fatalError("Error: Unable to fetch coredata \(error.localizedDescription)")
        }
    }
    func setPredicate(predicate: NSPredicate){
        fetchRequest.predicate = predicate
    }
    func setSortDescriptor(_ descriptors: [NSSortDescriptor]){
        self.sortDescriptors = descriptors
    }
    
    func get() -> AnyPublisher<[Entity], Error> {
        $entities.tryMap( {$0} ).eraseToAnyPublisher()
    }
    func getObject(by entityID: Entity.ID) -> Entity? {
        guard let index = entities.firstIndex(where: {$0.id == entityID}) else { return nil }
        return entities[index]
    }
    func create() -> Entity {
        Entity(context: manager.context)
    }
    func add(_ entity: Entity) {
        manager.save()
    }
    func deleteAll(){
        for entity in entities {
            manager.context.delete(entity)
        }
        manager.save()
    }
    func delete(_ entity: Entity) {
        manager.context.delete(entity)
        manager.save()
    }
    func delete(indexSet: IndexSet) {
        for index in indexSet {
            manager.context.delete(entities[index])
        }
        manager.save()
    }
    func update(_ entity: Entity) {
        manager.save()
    }

    func undo() {
        manager.undo()
    }
    func redo() {
        manager.redo()
    }
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let entities = controller.fetchedObjects as? [Entity] else { return }
        self.entities = entities
    }
    init(manager: PersistenceController, entityName: String, sortDescriptors: [NSSortDescriptor]=[], predicate: NSPredicate?=nil) {
        self.manager = manager
        self.entityName = entityName
        self.fetchRequest = NSFetchRequest(entityName: entityName)
        self.sortDescriptors = sortDescriptors
        self.fetchRequest.sortDescriptors = sortDescriptors
        self.fetchRequest.predicate = predicate
        
        self.fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: manager.context, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()

        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            guard let entities = fetchedResultsController.fetchedObjects else { return }
            self.entities = entities
        } catch {
            print(error)
        }
        
        fetch()
    }
}
