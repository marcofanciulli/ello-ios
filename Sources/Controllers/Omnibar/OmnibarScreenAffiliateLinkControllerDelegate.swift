////
///  OmnibarScreenAffiliateLinkControllerDelegate.swift
//

extension OmnibarScreen: AffiliateLinkControllerDelegate {

    public func submitAffiliateLink(url: NSURL) {
        delegate?.submitAffiliateLink(url)
    }

    public func clearAffiliateLink() {
        delegate?.clearAffiliateLink()
    }

}
