////
///  AffiliateLinkScreen.swift
//

import SnapKit

public protocol AffiliateLinkDelegate: class {
    func closeModal()
    func submitLink(url: NSURL)
    func clearLink()
}

public class AffiliateLinkScreen: UIView {
    let backgroundButton = UIButton()
    let titleLabel = UILabel()
    let productLinkField = ElloTextField()
    let submitButton = GreenElloButton()
    let removeButton = GreenElloButton()
    let cancelLabel = UILabel()

    var submitButtonTrailingRight: Constraint?
    var submitButtonTrailingRemove: Constraint?

    weak var delegate: AffiliateLinkDelegate?

    var affiliateURL: NSURL? {
        get { return NSURL(string: productLinkField.text ?? "") }
        set {
            if let affiliateURL = newValue {
                productLinkField.text = affiliateURL.absoluteString
                submitButtonTrailingRight?.deactivate()
                submitButtonTrailingRemove?.activate()
                removeButton.hidden = false
            }
            else {
                productLinkField.text = ""
                submitButtonTrailingRight?.activate()
                submitButtonTrailingRemove?.deactivate()
                removeButton.hidden = true
            }
            productLinkDidChange()
        }
    }

    public required override init(frame: CGRect) {
        super.init(frame: frame)

        style()
        bindActions()
        setText()
        arrange()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func style() {
        backgroundButton.backgroundColor = .modalBackground()

        titleLabel.font = .defaultFont(18)
        titleLabel.textColor = .whiteColor()

        cancelLabel.font = .defaultFont()
        cancelLabel.textColor = .greyA()

        productLinkField.backgroundColor = .whiteColor()
        productLinkField.keyboardType = .URL
        productLinkField.autocapitalizationType = .None
        productLinkField.autocorrectionType = .No
        productLinkField.spellCheckingType = .No
        productLinkField.keyboardAppearance = .Dark
        productLinkField.enablesReturnKeyAutomatically = true
        productLinkField.returnKeyType = .Default

        submitButton.enabled = false
        removeButton.hidden = true
    }

    private func bindActions() {
        backgroundButton.addTarget(self, action: #selector(closeModal), forControlEvents: .TouchUpInside)
        submitButton.addTarget(self, action: #selector(submitLink), forControlEvents: .TouchUpInside)
        removeButton.addTarget(self, action: #selector(removeLink), forControlEvents: .TouchUpInside)
        productLinkField.addTarget(self, action: #selector(productLinkDidChange), forControlEvents: .EditingChanged)
    }

    private func setText() {
        titleLabel.text = InterfaceString.Omnibar.SellYourWorkTitle
        productLinkField.placeholder = InterfaceString.Omnibar.ProductLinkPlaceholder
        submitButton.setTitle(InterfaceString.Submit, forState: .Normal)
        removeButton.setTitle(InterfaceString.Delete, forState: .Normal)
        cancelLabel.text = InterfaceString.Cancel
    }

    private func arrange() {
        addSubview(backgroundButton)
        addSubview(titleLabel)
        addSubview(productLinkField)
        addSubview(submitButton)
        addSubview(removeButton)
        addSubview(cancelLabel)

        backgroundButton.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }

        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(self).offset(120)
            make.leading.equalTo(self).offset(10)
        }

        productLinkField.snp_makeConstraints { make in
            make.top.equalTo(titleLabel.snp_bottom).offset(40)
            make.leading.equalTo(self).offset(10)
            make.trailing.equalTo(self).offset(-10)
            make.height.equalTo(60)
        }

        submitButton.snp_makeConstraints { make in
            make.top.equalTo(productLinkField.snp_bottom).offset(10)
            make.leading.equalTo(self).offset(10)
            submitButtonTrailingRight = make.trailing.equalTo(self).offset(-10).constraint
            submitButtonTrailingRemove = make.trailing.equalTo(removeButton.snp_leading).offset(-10).constraint
            make.height.equalTo(60)
        }
        submitButtonTrailingRemove!.deactivate()

        removeButton.snp_makeConstraints { make in
            make.top.equalTo(productLinkField.snp_bottom).offset(10)
            make.width.equalTo(self).dividedBy(2).offset(-20)
            make.trailing.equalTo(self).offset(-10).constraint
            make.height.equalTo(60)
        }

        cancelLabel.snp_makeConstraints { make in
            make.top.equalTo(submitButton.snp_bottom).offset(25)
            make.leading.equalTo(self).offset(10)
        }
    }

    func productLinkDidChange() {
        submitButton.enabled = isValidLink(productLinkField.text)
    }

    func isValidLink(urlString: String?) -> Bool {
        guard let urlString = urlString else {
            return false
        }

        var url: NSURL?
        if let urlTest = NSURL(string: urlString) where urlTest.scheme != "" {
            url = urlTest
        }
        else if let urlTest = NSURL(string: "http://\(urlString)") {
            url = urlTest
        }

        if let host = url?.host where host =~ "\\w+\\.\\w+" {
            return true
        }
        return false
    }

    func closeModal() {
        delegate?.closeModal()
    }

    func submitLink() {
        guard let urlString = productLinkField.text else {
            return
        }

        var url: NSURL?
        if let urlTest = NSURL(string: urlString) where urlTest.scheme != "" {
            url = urlTest
        }
        else if let urlTest = NSURL(string: "http://\(urlString)") {
            url = urlTest
        }

        if let url = url {
            delegate?.submitLink(url)
        }
        closeModal()
    }

    func removeLink() {
        delegate?.clearLink()
        closeModal()
    }
}