import CoreData

public protocol CoreDataModelType: class {
    
    static var entityName: String { get }
    
}

public extension CoreDataModelType where Self: NSManagedObject {
    
    private static func entityInContext(context: NSManagedObjectContext) -> NSEntityDescription! {
        guard let entity = NSEntityDescription.entityForName(Self.entityName, inManagedObjectContext: context) else {
            assertionFailure("Entity doesn't exist named \(Self.entityName). Fix the pairing for \(Self.self).")
            return nil
        }
        return entity
    }
    
    init!(insertingInto context: NSManagedObjectContext) {
        self.init(entity: Self.entityInContext(context), insertIntoManagedObjectContext: context)
    }
    
    // WIP
    /*
    private static func objectsInContext<T>(context: NSManagedObjectContext, ofType: T.Type = T.self, @noescape fetchRequest makeFetchRequest: NSEntityDescription -> NSFetchRequest) throws -> T {
        let entity = Self.entityInContext(context)
        let request = makeFetchRequest(entity)
        let fr1 = try context.executeFetchRequest(request)
        print(fr1.dynamicType)
        guard let fetchResults = fr1 as? T else {
            print("yeah")
            throw NSCocoaError.CoreDataError
        }
        return fetchResults
    }
    */
    
}
