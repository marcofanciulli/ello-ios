////
///  OmnibarScreenAffiliateLinkControllerDelegate.swift
//

extension OmnibarScreen: AffiliateLinkControllerDelegate {

    public func submitAffiliateLink(url: NSURL) {
        affiliateURL = url
    }

    public func clearAffiliateLink() {
        affiliateURL = nil
    }

}
