//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport

final class FirstViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "First"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        navigationController?.tabBarItem.title = title
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let toggleStack = UIStackView()
        toggleStack.translatesAutoresizingMaskIntoConstraints = false
        toggleStack.axis = .horizontal
        toggleStack.spacing = 16
        view.addSubview(toggleStack)

        let toggleLabel = UILabel()
        toggleLabel.translatesAutoresizingMaskIntoConstraints = false
        toggleLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        toggleLabel.text = "Show palette?"
        toggleLabel.adjustsFontForContentSizeCategory = true
        toggleStack.addArrangedSubview(toggleLabel)

        let toggleSwitch = UISwitch()
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        toggleSwitch.addTarget(self, action: #selector(togglePalette), for: .primaryActionTriggered)
        toggleStack.addArrangedSubview(toggleSwitch)

        let layoutTopContainer = UIView()
        layoutTopContainer.translatesAutoresizingMaskIntoConstraints = false
        layoutTopContainer.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 0.5)
        view.addSubview(layoutTopContainer)

        let layoutTop = UILabel()
        layoutTop.translatesAutoresizingMaskIntoConstraints = false
        layoutTop.font = UIFont.preferredFont(forTextStyle: .footnote)
        layoutTop.text = "Layout top"
        layoutTop.adjustsFontForContentSizeCategory = true
        layoutTopContainer.addSubview(layoutTop)

        let layoutBottomContainer = UIView()
        layoutBottomContainer.translatesAutoresizingMaskIntoConstraints = false
        layoutBottomContainer.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.8509803922, blue: 0.3921568627, alpha: 0.5)
        view.addSubview(layoutBottomContainer)

        let layoutBottom = UILabel()
        layoutBottom.translatesAutoresizingMaskIntoConstraints = false
        layoutBottom.font = UIFont.preferredFont(forTextStyle: .footnote)
        layoutBottom.text = "Layout bottom"
        layoutBottom.adjustsFontForContentSizeCategory = true
        layoutBottomContainer.addSubview(layoutBottom)

        let screenBottomContainer = UIView()
        screenBottomContainer.translatesAutoresizingMaskIntoConstraints = false
        screenBottomContainer.backgroundColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 0.9843137255, alpha: 0.4820367518)
        view.addSubview(screenBottomContainer)

        let screenBottom = UILabel()
        screenBottom.translatesAutoresizingMaskIntoConstraints = false
        screenBottom.font = UIFont.preferredFont(forTextStyle: .footnote)
        screenBottom.text = "Screen bottom"
        screenBottom.adjustsFontForContentSizeCategory = true
        screenBottomContainer.addSubview(screenBottom)

        NSLayoutConstraint.activate([
            toggleStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            toggleStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            layoutTopContainer.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            layoutTopContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            layoutTopContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            layoutTop.topAnchor.constraint(equalTo: layoutTopContainer.layoutMarginsGuide.topAnchor),
            layoutTop.centerXAnchor.constraint(equalTo: layoutTopContainer.layoutMarginsGuide.centerXAnchor),
            layoutTop.centerYAnchor.constraint(equalTo: layoutTopContainer.layoutMarginsGuide.centerYAnchor),

            bottomLayoutGuide.topAnchor.constraint(equalTo: layoutBottomContainer.bottomAnchor),
            layoutBottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            layoutBottomContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            layoutBottom.topAnchor.constraint(equalTo: layoutBottomContainer.layoutMarginsGuide.topAnchor),
            layoutBottom.centerXAnchor.constraint(equalTo: layoutBottomContainer.layoutMarginsGuide.centerXAnchor),
            layoutBottom.centerYAnchor.constraint(equalTo: layoutBottomContainer.layoutMarginsGuide.centerYAnchor),

            screenBottomContainer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            screenBottomContainer.topAnchor.constraint(greaterThanOrEqualTo: toggleStack.bottomAnchor),
            view.bottomAnchor.constraint(equalTo: screenBottomContainer.bottomAnchor),

            screenBottom.topAnchor.constraint(equalTo: screenBottomContainer.layoutMarginsGuide.topAnchor),
            screenBottom.leadingAnchor.constraint(equalTo: screenBottomContainer.layoutMarginsGuide.leadingAnchor),
            screenBottom.centerXAnchor.constraint(equalTo: screenBottomContainer.layoutMarginsGuide.centerXAnchor),
            layoutBottomContainer.topAnchor.constraint(greaterThanOrEqualTo: screenBottom.bottomAnchor, constant: 12)
        ])

    }

    @objc private func togglePalette(_ sender: UISwitch) {
        guard let tvc = tabBarController as? AccessoryTabBarController else { return }
        tvc.setPaletteViewController(sender.isOn ? PaletteViewController() : nil, animated: true)
    }

}

