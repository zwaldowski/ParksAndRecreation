import UIKit

public final class BadgeGalleryViewController: UICollectionViewController, UICollectionViewDragDelegate {

    private enum Constants {
        static let cellIdentifier = "Badge"
    }

    private class Cell: UICollectionViewCell {

        private enum Constants {
            static let cornerRadius: CGFloat = 8.5
        }

        private let label = UILabel()

        override init(frame: CGRect) {
            super.init(frame: frame)
            
            let bv = UIView()
            bv.backgroundColor = #colorLiteral(red: 0.9490196078, green: 0.9568627451, blue: 1, alpha: 0.14)
            bv.layer.cornerRadius = Constants.cornerRadius
            self.backgroundView = bv

            let sbv = UIView()
            sbv.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            sbv.layer.cornerRadius = Constants.cornerRadius
            self.selectedBackgroundView = sbv
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 32, weight: .bold)
            label.textColor = .white
            label.highlightedTextColor = tintColor
            contentView.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
                contentView.layoutMarginsGuide.trailingAnchor.constraint(equalTo: label.trailingAnchor),
                label.topAnchor.constraint(greaterThanOrEqualTo: contentView.layoutMarginsGuide.topAnchor),
                label.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func tintColorDidChange() {
            super.tintColorDidChange()

            label.highlightedTextColor = tintColor
        }

        // MARK: -

        var text: String {
            get { return label.text ?? "" }
            set { label.text = newValue }
        }

        // MARK: -

        func clippingPathForDrag() -> UIBezierPath {
            return UIBezierPath(roundedRect: bounds, cornerRadius: Constants.cornerRadius)
        }

    }

    // MARK: -

    private let values = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!+<=>?\u{00D7}\u{00F7}\u{2212}\u{25b2}\u{25b6}\u{25bc}\u{25c0}\u{2713}\u{2717}")

    private let formatters = [
        BadgeFormatter(style: .outlinedSquare),
        BadgeFormatter(style: .outlinedRound),
        BadgeFormatter(style: .filledSquare),
        BadgeFormatter(style: .filledRound)
    ]

    private func formattedValue(at indexPath: IndexPath) -> String {
        let (valueIndex, formatterIndex) = indexPath.item.quotientAndRemainder(dividingBy: formatters.count)
        let value = values[valueIndex]
        let formatter = formatters[formatterIndex]
        return formatter.string(for: value)
    }

    private func dragItem(at indexPath: IndexPath) -> UIDragItem {
        let text = formattedValue(at: indexPath)
        let provider = NSItemProvider(object: text as NSItemProviderWriting)
        let item = UIDragItem(itemProvider: provider)
        return item
    }

    // MARK: -

    private func commonInit() {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }
        layout.sectionInsetReference = .fromLayoutMargins
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 16
        layout.minimumLineSpacing = 16
    }

    public init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        collectionView.allowsMultipleSelection = true
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.dragDelegate = self
    }

    // MARK: - UICollectionViewDataSource

    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assert(section == 0)
        return values.count * formatters.count
    }

    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as! Cell
        cell.text = formattedValue(at: indexPath)
        return cell
    }

    // MARK: - UICollectionViewDragDelegate

    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [ dragItem(at: indexPath) ]
    }

    public func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return [ dragItem(at: indexPath) ]
    }

    public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let cell = collectionView.cellForItem(at: indexPath) as! Cell
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = cell.clippingPathForDrag()
        previewParameters.backgroundColor = .black
        return previewParameters
    }

}
