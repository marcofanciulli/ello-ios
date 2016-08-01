////
///  OmnibarViewController.swift
//

import Crashlytics
import SwiftyUserDefaults
import PINRemoteImage


public class OmnibarViewController: BaseElloViewController {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?

    override public var tabBarItem: UITabBarItem? {
        get { return UITabBarItem.item(.Omni) }
        set { self.tabBarItem = newValue }
    }

    var previousTab: ElloTab = .DefaultTab
    var parentPost: Post?
    var editPost: Post?
    var editComment: ElloComment?
    var rawEditBody: [Regionable]?
    var defaultText: String?
    var canGoBack: Bool = true {
        didSet {
            if isViewLoaded() {
                screen.canGoBack = canGoBack
            }
        }
    }

    typealias CommentSuccessListener = (comment: ElloComment) -> Void
    typealias PostSuccessListener = (post: Post) -> Void
    var commentSuccessListener: CommentSuccessListener?
    var postSuccessListener: PostSuccessListener?

    var _mockScreen: OmnibarScreenProtocol?
    public var screen: OmnibarScreenProtocol {
        set(screen) { _mockScreen = screen }
        get {
            if let mock = _mockScreen { return mock }
            return self.view as! OmnibarScreen
        }
    }

    convenience public init(parentPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        parentPost = post
    }

    convenience public init(editComment comment: ElloComment) {
        self.init(nibName: nil, bundle: nil)
        editComment = comment
        PostService().loadComment(comment.postId, commentId: comment.id, success: { (comment, _) in
            self.rawEditBody = comment.body
            if let body = comment.body where self.isViewLoaded() {
                self.prepareScreenForEditing(body, isComment: true)
            }
        })
    }

    convenience public init(editPost post: Post) {
        self.init(nibName: nil, bundle: nil)
        editPost = post
        PostService().loadPost(post.id,
            needsComments: false,
            success: { (post, _) in
                self.rawEditBody = post.body
                if let body = post.body where self.isViewLoaded() {
                    self.prepareScreenForEditing(body, isComment: false)
                }
            })
    }

    convenience public init(parentPost post: Post, defaultText: String?) {
        self.init(parentPost: post)
        self.defaultText = defaultText
    }

    convenience public init(defaultText: String?) {
        self.init(nibName: nil, bundle: nil)
        self.defaultText = defaultText
    }

    override func didSetCurrentUser() {
        super.didSetCurrentUser()
        if isViewLoaded() {
            if let cachedImage = TemporaryCache.load(.Avatar) {
                screen.avatarImage = cachedImage
            }
            else {
                screen.avatarURL = currentUser?.avatarURL()
            }
        }
    }

    func onCommentSuccess(listener: CommentSuccessListener) {
        commentSuccessListener = listener
    }

    func onPostSuccess(listener: PostSuccessListener) {
        postSuccessListener = listener
    }

    override public func loadView() {
        self.view = OmnibarScreen(frame: UIScreen.mainScreen().bounds)

        screen.canGoBack = canGoBack
        screen.currentUser = currentUser
        var defaultRegions: [Regionable] = []
        if let text = defaultText {
            defaultRegions = [TextRegion(content: text)]
        }

        if editPost != nil {
            screen.title = InterfaceString.Omnibar.EditPostTitle
            screen.submitTitle = InterfaceString.Omnibar.EditPostButton
            screen.isEditing = true
            if let rawEditBody = rawEditBody {
                prepareScreenForEditing(rawEditBody, isComment: false)
            }
        }
        else if editComment != nil {
            screen.title = InterfaceString.Omnibar.EditCommentTitle
            screen.submitTitle = InterfaceString.Omnibar.EditCommentButton
            screen.isEditing = true
            if let rawEditBody = rawEditBody {
                prepareScreenForEditing(rawEditBody, isComment: true)
            }
        }
        else {
            let isComment: Bool
            if parentPost != nil {
                screen.title = InterfaceString.Omnibar.CreateCommentTitle
                screen.submitTitle = InterfaceString.Omnibar.CreateCommentButton
                isComment = true
            }
            else {
                screen.title = ""
                screen.submitTitle = InterfaceString.Omnibar.CreatePostButton
                isComment = false
            }
            prepareScreenForEditing(defaultRegions, isComment: isComment)

            if let fileName = omnibarDataName(),
                data: NSData = Tmp.read(fileName)
                where (defaultText ?? "") == ""
            {
                if let omnibarData = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? OmnibarCacheData {
                    let regions: [OmnibarRegion] = omnibarData.regions.flatMap { obj in
                        if let region = OmnibarRegion.fromRaw(obj) {
                            return region
                        }
                        return nil
                    }
                    Tmp.remove(fileName)
                    screen.regions = regions
                }
            }
        }
        screen.delegate = self
    }

    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        UIApplication.sharedApplication().statusBarStyle = .LightContent

        if let previousTab = elloTabBarController?.previousTab {
            self.previousTab = previousTab
        }

        if let cachedImage = TemporaryCache.load(.Avatar) {
            screen.avatarImage = cachedImage
        }
        else {
            screen.avatarURL = currentUser?.avatarURL()
        }

        keyboardWillShowObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillShow, block: self.keyboardWillShow)
        keyboardWillHideObserver = NotificationObserver(notification: Keyboard.Notifications.KeyboardWillHide, block: self.keyboardWillHide)
        view.setNeedsLayout()

        let isEditing = (editPost != nil || editComment != nil)
        if isEditing {
            if rawEditBody == nil {
                ElloHUD.showLoadingHudInView(self.view)
            }
        }
        else {
            let isShowingNarration = elloTabBarController?.shouldShowNarration ?? false
            let isPosting = !screen.interactionEnabled
            if !isShowingNarration && !isPosting && presentedViewController == nil {
                // desired behavior: animate the keyboard in when this screen is
                // shown.  without the delay, the keyboard just appears suddenly.
                delay(0) {
                    self.screen.startEditing()
                }
            }
        }

        screen.updateButtons()
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        elloTabBarController?.setTabBarHidden(false, animated: animated)
        Crashlytics.sharedInstance().setObjectValue("Omnibar", forKey: CrashlyticsKey.StreamName.rawValue)
    }

    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        screen.stopEditing()

        if let keyboardWillShowObserver = keyboardWillShowObserver {
            keyboardWillShowObserver.removeObserver()
            self.keyboardWillShowObserver = nil
        }
        if let keyboardWillHideObserver = keyboardWillHideObserver {
            keyboardWillHideObserver.removeObserver()
            self.keyboardWillHideObserver = nil
        }
    }

    func prepareScreenForEditing(content: [Regionable], isComment: Bool) {
        var regions: [OmnibarRegion] = []
        var affiliateURL: NSURL?
        var downloads: [(Int, NSURL)] = []  // the 'index' is used to replace the ImageURL region after it is downloaded
        for (index, region) in content.enumerate() {
            if let region = region as? TextRegion,
                attrdText = ElloAttributedString.parse(region.content)
            {
                regions.append(.AttributedText(attrdText))
            }
            else if let region = region as? ImageRegion,
                url = region.url
            {
                if let imageRegionURL = region.affiliateURL {
                    affiliateURL = imageRegionURL
                }
                downloads.append((index, url))
                regions.append(.ImageURL(url))
            }
        }
        screen.regions = regions
        screen.isComment = isComment
        screen.affiliateURL = affiliateURL

        let completed = after(downloads.count) {
            ElloHUD.hideLoadingHudInView(self.view)
        }

        for (index, imageURL) in downloads {
            PINRemoteImageManager.sharedImageManager().downloadImageWithURL(imageURL) { result in
                if let image = result.image {
                    regions[index] = .Image(image)
                }
                else if let animatedImage = result.animatedImage {
                    regions[index] = .ImageData(animatedImage.posterImage, animatedImage.data, "image/gif")
                }
                else {
                    regions[index] = .Error(imageURL)
                }
                let tmp = regions
                inForeground {
                    self.screen.regions = tmp
                    completed()
                }
            }
        }
    }

    func keyboardWillShow(keyboard: Keyboard) {
        screen.keyboardWillShow()
    }

    func keyboardWillHide(keyboard: Keyboard) {
        screen.keyboardWillHide()
    }

    private func goToPreviousTab() {
        elloTabBarController?.selectedTab = previousTab
    }

}

extension OmnibarViewController {

    public class func canEditRegions(regions: [Regionable]?) -> Bool {
        return OmnibarScreen.canEditRegions(regions)
    }
}


extension OmnibarViewController: OmnibarScreenDelegate {

    public func omnibarCancel() {
        if canGoBack {
            if let fileName = omnibarDataName() {
                var dataRegions = [NSObject]()
                for region in screen.regions {
                    if let rawRegion = region.rawRegion {
                        dataRegions.append(rawRegion)
                    }
                }
                let omnibarData = OmnibarCacheData()
                omnibarData.regions = dataRegions
                let data = NSKeyedArchiver.archivedDataWithRootObject(omnibarData)
                Tmp.write(data, to: fileName)
            }

            if parentPost != nil {
                Tracker.sharedTracker.contentCreationCanceled(.Comment)
            }
            else if editPost != nil {
                Tracker.sharedTracker.contentEditingCanceled(.Post)
            }
            else if editComment != nil {
                Tracker.sharedTracker.contentEditingCanceled(.Comment)
            }
            else {
                Tracker.sharedTracker.contentCreationCanceled(.Post)
            }
            navigationController?.popViewControllerAnimated(true)
        }
        else {
            Tracker.sharedTracker.contentCreationCanceled(.Post)
            goToPreviousTab()
        }
    }

    public func omnibarPresentController(controller: UIViewController) {
        if !(controller is AlertViewController) {
            UIApplication.sharedApplication().statusBarStyle = .LightContent
        }
        self.presentViewController(controller, animated: true, completion: nil)
    }

    public func omnibarPushController(controller: UIViewController) {
        self.navigationController?.pushViewController(controller, animated: true)
    }

