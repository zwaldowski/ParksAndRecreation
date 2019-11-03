import UIKit
import PlaygroundSupport

class ExampleViewController: UIViewController {
    
    private(set) var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor)
        ])

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Scroll", style: .plain, target: self, action: #selector(magicScroll))
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print(scrollView.contentSize)
    }

    @objc private func magicScroll(from sender: Any) {
        scrollView.scrollRectToVisible(CGRect(x: 0, y: 2000, width: 200, height: 10), animated: true)
    }
    
}

class ExampleTableViewController: ExampleViewController, UITableViewDataSource {
    
    private(set) var tableView: DerivingContentSizeTableView!
    
    class Cell: UITableViewCell {
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            
            contentView.backgroundColor = .red
            
            let v = UIView()
            v.backgroundColor = .green
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
            
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                contentView.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: 10),
                contentView.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: 10)
            ])
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = "Table View"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tableView = DerivingContentSizeTableView()
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 44
        tableView.register(Cell.self, forCellReuseIdentifier: "Cell")
        scrollView.addSubview(tableView)
        self.tableView = tableView
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            tableView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            tableView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 64),
            scrollView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor, constant: 64),
            scrollView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor)
        ])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10000
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
    }

}

class ExampleCollectionViewController: ExampleViewController, UICollectionViewDataSource {
    
    private(set) var collectionView: DerivingContentSizeCollectionView!
    
    class Cell: UICollectionViewCell {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = .red
            
            let v = UIView()
            v.backgroundColor = .green
            v.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(v)
            
            NSLayoutConstraint.activate([
                v.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                v.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
                contentView.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: 10),
                contentView.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: 10)
            ])
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        title = "Collection"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let collectionViewLayout = UICollectionViewFlowLayout()
        collectionViewLayout.minimumLineSpacing = 10
        collectionViewLayout.itemSize = CGSize(width: 50, height: 50)
        collectionViewLayout.minimumInteritemSpacing = 10
        
        let collectionView = DerivingContentSizeCollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.isScrollEnabled = false
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(Cell.self, forCellWithReuseIdentifier: "Cell")
        scrollView.addSubview(collectionView)
        self.collectionView = collectionView
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            collectionView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 64),
            scrollView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor, constant: 64),
            scrollView.bottomAnchor.constraint(equalTo: collectionView.bottomAnchor)
        ])
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10000
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    }
    
}

let tab = UITabBarController()
tab.viewControllers = [
    UINavigationController(rootViewController: ExampleTableViewController()),
    UINavigationController(rootViewController: ExampleCollectionViewController())
]
PlaygroundPage.current.liveView = tab

//: [Next](@next)
