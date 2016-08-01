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

    var normalImage: UIImage! {
        switch self {
        case .Affiliate:
            let svgkImage = SVGKImage(named: "\(self.rawValue).svg")
            svgkImage.size = CGSize(width: 6, height: 11)
            return svgkImage.UIImage
        case .AddAffiliate:
            let svgkImage = SVGKImage(named: "\(self.rawValue)_normal.svg")
            svgkImage.size = CGSize(width: 9, height: 16.5)
            return svgkImage.UIImage
        case .ElloLogo,
            .GiantHeart,
            .AudioPlay,
            .VideoPlay,
            .BubbleTail,
            .NarrationPointer,
            .ValidationError,
            .ValidationOK:
            return SVGKImage(named: "\(self.rawValue).svg").UIImage
        default:
            return SVGKImage(named: "\(self.rawValue)_normal.svg").UIImage
        }
    }
    var selectedImage: UIImage! {
        switch self {
        case .AddAffiliate:
            let svgkImage = SVGKImage(named: "\(self.rawValue)_selected.svg")
            svgkImage.size = CGSize(width: 12, height: 22)
            return svgkImage.UIImage
        default:
            return SVGKImage(named: "\(self.rawValue)_selected.svg").UIImage
        }
    }
    var whiteImage: UIImage! {
        return SVGKImage(named: "\(self.rawValue)_white.svg").UIImage
    }
    var disabledImage: UIImage! {
        switch self {
        case .Repost, .AngleBracket:
            return SVGKImage(named: "\(self.rawValue)_disabled.svg").UIImage
        default:
            return nil
        }
    }
    var redImage: UIImage! { return SVGKImage(named: "\(self.rawValue)_red.svg").UIImage }
}
