////
///  AffiliateLinkScreen.swift
//

import SnapKit

public protocol AffiliateLinkDelegate: class {
    func closeModal()
}

public class AffiliateLinkScreen: UIView {
    let backgroundButton = UIButton()
    let titleLabel = UILabel()
    weak var delegate: AffiliateLinkDelegate?

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
        backgroundButton.addTarget(self, action: #selector(closeModal), forControlEvents: .TouchUpInside)

        titleLabel.font = .defaultFont(18)
        titleLabel.textColor = .whiteColor()
        titleLabel.lineBreakMode = .ByWordWrapping
        titleLabel.numberOfLines = 0
    }

    private func bindActions() {
    }

    private func setText() {
        titleLabel.text = InterfaceString.Omnibar.SellYourWorkTitle
    }

    private func arrange() {
        addSubview(backgroundButton)
        addSubview(titleLabel)

        backgroundButton.snp_makeConstraints { make in
            make.edges.equalTo(self)
        }

        titleLabel.snp_makeConstraints { make in
            make.top.equalTo(self).offset(120)
        }
    }

    func closeModal() {
        delegate?.closeModal()
    }
}
