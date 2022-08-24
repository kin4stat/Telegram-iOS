import Foundation
import UIKit
import Display
import AsyncDisplayKit
import ComponentFlow
import SwiftSignalKit
import AnimationCache
import MultiAnimationRenderer
import EntityKeyboard
import ComponentDisplayAdapters
import TelegramPresentationData
import AccountContext
import PagerComponent
import Postbox
import TelegramCore

public final class EmojiStatusSelectionComponent: Component {
    public typealias EnvironmentType = Empty
    
    public let theme: PresentationTheme
    public let strings: PresentationStrings
    public let deviceMetrics: DeviceMetrics
    public let emojiContent: EmojiPagerContentComponent
    public let backgroundColor: UIColor
    public let separatorColor: UIColor
    
    public init(
        theme: PresentationTheme,
        strings: PresentationStrings,
        deviceMetrics: DeviceMetrics,
        emojiContent: EmojiPagerContentComponent,
        backgroundColor: UIColor,
        separatorColor: UIColor
    ) {
        self.theme = theme
        self.strings = strings
        self.deviceMetrics = deviceMetrics
        self.emojiContent = emojiContent
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
    }
    
    public static func ==(lhs: EmojiStatusSelectionComponent, rhs: EmojiStatusSelectionComponent) -> Bool {
        if lhs.theme !== rhs.theme {
            return false
        }
        if lhs.strings != rhs.strings {
            return false
        }
        if lhs.deviceMetrics != rhs.deviceMetrics {
            return false
        }
        if lhs.emojiContent != rhs.emojiContent {
            return false
        }
        if lhs.backgroundColor != rhs.backgroundColor {
            return false
        }
        if lhs.separatorColor != rhs.separatorColor {
            return false
        }
        return true
    }
    
    public final class View: UIView {
        private let keyboardView: ComponentView<Empty>
        private let keyboardClippingView: UIView
        private let panelHostView: PagerExternalTopPanelContainer
        private let panelBackgroundView: BlurredBackgroundView
        private let panelSeparatorView: UIView
        
        private var component: EmojiStatusSelectionComponent?
        
        override init(frame: CGRect) {
            self.keyboardView = ComponentView<Empty>()
            self.keyboardClippingView = UIView()
            self.panelHostView = PagerExternalTopPanelContainer()
            self.panelBackgroundView = BlurredBackgroundView(color: .clear, enableBlur: true)
            self.panelSeparatorView = UIView()
            
            super.init(frame: frame)
            
            self.addSubview(self.keyboardClippingView)
            self.addSubview(self.panelBackgroundView)
            self.addSubview(self.panelSeparatorView)
            self.addSubview(self.panelHostView)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func update(component: EmojiStatusSelectionComponent, availableSize: CGSize, state: EmptyComponentState, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize {
            self.backgroundColor = component.backgroundColor
            let panelBackgroundColor = component.backgroundColor.withMultipliedAlpha(0.85)
            self.panelBackgroundView.updateColor(color: panelBackgroundColor, transition: .immediate)
            self.panelSeparatorView.backgroundColor = component.separatorColor
            
            self.component = component
            
            let topPanelHeight: CGFloat = 42.0
            
            let keyboardSize = self.keyboardView.update(
                transition: transition,
                component: AnyComponent(EntityKeyboardComponent(
                    theme: component.theme,
                    strings: component.strings,
                    containerInsets: UIEdgeInsets(top: topPanelHeight - 34.0, left: 0.0, bottom: 0.0, right: 0.0),
                    topPanelInsets: UIEdgeInsets(top: 0.0, left: 4.0, bottom: 0.0, right: 4.0),
                    emojiContent: component.emojiContent,
                    stickerContent: nil,
                    gifContent: nil,
                    hasRecentGifs: false,
                    availableGifSearchEmojies: [],
                    defaultToEmojiTab: true,
                    externalTopPanelContainer: self.panelHostView,
                    topPanelExtensionUpdated: { _, _ in },
                    hideInputUpdated: { _, _, _ in },
                    switchToTextInput: {},
                    switchToGifSubject: { _ in },
                    makeSearchContainerNode: { _ in return nil },
                    deviceMetrics: component.deviceMetrics,
                    hiddenInputHeight: 0.0,
                    displayBottomPanel: false,
                    isExpanded: false
                )),
                environment: {},
                containerSize: availableSize
            )
            if let keyboardComponentView = self.keyboardView.view {
                if keyboardComponentView.superview == nil {
                    self.keyboardClippingView.addSubview(keyboardComponentView)
                }
                
                if panelBackgroundColor.alpha < 0.01 {
                    self.keyboardClippingView.clipsToBounds = true
                } else {
                    self.keyboardClippingView.clipsToBounds = false
                }
                
                transition.setFrame(view: self.keyboardClippingView, frame: CGRect(origin: CGPoint(x: 0.0, y: topPanelHeight), size: CGSize(width: availableSize.width, height: availableSize.height - topPanelHeight)))
                
                transition.setFrame(view: keyboardComponentView, frame: CGRect(origin: CGPoint(x: 0.0, y: -topPanelHeight), size: keyboardSize))
                transition.setFrame(view: self.panelHostView, frame: CGRect(origin: CGPoint(x: 0.0, y: topPanelHeight - 34.0), size: CGSize(width: keyboardSize.width, height: 0.0)))
                
                transition.setFrame(view: self.panelBackgroundView, frame: CGRect(origin: CGPoint(), size: CGSize(width: keyboardSize.width, height: topPanelHeight)))
                self.panelBackgroundView.update(size: self.panelBackgroundView.bounds.size, transition: transition.containedViewLayoutTransition)
                
                transition.setFrame(view: self.panelSeparatorView, frame: CGRect(origin: CGPoint(x: 0.0, y: topPanelHeight), size: CGSize(width: keyboardSize.width, height: UIScreenPixel)))
            }
            
            return availableSize
        }
    }

    public func makeView() -> View {
        return View(frame: CGRect())
    }
    
    public func update(view: View, availableSize: CGSize, state: EmptyComponentState, environment: Environment<EnvironmentType>, transition: Transition) -> CGSize {
        return view.update(component: self, availableSize: availableSize, state: state, environment: environment, transition: transition)
    }
}

public final class EmojiStatusSelectionController: ViewController {
    private final class Node: ViewControllerTracingNode {
        private weak var controller: EmojiStatusSelectionController?
        private let context: AccountContext
        private weak var sourceView: UIView?
        private var globalSourceRect: CGRect?
        
