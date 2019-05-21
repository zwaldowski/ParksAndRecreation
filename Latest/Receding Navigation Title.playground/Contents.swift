import UIKit
import PlaygroundSupport

@objc(MyViewController)
class MyViewController: UIViewController {

    @IBOutlet private var scrollView: UIScrollView!
    @IBOutlet private var titleLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.setWantsScrollingTitle(tracking: titleLabel, in: scrollView)

        (titleLabel.font = titleLabel.font.boldFont)
    }

}

PlaygroundPage.current.liveView = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
