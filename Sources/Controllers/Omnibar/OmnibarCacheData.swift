////
///  OmnibarCacheData.swift
//

public class OmnibarCacheData: NSObject, NSCoding {
    public var regions: [NSObject]

    public override init() {
        regions = [NSObject]()
        super.init()
    }

// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(regions, forKey: "regions")
    }

    required public init?(coder: NSCoder) {
        let decoder = Coder(coder)
        regions = decoder.decodeKey("regions")
        super.init()
    }

}
