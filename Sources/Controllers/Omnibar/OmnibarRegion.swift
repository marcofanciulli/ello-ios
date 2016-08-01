////
///  OmnibarRegion.swift
//

public enum OmnibarRegion {
    case Image(UIImage)
    case ImageData(UIImage, NSData, String)
    case ImageURL(NSURL)
    case AttributedText(NSAttributedString)
    case Spacer
    case Error(NSURL)

    public static func Text(str: String) -> OmnibarRegion {
        return AttributedText(ElloAttributedString.style(str))
    }
}

public extension OmnibarRegion {
    var editable: Bool {
        switch self {
        case .ImageData, .Image: return true
        case let .AttributedText(text): return text.string.characters.count > 0
        default: return false
        }
    }

    var text: NSAttributedString? {
        switch self {
        case let .AttributedText(text): return text
        default: return nil
        }
    }

    var image: UIImage? {
        switch self {
        case let .Image(image): return image
        case let .ImageData(image, _, _): return image
        default: return nil
        }
    }

    var isText: Bool {
        switch self {
        case .AttributedText: return true
        default: return false
        }
    }

    var isImage: Bool {
        switch self {
        case .ImageData, .Image: return true
        default: return false
        }
    }

    var empty: Bool {
        switch self {
        case let .AttributedText(text): return text.string.characters.count == 0
        case .Spacer: return true
        default: return false
        }
    }

    var isSpacer: Bool {
        switch self {
        case .Spacer: return true
        default: return false
        }
    }

    var reuseIdentifier: String {
        switch self {
        case .ImageData, .Image: return OmnibarImageCell.reuseIdentifier()
        case .ImageURL: return OmnibarImageDownloadCell.reuseIdentifier()
        case .AttributedText: return OmnibarTextCell.reuseIdentifier()
        case .Spacer: return OmnibarRegion.OmnibarSpacerCell
        case .Error: return OmnibarErrorCell.reuseIdentifier()
        }
    }

    static let OmnibarSpacerCell = "OmnibarSpacerCell"
}

public extension OmnibarRegion {
    var rawRegion: NSObject? {
        switch self {
        case let .Image(image): return image
        case let .ImageData(image, _, _): return image
        case let .AttributedText(text): return text
        default: return nil
        }
    }
    static func fromRaw(obj: NSObject) -> OmnibarRegion? {
        if let text = obj as? NSAttributedString {
            return .AttributedText(text)
        }
        else if let image = obj as? UIImage {
            return .Image(image)
        }
        return nil
    }
}

extension OmnibarRegion: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        switch self {
        case let .Image(image): return "Image(size: \(image.size))"
        case let .ImageData(image, _, _): return "ImageData(size: \(image.size))"
        case let .ImageURL(url): return "ImageURL(url: \(url))"
        case let .AttributedText(text): return "AttributedText(text: \(text.string))"
        case .Spacer: return "Spacer()"
        case .Error: return "Error()"
        }
    }

    public var debugDescription: String {
        return description
    }

}