    public func omnibarDismissController(controller: UIViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    public func omnibarSubmitted(regions: [OmnibarRegion], affiliateURL: NSURL?) {
        let content = generatePostContent(regions)
        guard content.count > 0 else {
            return
        }

        if let authorId = currentUser?.id {
            startPosting(authorId, content, affiliateURL: affiliateURL)
        }
        else {
            contentCreationFailed(InterfaceString.App.LoggedOutError)
        }
    }

}

// MARK: Posting the content to API
extension OmnibarViewController {

    public func generatePostContent(regions: [OmnibarRegion]) -> [PostEditingService.PostContentRegion] {
        var content: [PostEditingService.PostContentRegion] = []
        for region in regions {
            switch region {
            case let .AttributedText(attributedText):
                let textString = attributedText.string
                if textString.characters.count > 5000 {
                    contentCreationFailed(InterfaceString.Omnibar.TooLongError)
                    return []
                }

                let cleanedText = textString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                if cleanedText.characters.count > 0 {
                    content.append(.Text(ElloAttributedString.render(attributedText)))
                }
            case let .Image(image):
                content.append(.Image(image))
            case let .ImageData(image, data, contentType):
                content.append(.ImageData(image, data, contentType))
            default:
                break // there are "non submittable" types from OmnibarRegion, like Spacer and ImageURL
            }
        }
        return content
    }

    private func startPosting(authorId: String, _ content: [PostEditingService.PostContentRegion], affiliateURL: NSURL?) {
        let service: PostEditingService
        let didGoToPreviousTab: Bool

        if let parentPost = parentPost {
            service = PostEditingService(parentPost: parentPost)
            didGoToPreviousTab = false
        }
        else if let editPost = editPost {
            service = PostEditingService(editPost: editPost)
            didGoToPreviousTab = false
        }
        else if let editComment = editComment {
            service = PostEditingService(editComment: editComment)
            didGoToPreviousTab = false
        }
        else {
            service = PostEditingService()

            goToPreviousTab()
            didGoToPreviousTab = true
        }

        ElloHUD.showLoadingHudInView(view)
        screen.interactionEnabled = false
        service.create(
            content: content,
            affiliateURL: affiliateURL,
            success: { postOrComment in
                ElloHUD.hideLoadingHudInView(self.view)
                self.screen.interactionEnabled = true

                if self.editPost != nil || self.editComment != nil {
                    NSURLCache.sharedURLCache().removeAllCachedResponses()
                }

                self.emitSuccess(postOrComment, didGoToPreviousTab: didGoToPreviousTab)
            },
            failure: { error, statusCode in
                ElloHUD.hideLoadingHudInView(self.view)
                self.screen.interactionEnabled = true
                self.contentCreationFailed(error.elloErrorMessage ?? error.localizedDescription)

                if let vc = self.parentViewController as? ElloTabBarController
                where didGoToPreviousTab {
                    vc.selectedTab = .Omnibar
                }
            })
    }

    private func emitSuccess(postOrComment: AnyObject, didGoToPreviousTab: Bool) {
        if let comment = postOrComment as? ElloComment {
            self.emitCommentSuccess(comment)
        }
        else if let post = postOrComment as? Post {
            self.emitPostSuccess(post, didGoToPreviousTab: didGoToPreviousTab)
        }
    }

    private func emitCommentSuccess(comment: ElloComment) {
        postNotification(CommentChangedNotification, value: (comment, .Create))
        ContentChange.updateCommentCount(comment, delta: 1)

        if editComment != nil {
            Tracker.sharedTracker.commentEdited(comment)
            postNotification(CommentChangedNotification, value: (comment, .Replaced))
        }
        else {
            Tracker.sharedTracker.commentCreated(comment)
        }

        if let listener = commentSuccessListener {
            listener(comment: comment)
        }
    }

    private func emitPostSuccess(post: Post, didGoToPreviousTab: Bool) {
        if let user = currentUser, postsCount = user.postsCount {
            user.postsCount = postsCount + 1
            postNotification(CurrentUserChangedNotification, value: user)
        }

        if editPost != nil {
            Tracker.sharedTracker.postEdited(post)
            postNotification(PostChangedNotification, value: (post, .Replaced))
        }
        else {
            Tracker.sharedTracker.postCreated(post)
            postNotification(PostChangedNotification, value: (post, .Create))
        }

        if let listener = postSuccessListener {
            listener(post: post)
        }

        self.screen.resetAfterSuccessfulPost()

        if didGoToPreviousTab {
            NotificationBanner.displayAlert(InterfaceString.Omnibar.CreatedPost)
        }
    }

    func contentCreationFailed(errorMessage: String) {
        let contentType: ContentType
        if parentPost == nil && editComment == nil {
            contentType = .Post
        }
        else {
            contentType = .Comment
        }
        Tracker.sharedTracker.contentCreationFailed(contentType, message: errorMessage)
        screen.reportError("Could not create \(contentType.rawValue)", errorMessage: errorMessage)
    }

}

extension OmnibarViewController {
    public func omnibarDataName() -> String? {
        if let post = parentPost {
            return "omnibar_v2_comment_\(post.repostId ?? post.id)"
        }
        else if editPost != nil || editComment != nil {
            return nil
        }
        else {
            return "omnibar_v2_post"
        }
    }
}
