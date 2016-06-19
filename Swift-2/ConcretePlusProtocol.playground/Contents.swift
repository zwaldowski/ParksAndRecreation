import UIKit

//: This protocol demonstrates how you might write the equivalent of Objective-C's `SomeType<SomeProtocol> *` syntax using Swift 2 protocol extensions. This requires changes to your API, which is manageable from within a module; if you can't do that, get creative with nested protocols.

protocol MyThingy {
    
    func frobdingnang()
    
    var view: UIView { get }
    
}

extension MyThingy where Self: UIView {
    
    var view: UIView {
        return self
    }
    
}

func takeAThing(a: MyThingy) {
    print(a)
}

extension UITableView: MyThingy {
    
    func frobdingnang() {
        print("Yeah")
    }
    
}

let table = UITableView()
takeAThing(table)
