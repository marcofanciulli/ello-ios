////
///  OmnibarImageData.swift
//

public class OmnibarImageData: NSObject, NSCoding {
    public var image: UIImage?
    public var data: NSData?
    public var type: NSString?

// MARK: NSCoding

    public func encodeWithCoder(encoder: NSCoder) {
        if let image = image {
            encoder.encodeObject(image, forKey: "image")
        }
        if let data = data {
            encoder.encodeObject(data, forKey: "data")
        }
        if let type = type {
            encoder.encodeObject(type, forKey: "type")
        }
    }

    required public init?(coder: NSCoder) {
        let decoder = Coder(coder)
        image = decoder.decodeKey("image")
        data = decoder.decodeKey("data")
        type = decoder.decodeKey("type")
        super.init()
    }
}
