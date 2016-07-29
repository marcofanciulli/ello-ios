////
///  OmnibarScreenAffiliateLinkControllerDelegate.swift
//

extension OmnibarScreen: AffiliateLinkControllerDelegate {

    public func submitAffiliateLink(url: NSURL) {
        affiliateURL = url
        regionsTableView.reloadData()
    }

    public func clearAffiliateLink() {
        affiliateURL = nil
        regionsTableView.reloadData()
    }

}
