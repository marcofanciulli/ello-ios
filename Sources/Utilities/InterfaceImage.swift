////
///  InterfaceImage.swift
//

import UIKit
import SVGKit


public enum InterfaceImage: String {
    public enum Style {
        case Normal
        case White
        case Selected
        case Disabled
        case Red
    }

    case ElloLogo = "ello_logo"

    // Postbar Icons
    case Eye = "eye"
    case Heart = "hearts"
    case GiantHeart = "hearts_giant"
    case Repost = "repost"
    case Share = "share"
    case XBox = "xbox"
    case Pencil = "pencil"
    case Reply = "reply"
    case Flag = "flag"

    // Notification Icons
    case Comments = "bubble"
    case Invite = "relationships"

    // TabBar Icons
    case Sparkles = "sparkles"
    case Bolt = "bolt"
    case Omni = "omni"
    case Person = "person"
    case CircBig = "circbig"
    case NarrationPointer = "narration_pointer"

    // Validation States
    case ValidationLoading = "circ"
    case ValidationError = "x_red"
    case ValidationOK = "check_green"

    // NavBar Icons
    case Search = "search"
    case Burger = "burger"

    // Grid/List Icons
    case Grid = "grid"
    case List = "list"

    // Omnibar
    case Reorder = "reorder"
    case Camera = "camera"
    case Check = "check"
    case Arrow = "arrow"
    case Link = "link"
    case BreakLink = "breaklink"

    // Commenting
    case ReplyAll = "replyall"
    case BubbleBody = "bubble_body"
    case BubbleTail = "bubble_tail"

    // Relationship
    case Star = "star"

    // Alert
    case Question = "question"

    // Affiliate
    case Affiliate = "$"
    case AddAffiliate = "$_add"
    case SetAffiliate = "$_set"

    // Generic
    case X = "x"
    case Dots = "dots"
    case DotsLight = "dots_light"
    case PlusSmall = "plussmall"
    case CheckSmall = "checksmall"
    case AngleBracket = "abracket"

    // Embeds
    case AudioPlay = "embetter_audio_play"
    case VideoPlay = "embetter_video_play"

    func image(style: Style) -> UIImage? {
        switch style {
        case .Normal:   return normalImage
        case .White:    return whiteImage
        case .Selected: return selectedImage
        case .Disabled: return disabledImage
        case .Red:      return redImage
        }
    }

    var overrideImageSize: CGSize? {
        switch self {
        case .Affiliate: return CGSize(width: 6, height: 11)
        case .AddAffiliate: return CGSize(width: 12, height: 16.5)
        case .SetAffiliate: return CGSize(width: 12, height: 16.5)
        default: return nil
        }
    }

    private func svgNamed(name: String) -> UIImage {
        let svgkImage = SVGKImage(named: "\(name).svg")
        if let overrideImageSize = overrideImageSize {
            svgkImage.size = overrideImageSize
        }
        return svgkImage.UIImage
    }

    var normalImage: UIImage! {
        switch self {
        case .ElloLogo,
            .Affiliate,
            .GiantHeart,
            .AudioPlay,
            .VideoPlay,
            .BubbleTail,
            .NarrationPointer,
            .ValidationError,
            .ValidationOK:
            return svgNamed(self.rawValue)
        default:
            return svgNamed("\(self.rawValue)_normal")
        }
    }
    var selectedImage: UIImage! {
        return svgNamed("\(self.rawValue)_selected")
    }
    var whiteImage: UIImage? {
        switch self {
        case .AngleBracket,
             .Arrow,
             .BreakLink,
             .BubbleBody,
             .Camera,
             .CheckSmall,
             .Comments,
             .Heart,
             .Invite,
             .Link,
             .Pencil,
             .PlusSmall,
             .Repost,
             .Star,
             .X:
            return svgNamed("\(self.rawValue)_white")
        default:
            return nil
        }
    }
    var disabledImage: UIImage? {
        switch self {
        case .Repost, .AngleBracket, .AddAffiliate:
            return svgNamed("\(self.rawValue)_disabled")
        default:
            return nil
        }
    }
    var redImage: UIImage? {
        switch self {
        case .X:
            return svgNamed("\(self.rawValue)_red")
        default:
            return nil
        }
    }
}
