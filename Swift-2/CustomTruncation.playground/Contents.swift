import UIKit
import XCPlayground

XCPlaygroundPage.currentPage.needsIndefiniteExecution = true

final class LabelViewController: UIViewController {
    
    private let longText = "Heirloom banjo readymade kogi, cold-pressed YOLO raw denim Echo Park fashion axe 8-bit kale chips occupy. Meh ugh farm-to-table Pinterest fingerstache 8-bit. +1 hella PBR sartorial blog Intelligentsia, XOXO post-ironic slow-carb taxidermy Vice pop-up Neutra. McSweeney's vegan listicle put a bird on it fanny pack. Kickstarter narwhal Banksy, Marfa hashtag retro polaroid VHS farm-to-table Williamsburg stumptown twee. Banjo Schlitz Williamsburg yr listicle lumbersexual. Retro synth Wes Anderson, Williamsburg brunch raw denim quinoa flexitarian hoodie kale chips."
    
    private lazy var label1: UILabel = {
        let label = UILabel()
        label.text = self.longText
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        label.numberOfLines = 2
        label.textAlignment = .Justified
        label.lineBreakMode = .ByTruncatingTail
        return label
    }()
    
    private lazy var label2: TruncatingLabel = {
        let label = TruncatingLabel()
        label.text = self.longText
        label.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        label.numberOfLines = 2
        label.textAlignment = .Justified
        label.lineBreakMode = .ByTruncatingTail
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        label1.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label1)
        label1.setContentHuggingPriority(251, forAxis: .Horizontal)
        label1.setContentHuggingPriority(251, forAxis: .Vertical)
        
        label2.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label2)
        label2.setContentHuggingPriority(251, forAxis: .Horizontal)
        label2.setContentHuggingPriority(251, forAxis: .Vertical)
        
        NSLayoutConstraint.activateConstraints([
            label1.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 8),
            label1.leadingAnchor.constraintEqualToAnchor(view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraintGreaterThanOrEqualToAnchor(label1.trailingAnchor),
            label2.leadingAnchor.constraintEqualToAnchor(label1.leadingAnchor),
            label2.topAnchor.constraintEqualToAnchor(label1.bottomAnchor, constant: 42),
            view.layoutMarginsGuide.trailingAnchor.constraintGreaterThanOrEqualToAnchor(label2.trailingAnchor),
            ])
    }
    
    private var timer: NSTimer?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        timer?.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "noteDemoTick", userInfo: nil, repeats: true)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
        timer = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = view.bounds.width - view.layoutMargins.left - view.layoutMargins.right
        label1.preferredMaxLayoutWidth = width
        label2.preferredMaxLayoutWidth = width
        
        view.layoutIfNeeded()
    }
    
    // MARK: -
    
    private var demoTick = 0
    
    @IBAction func noteDemoTick() {
        demoTick += 1
        if (demoTick % 2) != 0 {
            view.tintAdjustmentMode = .Automatic
            label2.toggleTruncation()
        } else {
            view.tintAdjustmentMode = .Dimmed
        }
    }
    
}

XCPlaygroundPage.currentPage.liveView = LabelViewController()
