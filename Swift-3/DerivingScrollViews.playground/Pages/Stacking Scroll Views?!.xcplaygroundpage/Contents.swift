//: [Previous](@previous)

import UIKit
import PlaygroundSupport

class StackedCollectionViewsController: UIViewController, UICollectionViewDataSource {
    
    class RedCell: UICollectionViewCell {
        
        class var color: UIColor { return .red }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = type(of: self).color
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
    }

    class GreenCell: RedCell {
        
        override class var color: UIColor { return .green }
        
    }
    
    
    class BlueCell: RedCell {
        
        override class var color: UIColor { return .blue }
        
    }
    
    private var scrollView: UIScrollView!
    private var redCV: UICollectionView!
    private var blueCV: UICollectionView!
    private var greenCV: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        self.scrollView = scrollView
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        
        let redLayout = UICollectionViewFlowLayout()
        redLayout.minimumLineSpacing = 30
        redLayout.itemSize = CGSize(width: 30, height: 30)
        redLayout.minimumInteritemSpacing = 30
        redCV = DerivingContentSizeCollectionView(frame: .zero, collectionViewLayout: redLayout)
        redCV.isScrollEnabled = false
        redCV.dataSource = self
        redCV.translatesAutoresizingMaskIntoConstraints = false
        redCV.register(RedCell.self, forCellWithReuseIdentifier: "RedCell")
        stackView.addArrangedSubview(redCV)

        let greenLayout = UICollectionViewFlowLayout()
        greenLayout.minimumLineSpacing = 20
        greenLayout.itemSize = CGSize(width: 40, height: 40)
        greenLayout.minimumInteritemSpacing = 20
        greenCV = DerivingContentSizeCollectionView(frame: .zero, collectionViewLayout: greenLayout)
        greenCV.isScrollEnabled = false
        greenCV.dataSource = self
        greenCV.translatesAutoresizingMaskIntoConstraints = false
        greenCV.register(GreenCell.self, forCellWithReuseIdentifier: "GreenCell")
        stackView.addArrangedSubview(greenCV)

        let blueLayout = UICollectionViewFlowLayout()
        blueLayout.minimumLineSpacing = 10
        blueLayout.itemSize = CGSize(width: 50, height: 40)
        blueLayout.minimumInteritemSpacing = 10
        blueCV = DerivingContentSizeCollectionView(frame: .zero, collectionViewLayout: blueLayout)
        blueCV.isScrollEnabled = false
        blueCV.dataSource = self
        blueCV.translatesAutoresizingMaskIntoConstraints = false
        blueCV.register(BlueCell.self, forCellWithReuseIdentifier: "BlueCell")
        stackView.addArrangedSubview(blueCV)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            view.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            stackView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 10),
            scrollView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 10),
            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            scrollView.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 10)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print(scrollView.contentSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 85
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case redCV:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "RedCell", for: indexPath)
        case greenCV:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "GreenCell", for: indexPath)
        case blueCV, _:
            return collectionView.dequeueReusableCell(withReuseIdentifier: "BlueCell", for: indexPath)
        }
    }
    
    
}

PlaygroundPage.current.liveView = StackedCollectionViewsController()

//: [Next](@next)
