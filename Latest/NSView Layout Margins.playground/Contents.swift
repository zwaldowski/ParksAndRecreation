import Cocoa
import PlaygroundSupport

class InitialLiveViewController: NSViewController {

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 120, height: 120))

        let butt = NSButton(title: "Show Sheet", target: self, action: #selector(showSheet))
        butt.frame = view.bounds
        view.addSubview(butt)
    }

    @objc func showSheet(_ sender: Any) {
        let vc = LayoutGuidesSheetViewController()
        presentAsSheet(vc)
    }

}

class LayoutGuidesSheetViewController: NSViewController {

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 320, height: 480))
        view.layoutMargins = NSEdgeInsets(top: 0, left: 120, bottom: 0, right: 120)

        let redView = NSBox()
        redView.translatesAutoresizingMaskIntoConstraints = false
        redView.boxType = .custom
        redView.fillColor = .red
        redView.borderWidth = 0
        view.addSubview(redView)

        let redLabel = NSTextField(labelWithString: "Safe Area")
        redLabel.translatesAutoresizingMaskIntoConstraints = false
        redLabel.textColor = .white
        redView.addSubview(redLabel)

        let blueView = NSBox()
        blueView.translatesAutoresizingMaskIntoConstraints = false
        blueView.boxType = .custom
        blueView.fillColor = .blue
        blueView.borderWidth = 0
        view.addSubview(blueView)

        let blueLabel = NSTextField(labelWithString: "Layout Margins")
        blueLabel.translatesAutoresizingMaskIntoConstraints = false
        blueLabel.textColor = .white
        blueView.addSubview(blueLabel)

        let yellowView = NSBox()
        yellowView.translatesAutoresizingMaskIntoConstraints = false
        yellowView.boxType = .custom
        yellowView.fillColor = .yellow
        yellowView.borderWidth = 0
        view.addSubview(yellowView)

        let yellowLabel = NSTextField(wrappingLabelWithString: """
            Readable Content
        """)
        yellowLabel.translatesAutoresizingMaskIntoConstraints = false
        yellowLabel.textColor = .black
        yellowLabel.alignment = .center
        yellowView.addSubview(yellowLabel)

        NSLayoutConstraint.activate([
            // Bind the red view to the edges of the safe area.
            redView.topAnchor.constraint(equalTo: view.windowContentLayoutGuide.topAnchor),
            redView.leadingAnchor.constraint(equalTo: view.windowContentLayoutGuide.leadingAnchor),
            view.windowContentLayoutGuide.bottomAnchor.constraint(equalTo: redView.bottomAnchor),
            view.windowContentLayoutGuide.trailingAnchor.constraint(equalTo: redView.trailingAnchor),

            // Bind the red view's label to the left, vertically centered.
            redLabel.leadingAnchor.constraint(equalTo: redView.leadingAnchor, constant: 8),
            redLabel.topAnchor.constraint(greaterThanOrEqualTo: redView.topAnchor, constant: 8),
            redLabel.centerYAnchor.constraint(equalTo: redView.centerYAnchor),

            // Bind the blue view to the edges of the layout margins.
            blueView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            blueView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            view.layoutMarginsGuide.bottomAnchor.constraint(equalTo: blueView.bottomAnchor),
            view.layoutMarginsGuide.trailingAnchor.constraint(equalTo: blueView.trailingAnchor),

            // Bind the blue view's label to the left, vertically centered.
            blueLabel.leadingAnchor.constraint(equalTo: blueView.leadingAnchor, constant: 8),
            blueLabel.topAnchor.constraint(greaterThanOrEqualTo: blueView.topAnchor, constant: 8),
            blueLabel.centerYAnchor.constraint(equalTo: blueView.centerYAnchor),

            // Bind the yellow view to the edges of the readable content.
            yellowView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            yellowView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            view.readableContentGuide.bottomAnchor.constraint(equalTo: yellowView.bottomAnchor),
            view.readableContentGuide.trailingAnchor.constraint(equalTo: yellowView.trailingAnchor),

            // Bind the yellow view's label to the center.
            yellowLabel.leadingAnchor.constraint(greaterThanOrEqualTo: yellowView.leadingAnchor, constant: 8),
            yellowLabel.topAnchor.constraint(greaterThanOrEqualTo: yellowView.topAnchor, constant: 8),
            yellowLabel.centerXAnchor.constraint(equalTo: yellowView.centerXAnchor),
            yellowLabel.centerYAnchor.constraint(equalTo: yellowView.centerYAnchor),
        ])
    }

    @objc func cancel(_ sender: Any?) {
        presentingViewController?.dismiss(self)
    }

}

PlaygroundPage.current.liveView = InitialLiveViewController()
