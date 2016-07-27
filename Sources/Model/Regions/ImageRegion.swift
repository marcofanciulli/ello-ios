////
///  ImageRegion.swift
//

import Crashlytics
import Foundation
import SwiftyJSON

let ImageRegionVersion = 1

@objc(ImageRegion)
public final class ImageRegion: JSONAble, Regionable {
    public var isRepost: Bool  = false

    // required
    public let alt: String
    // optional
    public var url: NSURL?
    public var affiliateURL: NSURL?

    // links
    public var asset: Asset? { return getLinkObject("assets") as? Asset }

// MARK: Initialization

    public init(alt: String)
    {
        self.alt = alt
        super.init(version: ImageRegionVersion)
    }

// MARK: NSCoding

    public required init(coder aDecoder: NSCoder) {
        let decoder = Coder(aDecoder)
        // required
        self.alt = decoder.decodeKey("alt")
        self.isRepost = decoder.decodeKey("isRepost")
        // optional
        self.url = decoder.decodeOptionalKey("url")
        self.affiliateURL = decoder.decodeOptionalKey("affiliateURL")
        super.init(coder: decoder.coder)
    }

    public override func encodeWithCoder(encoder: NSCoder) {
        let coder = Coder(encoder)
        // required
        coder.encodeObject(alt, forKey: "alt")
        coder.encodeObject(isRepost, forKey: "isRepost")
        // optional
        coder.encodeObject(url, forKey: "url")
        coder.encodeObject(affiliateURL, forKey: "affiliateURL")
        super.encodeWithCoder(coder.coder)
    }

// MARK: JSONAble

    override public class func fromJSON(data: [String: AnyObject], fromLinked: Bool = false) -> JSONAble {
        let json = JSON(data)
        Crashlytics.sharedInstance().setObjectValue(json.rawString(), forKey: CrashlyticsKey.ImageRegionFromJSON.rawValue)
        // create region
        let imageRegion = ImageRegion(
            alt: json["data"]["alt"].stringValue
            )
        // optional
        if let urlStr = json["data"]["url"].string {
            imageRegion.url = NSURL(string: urlStr)
        }
        if let urlStr = json["link_url"].string {
            imageRegion.affiliateURL = NSURL(string: urlStr)
        }
        // links
        imageRegion.links = data["links"] as? [String: AnyObject]
        return imageRegion
    }

// MARK: Regionable

    public var kind: String { return RegionKind.Image.rawValue }

    public func coding() -> NSCoding {
        return self
    }

    public func toJSON() -> [String: AnyObject] {
        var json: [String: AnyObject]
        if let url = self.url?.absoluteString {
            json = [
                "kind": self.kind,
                "data": [
                    "alt": alt ?? "",
                    "url": url
                ],
            ]
        }
        else {
            json = [
                "kind": self.kind,
                "data": [:]
            ]
        }

        if let affiliateURL = affiliateURL {
            json["link_url"] = affiliateURL
        }
        return json
    }
}
