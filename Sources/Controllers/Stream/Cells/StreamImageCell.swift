////
///  StreamImageCell.swift
//

import FLAnimatedImage
import PINRemoteImage
import Alamofire

public class StreamImageCell: StreamRegionableCell {
    static let reuseIdentifier = "StreamImageCell"

    // this little hack prevents constraints from breaking on initial load
    override public var bounds: CGRect {
        didSet {
          contentView.frame = bounds
        }
    }

    public struct Size {
        static let bottomMargin: CGFloat = 10
        static let singleColumnFailWidth: CGFloat = 140
        static let singleColumnFailHeight: CGFloat = 160
        static let multiColumnFailWidth: CGFloat = 70
        static let multiColumnFailHeight: CGFloat = 80
    }

    @IBOutlet public weak var imageView: FLAnimatedImageView!
    @IBOutlet public weak var imageButton: UIView!
    @IBOutlet public weak var affiliateButton: UIButton?
    @IBOutlet public weak var affiliateGreen: UIView?
    @IBOutlet public weak var circle: PulsingCircle!
    @IBOutlet public weak var failImage: UIImageView!
    @IBOutlet public weak var failBackgroundView: UIView!
    @IBOutlet public weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var failWidthConstraint: NSLayoutConstraint!
    @IBOutlet private weak var failHeightConstraint: NSLayoutConstraint!

    // not used in StreamEmbedCell
    @IBOutlet public weak var largeImagePlayButton: UIImageView?
    @IBOutlet public weak var imageRightConstraint: NSLayoutConstraint!

    weak var streamImageCellDelegate: StreamImageCellDelegate?
    weak var streamEditingDelegate: StreamEditingDelegate?
    public var isGif = false
    public typealias OnHeightMismatch = (CGFloat) -> Void
    public var onHeightMismatch: OnHeightMismatch?
    public var tallEnoughForFailToShow = true
    public var presentedImageUrl: NSURL?
    public var affiliateURL: NSURL? {
        didSet {
            let hidden = (affiliateURL == nil)
            affiliateButton?.hidden = hidden
            affiliateGreen?.hidden = hidden
        }
    }
    var serverProvidedAspectRatio: CGFloat?
    public var isLargeImage: Bool {
        get { return !(largeImagePlayButton?.hidden ?? true) }
        set {
            largeImagePlayButton?.image = InterfaceImage.VideoPlay.normalImage
            largeImagePlayButton?.hidden = !newValue
        }
    }
    public var isGridView: Bool = false {
        didSet {
            if isGridView {
                failWidthConstraint.constant = Size.multiColumnFailWidth
                failHeightConstraint.constant = Size.multiColumnFailHeight
            }
            else {
                failWidthConstraint.constant = Size.singleColumnFailWidth
                failHeightConstraint.constant = Size.singleColumnFailHeight
            }
        }
    }

    private var imageSize: CGSize?
    private var aspectRatio: CGFloat? {
        guard let imageSize = imageSize else { return nil }
        return imageSize.width / imageSize.height
    }

    var calculatedHeight: CGFloat? {
        guard let aspectRatio = aspectRatio else {
            return nil
        }
        return frame.width / aspectRatio
    }