        private let componentHost: ComponentView<Empty>
        private let componentShadowLayer: SimpleLayer
        
        private let cloudLayer0: SimpleLayer
        private let cloudShadowLayer0: SimpleLayer
        private let cloudLayer1: SimpleLayer
        private let cloudShadowLayer1: SimpleLayer
        
        private var presentationData: PresentationData
        private var validLayout: ContainerViewLayout?
        
        private var emojiContentDisposable: Disposable?
        private var emojiContent: EmojiPagerContentComponent?
        private var scheduledEmojiContentAnimationHint: EmojiPagerContentComponent.ContentAnimation?
        
        private var isDismissed: Bool = false
        
        init(controller: EmojiStatusSelectionController, context: AccountContext, sourceView: UIView?, emojiContent: Signal<EmojiPagerContentComponent, NoError>) {
            self.controller = controller
            self.context = context
            
            if let sourceView = sourceView {
                self.globalSourceRect = sourceView.convert(sourceView.bounds, to: nil)
            }
            
            self.presentationData = self.context.sharedContext.currentPresentationData.with { $0 }
            
            self.componentHost = ComponentView<Empty>()
            self.componentShadowLayer = SimpleLayer()
            self.componentShadowLayer.shadowOpacity = 0.12
            self.componentShadowLayer.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
            self.componentShadowLayer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.componentShadowLayer.shadowRadius = 16.0
            
            self.cloudLayer0 = SimpleLayer()
            self.cloudShadowLayer0 = SimpleLayer()
            self.cloudShadowLayer0.shadowOpacity = 0.12
            self.cloudShadowLayer0.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
            self.cloudShadowLayer0.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.cloudShadowLayer0.shadowRadius = 16.0
            
            self.cloudLayer1 = SimpleLayer()
            self.cloudShadowLayer1 = SimpleLayer()
            self.cloudShadowLayer1.shadowOpacity = 0.12
            self.cloudShadowLayer1.shadowColor = UIColor(white: 0.0, alpha: 1.0).cgColor
            self.cloudShadowLayer1.shadowOffset = CGSize(width: 0.0, height: 2.0)
            self.cloudShadowLayer1.shadowRadius = 16.0
            
            super.init()
            
            self.layer.addSublayer(self.componentShadowLayer)
            self.layer.addSublayer(self.cloudShadowLayer0)
            self.layer.addSublayer(self.cloudShadowLayer1)
            
            self.layer.addSublayer(self.cloudLayer0)
            self.layer.addSublayer(self.cloudLayer1)
            
            self.emojiContentDisposable = (emojiContent
            |> deliverOnMainQueue).start(next: { [weak self] emojiContent in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.controller?._ready.set(.single(true))
                strongSelf.emojiContent = emojiContent
                
                emojiContent.inputInteractionHolder.inputInteraction = EmojiPagerContentComponent.InputInteraction(
                    performItemAction: { _, item, _, _, _, _ in
                        guard let strongSelf = self else {
                            return
                        }
                        strongSelf.applyItem(item: item)
                    },
                    deleteBackwards: {
                    },
                    openStickerSettings: {
                    },
                    openFeatured: {
                    },
                    addGroupAction: { groupId, isPremiumLocked in
                        guard let strongSelf = self, let collectionId = groupId.base as? ItemCollectionId else {
                            return
                        }
                        
                        let viewKey = PostboxViewKey.orderedItemList(id: Namespaces.OrderedItemList.CloudFeaturedEmojiPacks)
                        let _ = (strongSelf.context.account.postbox.combinedView(keys: [viewKey])
                        |> take(1)
                        |> deliverOnMainQueue).start(next: { views in
                            guard let strongSelf = self, let view = views.views[viewKey] as? OrderedItemListView else {
                                return
                            }
                            for featuredEmojiPack in view.items.lazy.map({ $0.contents.get(FeaturedStickerPackItem.self)! }) {
                                if featuredEmojiPack.info.id == collectionId {
                                    if let strongSelf = self {
                                        strongSelf.scheduledEmojiContentAnimationHint = EmojiPagerContentComponent.ContentAnimation(type: .groupInstalled(id: collectionId))
                                    }
                                    let _ = strongSelf.context.engine.stickers.addStickerPackInteractively(info: featuredEmojiPack.info, items: featuredEmojiPack.topItems).start()
                                    
                                    break
                                }
                            }
                        })
                    },
                    clearGroup: { groupId in
                    },
                    pushController: { c in
                    },
                    presentController: { c in
                    },
                    presentGlobalOverlayController: { c in
                    },
                    navigationController: {
                        return nil
                    },
                    sendSticker: nil,
                    chatPeerId: nil,
                    peekBehavior: nil,
                    customLayout: nil,
                    externalBackground: nil
                )
                
                strongSelf.refreshLayout(transition: .immediate)
            })
        }
        