final class SecondViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "Second"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)

        navigationController?.tabBarItem.title = title
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let bigLabel = UILabel()
        bigLabel.translatesAutoresizingMaskIntoConstraints = false
        bigLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        bigLabel.text = "Second View"
        bigLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(bigLabel)

        let littleLabel = UILabel()
        littleLabel.translatesAutoresizingMaskIntoConstraints = false
        littleLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        littleLabel.text = "Loaded by \(type(of: self))"
        littleLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(littleLabel)

        NSLayoutConstraint.activate([
            bigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bigLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            littleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            littleLabel.topAnchor.constraint(equalTo: bigLabel.bottomAnchor, constant: 12)
        ])

        self.view = view
    }

}

final class ThirdViewController: UIViewController {

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        title = "Third"

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        self.view = view

        let bigLabel = UILabel()
        bigLabel.translatesAutoresizingMaskIntoConstraints = false
        bigLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        bigLabel.text = "Third View"
        bigLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(bigLabel)

        let littleLabel = UILabel()
        littleLabel.translatesAutoresizingMaskIntoConstraints = false
        littleLabel.font = UIFont.preferredFont(forTextStyle: .callout)
        littleLabel.text = "Loaded by \(type(of: self))"
        littleLabel.adjustsFontForContentSizeCategory = true
        view.addSubview(littleLabel)

        NSLayoutConstraint.activate([
            bigLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bigLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            littleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            littleLabel.topAnchor.constraint(equalTo: bigLabel.bottomAnchor, constant: 12)
        ])
    }

    @objc private func close(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }

}

final class PaletteViewController: UIViewController {

    private var heightConstraint: NSLayoutConstraint!

    override func loadView() {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.distribution = .equalSpacing
        view.isLayoutMarginsRelativeArrangement = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap)))

        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Show modal", for: .normal)
        button.addTarget(self, action: #selector(showModal), for: .primaryActionTriggered)
        view.addArrangedSubview(button)

        let button2 = UIButton(type: .system)
        button2.translatesAutoresizingMaskIntoConstraints = false
        button2.setTitle("Increase height", for: .normal)
        button2.addTarget(self, action: #selector(shrink), for: .primaryActionTriggered)
        view.addArrangedSubview(button2)

        heightConstraint = view.heightAnchor.constraint(equalToConstant: 64)
        heightConstraint.isActive = true

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("Palette view did load")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("Palette view will appear")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        print("Palette view did appear")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        print("Palette view will disappear")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        print("Palette view did disappear")
    }

    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)

        print("Palette will move to \(String(describing: parent))")
    }

    override func didMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)

        print("Palette did move to \(String(describing: parent))")
    }

    @objc private func showModal(_ sender: UIButton) {
        present(UINavigationController(rootViewController: ThirdViewController()), animated: true)
    }

    @objc private func shrink(_ sender: UIButton) {
        setPreferredHeightAnimated(32) { _ in
            sender.isEnabled = false
        }
    }

    private func setPreferredHeightAnimated(_ height: CGFloat, completion: ((Bool) -> Void)?) {
        heightConstraint.constant = 32

        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 0, options: .beginFromCurrentState, animations: view.layoutIfNeeded, completion: completion)
    }

    @objc private func tap(_ sender: UITapGestureRecognizer) {
        print("Tapped!")
    }

}

let tvc = AccessoryTabBarController()
tvc.viewControllers = [
    UINavigationController(rootViewController: FirstViewController()),
    UINavigationController(rootViewController: SecondViewController())
]
PlaygroundPage.current.liveView = tvc
