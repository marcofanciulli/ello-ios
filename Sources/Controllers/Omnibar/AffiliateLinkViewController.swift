////
///  AffiliateLinkViewController.swift
//

public protocol AffiliateLinkControllerDelegate: class {
    func submitAffiliateLink(url: NSURL)
}

public class AffiliateLinkViewController: UIViewController {
    var screen: AffiliateLinkScreen { return self.view as! AffiliateLinkScreen }
    weak var delegate: AffiliateLinkControllerDelegate?

    required public init() {
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let screen = AffiliateLinkScreen()
        screen.delegate = self
        view = screen
    }

}

extension AffiliateLinkViewController: AffiliateLinkDelegate {

    public func closeModal() {
        dismissViewControllerAnimated(true, completion: nil)
    }

    public func submitLink(url: NSURL) {
        delegate?.submitAffiliateLink(url)
    }

}
