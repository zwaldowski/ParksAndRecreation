import CoreData

//: **Ed. note:** Some of these techniques have been adapted into API for the [BNR CoreDataStack](https://github.com/bignerdranch/CoreDataStack).

// MARK: - Model class impl

class Test: NSManagedObject, CoreDataModelType {
    
    static let entityName = "Test"
    
}

extension Test {
    
    @NSManaged var count: NSNumber!
    
}

// MARK: - Simple model

let myEntityCount = NSAttributeDescription()
myEntityCount.name = "count"
myEntityCount.attributeType = .Integer64AttributeType

let myEntity = NSEntityDescription()
myEntity.name = Test.entityName
myEntity.properties = [ myEntityCount ]
myEntity.managedObjectClassName = NSStringFromClass(Test.self)

let model = NSManagedObjectModel()
model.entities = [ myEntity ]

let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
try! psc.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)

let context = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
context.persistentStoreCoordinator = psc

// MARK: - Using it

let myObject1 = Test(insertingInto: context)
myObject1.count = 42
print(myObject1)

let myObject2 = Test(insertingInto: context)
myObject2.count = 16
print(myObject2)

try! context.save()

let fr = NSFetchRequest(entityName: Test.entityName)
fr.fetchBatchSize = 1
let arr = (try! context.executeFetchRequest(fr))
