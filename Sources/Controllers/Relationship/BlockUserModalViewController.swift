////
///  BlockUserModalViewController.swift
//

import Foundation
import SnapKit


public class BlockUserModalViewController: BaseElloViewController, BlockUserModalDelegate {
    weak public var relationshipDelegate: RelationshipDelegate?

    let config: BlockUserModalConfig
    var relationshipPriority: RelationshipPriority { return config.relationshipPriority }
    var userId: String { return config.userId }
    var userAtName: String { return config.userAtName }
    var changeClosure: RelationshipChangeClosure { return config.changeClosure }

    var screen: BlockUserModalScreen { return self.view as! BlockUserModalScreen }

    required public init(config: BlockUserModalConfig) {
        self.config = config
        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .Custom
        modalTransitionStyle = .CrossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func loadView() {
        let screen = BlockUserModalScreen(config: config)
        self.view = screen
    }

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let superView = self.view.superview {
            self.view.center = superView.center
        }
    }

    public func updateRelationship(newRelationship: RelationshipPriority) {
        guard let currentUserId = currentUser?.id else {
            closeModal()
            return
        }

        switch newRelationship {
            case .Block: Tracker.sharedTracker.userBlocked(userId)
            case .Mute: Tracker.sharedTracker.userMuted(userId)
            case .Inactive:
                if relationshipPriority == .Block {
                    Tracker.sharedTracker.userUnblocked(userId)
                }
                else if relationshipPriority == .Mute {
                    Tracker.sharedTracker.userUnmuted(userId)
                }
            default: break
        }

        relationshipDelegate?.updateRelationship(currentUserId, userId: userId, prev: relationshipPriority, relationshipPriority: newRelationship) {
            (status, relationship, isFinalValue) in
            switch status {
            case .Success:
                self.changeClosure(relationshipPriority: newRelationship)
                self.closeModal()
            case .Failure:
                self.changeClosure(relationshipPriority: self.relationshipPriority)
            }
        }
    }

    public func flagTapped() {
        if let presentingViewController = presentingViewController {
            let flagger = ContentFlagger(
                presentingController: presentingViewController,
                flaggableId: userId,
                contentType: .User
            )

            closeModalAndThen {
                flagger.displayFlaggingSheet()
            }
        }
    }

    public func closeModal() {
        closeModalAndThen {}
    }

    public func closeModalAndThen(completion: BasicBlock) {
        Tracker.sharedTracker.userBlockCanceled(userId)
        self.dismissViewControllerAnimated(true, completion: completion)
    }

}
