////
///  AffiliateLinkViewController.swift
//

public protocol AffiliateLinkControllerDelegate: class {
    func submitAffiliateLink(url: NSURL)
    func clearAffiliateLink()
}

public class AffiliateLinkViewController: UIViewController {
    var screen: AffiliateLinkScreen { return self.view as! AffiliateLinkScreen }
    var affiliateURL: NSURL?
    weak var delegate: AffiliateLinkControllerDelegate?

    required public init(affiliateURL: NSURL?) {
        self.affiliateURL = affiliateURL
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let screen = AffiliateLinkScreen()
        screen.affiliateURL = affiliateURL
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

    public func clearLink() {
        delegate?.clearAffiliateLink()
    }

}
