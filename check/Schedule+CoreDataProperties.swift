import CoreData

extension Schedule {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Schedule> {
        NSFetchRequest<Schedule>(entityName: "Schedule")
    }

    @NSManaged public var createdAt: Date
    @NSManaged public var date: Date
    @NSManaged public var memo: String?
    @NSManaged public var startTime: Date
    @NSManaged public var title: String
}
