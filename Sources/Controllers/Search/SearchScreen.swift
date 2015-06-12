//
//  SearchScreen.swift
//  Ello
//
//  Created by Colin Gray on 4/21/2015.
//  Copyright (c) 2015 Ello. All rights reserved.
//

@objc
public protocol SearchScreenDelegate {
    func searchCanceled()
    func searchFieldCleared()
    func searchFieldChanged(text: String)
    func findFriendsTapped()
}

@objc
public protocol SearchScreenProtocol {
    var delegate : SearchScreenDelegate? { get set }
    func viewForStream() -> UIView
    func updateInsets(#bottom: CGFloat)
}

public class SearchScreen: UIView, SearchScreenProtocol {
    var keyboardWillShowObserver: NotificationObserver?
    var keyboardWillHideObserver: NotificationObserver?
    private var throttled: ThrottledBlock
    private var navigationBar: ElloNavigationBar!
    private var searchField: UITextField!
    private var streamViewContainer: UIView!
    private var findFriendsContainer: UIView!
    private var bottomInset: CGFloat
    private var navBarTitle: String!
    private var fieldPlaceholderText: String!
    private var addFindFriendsButton: Bool!

    weak public var delegate : SearchScreenDelegate?

// MARK: init

    public init(frame: CGRect, navBarTitle: String? = NSLocalizedString("Search", comment: "Search navbar title"), fieldPlaceholderText: String? = NSLocalizedString("Search Ello", comment: "search ello placeholder text"), addFindFriendsButton: Bool? = true) {
        throttled = debounce(0.5)
        bottomInset = 0
        self.navBarTitle = navBarTitle
        self.fieldPlaceholderText = fieldPlaceholderText
        self.addFindFriendsButton = addFindFriendsButton
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()

        setupNavigationBar()
        setupSearchField()
        setupStreamView()
        setupFindFriendsButton()
        findFriendsContainer.hidden = addFindFriendsButton == false
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

// MARK: views

    private func setupNavigationBar() {
        let frame = CGRect(x: 0, y: 0, width: self.frame.width, height: ElloNavigationBar.Size.height)
        navigationBar = ElloNavigationBar(frame: frame)
        navigationBar.autoresizingMask = .FlexibleBottomMargin | .FlexibleWidth

        let navigationItem = UINavigationItem(title: navBarTitle)
        let leftItem = UIBarButtonItem.backChevronWithTarget(self, action: Selector("backTapped"))
        navigationItem.leftBarButtonItems = [leftItem]
        navigationItem.fixNavBarItemPadding()
        navigationBar.items = [navigationItem]

        self.addSubview(navigationBar)
    }

    private func setupSearchField() {
        let frame = self.bounds.inset(sides: 15).atY(75).withHeight(41)
        searchField = UITextField(frame: frame)
        searchField.autoresizingMask = .FlexibleWidth | .FlexibleBottomMargin
        searchField.clearButtonMode = .WhileEditing
        searchField.font = UIFont.regularBoldFont(18)
        searchField.textColor = UIColor.blackColor()
        searchField.attributedPlaceholder = NSAttributedString(string: "  \(fieldPlaceholderText)", attributes: [NSForegroundColorAttributeName: UIColor.greyA()])
        searchField.autocapitalizationType = .None
        searchField.autocorrectionType = .No
        searchField.spellCheckingType = .No
        searchField.enablesReturnKeyAutomatically = true
        searchField.returnKeyType = .Search
        searchField.keyboardType = .Default
        searchField.delegate = self
        searchField.addTarget(self, action: Selector("searchFieldDidChange"), forControlEvents: .EditingChanged)
        self.addSubview(searchField)

        let lineFrame = searchField.frame.fromBottom().growUp(1).shiftUp(2)
        let lineView = UIView(frame: lineFrame)
        lineView.backgroundColor = UIColor.greyA()
        self.addSubview(lineView)
    }

    private func setupStreamView() {
        let height = self.frame.height - searchField.frame.maxY
        let frame = self.bounds.atY(searchField.frame.maxY).withHeight(height)
        streamViewContainer = UIView(frame: frame)
        streamViewContainer.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        streamViewContainer.backgroundColor = .whiteColor()
        self.addSubview(streamViewContainer)
    }

    private func setupFindFriendsButton() {
        let height = CGFloat(143)
        let containerFrame = self.frame.fromBottom().growUp(height)
        findFriendsContainer = UIView(frame: containerFrame)
        findFriendsContainer.backgroundColor = .blackColor()

        let margins = UIEdgeInsets(top: 20, left: 15, bottom: 26, right: 15)
        let buttonHeight = CGFloat(50)
        let button = WhiteElloButton(frame: CGRect(
            x: margins.left,
            y: containerFrame.height - margins.bottom - buttonHeight,
            width: containerFrame.width - margins.left - margins.right,
            height: buttonHeight
            ))
        button.setTitle(NSLocalizedString("Find your friends", comment: "Find your friends button title"), forState: .Normal)
        button.addTarget(self, action: Selector("findFriendsTapped"), forControlEvents: .TouchUpInside)

        let label = ElloLabel()
        label.frame = CGRect(
            x: margins.left, y: 0,
            width: button.frame.width,
            height: containerFrame.height - margins.bottom - button.frame.height
        )
        label.numberOfLines = 2
        label.setLabelText(NSLocalizedString("Ello is better with friends.\nFind or invite yours:", comment: "Ello is better with friends button title"))

        self.addSubview(findFriendsContainer)
        findFriendsContainer.addSubview(label)
        findFriendsContainer.addSubview(button)
    }

    public func viewForStream() -> UIView {
        return streamViewContainer
    }

    private func clearSearch() {
        delegate?.searchFieldCleared()
        throttled {}
    }

    public func updateInsets(#bottom: CGFloat) {
        bottomInset = bottom
        setNeedsLayout()
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        findFriendsContainer.frame.origin.y = frame.size.height - findFriendsContainer.frame.height - bottomInset
    }

// MARK: actions

    @objc
    private func backTapped() {
        delegate?.searchCanceled()
    }

    @objc
    private func findFriendsTapped() {
        delegate?.findFriendsTapped()
    }

    @objc
    private func searchFieldDidChange() {
        let text = searchField.text ?? ""
        if count(text) == 0 {
            clearSearch()
            showFindFriends()
        }
        else {
            throttled { [unowned self] in
                self.hideFindFriends()
                self.delegate?.searchFieldChanged(text)
            }
        }
    }

}

extension SearchScreen: UITextFieldDelegate {

    @objc
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        clearSearch()
        showFindFriends()
        return true
    }

}

extension SearchScreen {

    private func showFindFriends() {
        findFriendsContainer.hidden = addFindFriendsButton == false
    }

    private func hideFindFriends() {
        findFriendsContainer.hidden = true
    }

}