        deinit {
            self.emojiContentDisposable?.dispose()
        }
        
        private func refreshLayout(transition: Transition) {
            guard let layout = self.validLayout else {
                return
            }
            self.containerLayoutUpdated(layout: layout, transition: transition)
        }
        
        func animateOut(completion: @escaping () -> Void) {
            self.componentShadowLayer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
            self.componentHost.view?.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false, completion: { _ in
                completion()
            })
            
            self.cloudLayer0.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
            self.cloudShadowLayer0.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
            self.cloudLayer1.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
            self.cloudShadowLayer1.animateAlpha(from: 1.0, to: 0.0, duration: 0.25, removeOnCompletion: false)
        }
        
        func containerLayoutUpdated(layout: ContainerViewLayout, transition: Transition) {
            self.validLayout = layout
            
            var transition = transition
            
            guard let emojiContent = self.emojiContent else {
                return
            }
            
            let listBackgroundColor: UIColor
            let separatorColor: UIColor
            if self.presentationData.theme.overallDarkAppearance {
                listBackgroundColor = self.presentationData.theme.list.itemBlocksBackgroundColor
                separatorColor = self.presentationData.theme.list.itemBlocksSeparatorColor
                self.componentShadowLayer.shadowOpacity = 0.32
                self.cloudShadowLayer0.shadowOpacity = 0.32
                self.cloudShadowLayer1.shadowOpacity = 0.32
            } else {
                listBackgroundColor = self.presentationData.theme.list.plainBackgroundColor
                separatorColor = self.presentationData.theme.list.itemPlainSeparatorColor.withMultipliedAlpha(0.5)
                self.componentShadowLayer.shadowOpacity = 0.12
                self.cloudShadowLayer0.shadowOpacity = 0.12
                self.cloudShadowLayer1.shadowOpacity = 0.12
            }
            
            self.cloudLayer0.backgroundColor = listBackgroundColor.cgColor
            self.cloudLayer1.backgroundColor = listBackgroundColor.cgColor
            
            let sideInset: CGFloat = 16.0
            
            if let scheduledEmojiContentAnimationHint = self.scheduledEmojiContentAnimationHint {
                self.scheduledEmojiContentAnimationHint = nil
                let contentAnimation = scheduledEmojiContentAnimationHint
                transition = Transition(animation: .curve(duration: 0.4, curve: .spring)).withUserData(contentAnimation)
            }
            
            let componentSize = self.componentHost.update(
                transition: transition,
                component: AnyComponent(EmojiStatusSelectionComponent(
                    theme: self.presentationData.theme,
                    strings: self.presentationData.strings,
                    deviceMetrics: layout.deviceMetrics,
                    emojiContent: emojiContent,
                    backgroundColor: listBackgroundColor,
                    separatorColor: separatorColor
                )),
                environment: {},
                containerSize: CGSize(width: layout.size.width - sideInset * 2.0, height: min(308.0, layout.size.height))
            )
            if let componentView = self.componentHost.view {
                var animateIn = false
                if componentView.superview == nil {
                    self.view.addSubview(componentView)
                    animateIn = true
                    
                    componentView.clipsToBounds = true
                    componentView.layer.cornerRadius = 24.0
                }
                
                let sourceOrigin: CGPoint
                if let sourceView = self.sourceView {
                    let sourceRect = sourceView.convert(sourceView.bounds, to: self.view)
                    sourceOrigin = CGPoint(x: sourceRect.midX, y: sourceRect.maxY)
                } else if let globalSourceRect = self.globalSourceRect {
                    let sourceRect = self.view.convert(globalSourceRect, from: nil)
                    sourceOrigin = CGPoint(x: sourceRect.midX, y: sourceRect.maxY)
                } else {
                    sourceOrigin = CGPoint(x: layout.size.width / 2.0, y: floor(layout.size.height / 2.0 - componentSize.height))
                }
                
                let componentFrame = CGRect(origin: CGPoint(x: sideInset, y: sourceOrigin.y + 5.0), size: componentSize)
                
                if self.componentShadowLayer.bounds.size != componentFrame.size {
                    let componentShadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: componentFrame.size), cornerRadius: 24.0).cgPath
                    self.componentShadowLayer.shadowPath = componentShadowPath
                }
                transition.setFrame(layer: self.componentShadowLayer, frame: componentFrame)
                
