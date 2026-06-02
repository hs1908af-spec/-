import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        let model = NSManagedObjectModel()
        let scheduleEntity = NSEntityDescription()
        scheduleEntity.name = "Schedule"
        scheduleEntity.managedObjectClassName = NSStringFromClass(Schedule.self)

        let createdAt = NSAttributeDescription()
        createdAt.name = "createdAt"
        createdAt.attributeType = .dateAttributeType
        createdAt.isOptional = false

        let date = NSAttributeDescription()
        date.name = "date"
        date.attributeType = .dateAttributeType
        date.isOptional = false

        let memo = NSAttributeDescription()
        memo.name = "memo"
        memo.attributeType = .stringAttributeType
        memo.isOptional = true

        let startTime = NSAttributeDescription()
        startTime.name = "startTime"
        startTime.attributeType = .dateAttributeType
        startTime.isOptional = false

        let title = NSAttributeDescription()
        title.name = "title"
        title.attributeType = .stringAttributeType
        title.isOptional = false

        scheduleEntity.properties = [createdAt, date, memo, startTime, title]
        model.entities = [scheduleEntity]

        persistentContainer = NSPersistentContainer(name: "CheckModel", managedObjectModel: model)
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            assertionFailure("CoreData save error: \(error)")
        }
    }
}