    override public func awakeFromNib() {
        super.awakeFromNib()
        if let playButton = largeImagePlayButton {
            playButton.image = InterfaceImage.VideoPlay.normalImage
        }
        if let affiliateButton = affiliateButton, affiliateGreen = affiliateGreen {
            affiliateButton.hidden = true
            affiliateGreen.hidden = true
            affiliateButton.setTitle(nil, forState: .Normal)
            affiliateButton.setImage(.Affiliate, imageStyle: .Normal, forState: .Normal)
            affiliateGreen.backgroundColor = .greenD1()
            affiliateGreen.layer.cornerRadius = affiliateGreen.frame.size.width / 2
        }

        let doubleTapGesture = UITapGestureRecognizer()
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.addTarget(self, action: #selector(imageDoubleTapped(_:)))
        imageButton.addGestureRecognizer(doubleTapGesture)

        let singleTapGesture = UITapGestureRecognizer()
        singleTapGesture.numberOfTapsRequired = 1
        singleTapGesture.addTarget(self, action: #selector(imageTapped))
        singleTapGesture.requireGestureRecognizerToFail(doubleTapGesture)
        imageButton.addGestureRecognizer(singleTapGesture)

        let longPressGesture = UILongPressGestureRecognizer()
        longPressGesture.addTarget(self, action: #selector(imageLongPressed(_:)))
        imageButton.addGestureRecognizer(longPressGesture)
    }

    public func setImageURL(url: NSURL) {
        imageView.image = nil
        imageView.alpha = 0
        circle.pulse()
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.whiteColor()
        loadImage(url)
    }

    public func setImage(image: UIImage) {
        imageView.pin_cancelImageDownload()
        imageView.image = image
        imageView.alpha = 0
        failImage.hidden = true
        failImage.alpha = 0
        imageView.backgroundColor = UIColor.whiteColor()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        guard let aspectRatio = aspectRatio, imageSize = imageSize else { return }

        let width = min(imageSize.width, self.frame.width)
        let actualHeight: CGFloat = ceil(width / aspectRatio) + Size.bottomMargin
        if actualHeight != frame.height {
            self.onHeightMismatch?(actualHeight)
        }

        if let affiliateGreen = affiliateGreen {
            affiliateGreen.layer.cornerRadius = affiliateGreen.frame.size.width / 2
        }
    }

    private func loadImage(url: NSURL) {
        self.imageView.pin_setImageFromURL(url) { result in
            let success = result.image != nil || result.animatedImage != nil
            let isAnimated = result.animatedImage != nil
            if success {
                let imageSize = isAnimated ? result.animatedImage.size : result.image.size
                self.imageSize = imageSize

                if self.serverProvidedAspectRatio == nil {
                    postNotification(StreamNotification.AnimateCellHeightNotification, value: self)
                }

                if result.resultType != .MemoryCache {
                    self.imageView.alpha = 0
                    UIView.animateWithDuration(0.3,
                        delay:0.0,
                        options:UIViewAnimationOptions.CurveLinear,
                        animations: {
                            self.imageView.alpha = 1.0
                        }, completion: { _ in
                            self.circle.stopPulse()
                        })
                }
                else {
                    self.imageView.alpha = 1.0
                    self.circle.stopPulse()
                }

                self.layoutIfNeeded()
            }
            else {
                self.imageLoadFailed()
            }
        }
    }

    private func imageLoadFailed() {
        affiliateButton?.hidden = true
        affiliateGreen?.hidden = true
        failImage.hidden = false
        failBackgroundView.hidden = false
        circle.stopPulse()
        imageSize = nil
        largeImagePlayButton?.hidden = true
        nextTick { postNotification(StreamNotification.AnimateCellHeightNotification, value: self) }
        UIView.animateWithDuration(0.15) {
            self.failImage.alpha = 1.0
            self.imageView.backgroundColor = UIColor.greyF1()
            self.failBackgroundView.backgroundColor = UIColor.greyF1()
            self.imageView.alpha = 1.0
            self.failBackgroundView.alpha = 1.0
        }
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        imageButton.userInteractionEnabled = true
        onHeightMismatch = nil
        imageView.image = nil
        imageView.animatedImage = nil
        imageView.pin_cancelImageDownload()
        imageRightConstraint?.constant = 0
        affiliateButton?.hidden = true
        affiliateGreen?.hidden = true

        hideBorder()
        isGif = false
        presentedImageUrl = nil
        isLargeImage = false
        failImage.hidden = true
        failImage.alpha = 0
        failBackgroundView.hidden = true
        failBackgroundView.alpha = 0
    }

    @IBAction func imageTapped() {
        streamImageCellDelegate?.imageTapped(self.imageView, cell: self)
    }

    @IBAction func affiliateTapped() {
        guard let affiliateURL = affiliateURL else {
            return
        }
        postNotification(ExternalWebNotification, value: affiliateURL.URLString)
    }

    @IBAction func imageDoubleTapped(gesture: UIGestureRecognizer) {
        let location = gesture.locationInView(nil)
        streamEditingDelegate?.cellDoubleTapped(self, location: location)
    }

    @IBAction func imageLongPressed(gesture: UIGestureRecognizer) {
        if gesture.state == .Began {
            streamEditingDelegate?.cellLongPressed(self)
        }
    }
}