                let cloudOffset0: CGFloat = 30.0
                let cloudSize0: CGFloat = 16.0
                let cloudFrame0 = CGRect(origin: CGPoint(x: floor(sourceOrigin.x + cloudOffset0 - cloudSize0 / 2.0), y: componentFrame.minY - cloudSize0 / 2.0), size: CGSize(width: cloudSize0, height: cloudSize0))
                transition.setFrame(layer: self.cloudLayer0, frame: cloudFrame0)
                if self.cloudShadowLayer0.bounds.size != cloudFrame0.size {
                    let cloudShadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: cloudFrame0.size), cornerRadius: 24.0).cgPath
                    self.cloudShadowLayer0.shadowPath = cloudShadowPath
                }
                transition.setFrame(layer: self.cloudShadowLayer0, frame: cloudFrame0)
                transition.setCornerRadius(layer: self.cloudLayer0, cornerRadius: cloudFrame0.width / 2.0)
                
                let cloudOffset1 = CGPoint(x: -9.0, y: -14.0)
                let cloudSize1: CGFloat = 8.0
                let cloudFrame1 = CGRect(origin: CGPoint(x: floor(cloudFrame0.midX + cloudOffset1.x - cloudSize1 / 2.0), y: floor(cloudFrame0.midY + cloudOffset1.y - cloudSize1 / 2.0)), size: CGSize(width: cloudSize1, height: cloudSize1))
                transition.setFrame(layer: self.cloudLayer1, frame: cloudFrame1)
                if self.cloudShadowLayer1.bounds.size != cloudFrame1.size {
                    let cloudShadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: cloudFrame1.size), cornerRadius: 24.0).cgPath
                    self.cloudShadowLayer1.shadowPath = cloudShadowPath
                }
                transition.setFrame(layer: self.cloudShadowLayer1, frame: cloudFrame1)
                transition.setCornerRadius(layer: self.cloudLayer1, cornerRadius: cloudFrame1.width / 2.0)
                
                transition.setFrame(view: componentView, frame: CGRect(origin: componentFrame.origin, size: CGSize(width: componentFrame.width, height: componentFrame.height)))
                
                if animateIn {
                    self.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.1, completion: { [weak self] _ in
                        self?.allowsGroupOpacity = false
                    })
                    
                    let contentDuration: Double = 0.3
                    let contentDelay: Double = 0.14
                    let initialContentFrame = CGRect(origin: CGPoint(x: cloudFrame0.midX - 24.0, y: componentFrame.minY), size: CGSize(width: 24.0 * 2.0, height: 24.0 * 2.0))
                    
                    if let emojiView = self.componentHost.findTaggedView(tag: EmojiPagerContentComponent.Tag(id: AnyHashable("emoji"))) as? EmojiPagerContentComponent.View {
                        emojiView.animateIn(fromLocation: self.view.convert(initialContentFrame.center, to: emojiView))
                    }
                    
                    componentView.layer.animatePosition(from: initialContentFrame.center, to: componentFrame.center, duration: contentDuration, delay: contentDelay, timingFunction: kCAMediaTimingFunctionSpring)
                    componentView.layer.animateBounds(from: CGRect(origin: CGPoint(x: -(componentFrame.minX - initialContentFrame.minX), y: -(componentFrame.minY - initialContentFrame.minY)), size: initialContentFrame.size), to: CGRect(origin: CGPoint(), size: componentFrame.size), duration: contentDuration, delay: contentDelay, timingFunction: kCAMediaTimingFunctionSpring)
                    self.componentShadowLayer.animateFrame(from: CGRect(origin: CGPoint(x: cloudFrame0.midX - 24.0, y: componentFrame.minY), size: CGSize(width: 24.0 * 2.0, height: 24.0 * 2.0)), to: componentView.frame, duration: contentDuration, delay: contentDelay, timingFunction: kCAMediaTimingFunctionSpring)
                    componentView.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.04, delay: contentDelay)
                    self.componentShadowLayer.animateAlpha(from: 0.0, to: 1.0, duration: 0.04, delay: contentDelay)
                    
                    let initialComponentShadowPath = UIBezierPath(roundedRect: CGRect(origin: CGPoint(), size: initialContentFrame.size), cornerRadius: 24.0).cgPath
                    self.componentShadowLayer.animate(from: initialComponentShadowPath, to: self.componentShadowLayer.shadowPath!, keyPath: "shadowPath", timingFunction: kCAMediaTimingFunctionSpring, duration: contentDuration, delay: contentDelay)
                    
                    self.cloudLayer0.animateScale(from: 0.01, to: 1.0, duration: 0.4, delay: 0.05, timingFunction: kCAMediaTimingFunctionSpring)
                    self.cloudShadowLayer0.animateScale(from: 0.01, to: 1.0, duration: 0.4, delay: 0.05, timingFunction: kCAMediaTimingFunctionSpring)
                    
                    self.cloudLayer1.animateScale(from: 0.01, to: 1.0, duration: 0.4, timingFunction: kCAMediaTimingFunctionSpring)
                    self.cloudShadowLayer1.animateScale(from: 0.01, to: 1.0, duration: 0.4, timingFunction: kCAMediaTimingFunctionSpring)
                }
            }
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if let result = super.hitTest(point, with: event) {
                if self.isDismissed {
                    return self.view
                }
                
                if result === self.view {
                    self.isDismissed = true
                    self.controller?.dismiss()
                }
                
                return result
            }
            return nil
        }
        
        private func applyItem(item: EmojiPagerContentComponent.Item?) {
            self.controller?.dismiss()
            
            let _ = (self.context.engine.accountData.setEmojiStatus(file: item?.itemFile)
            |> deliverOnMainQueue).start()
        }
    }
    
    private let context: AccountContext
    private weak var sourceView: UIView?
    private let emojiContent: Signal<EmojiPagerContentComponent, NoError>
    
    fileprivate let _ready = Promise<Bool>()
    override public var ready: Promise<Bool> {
        return self._ready
    }
    
    public init(context: AccountContext, sourceView: UIView, emojiContent: Signal<EmojiPagerContentComponent, NoError>) {
        self.context = context
        self.sourceView = sourceView
        self.emojiContent = emojiContent
        
        super.init(navigationBarPresentationData: nil)
        
        self.statusBar.statusBarStyle = .Ignore
    }
    
    required public init(coder: NSCoder) {
        preconditionFailure()
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override public func dismiss(completion: (() -> Void)? = nil) {
        (self.displayNode as! Node).animateOut(completion: { [weak self] in
            self?.presentingViewController?.dismiss(animated: false, completion: nil)
            completion?()
        })
    }
    
    override public func loadDisplayNode() {
        self.displayNode = Node(controller: self, context: self.context, sourceView: self.sourceView, emojiContent: self.emojiContent)

        super.displayNodeDidLoad()
    }

    override public func containerLayoutUpdated(_ layout: ContainerViewLayout, transition: ContainedViewLayoutTransition) {
        super.containerLayoutUpdated(layout, transition: transition)

        (self.displayNode as! Node).containerLayoutUpdated(layout: layout, transition: Transition(transition))
    }
}
