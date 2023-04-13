//
//  PeopleTurntableView.swift
//  Neves
//
//  Created by zhoujianping on 2022/9/2.
//

class PeopleTurntableView: UIScrollView {
    var peopleViewsStack: [PeopleView] = []
    var peopleViews: [Int: PeopleView] = [:]
    
    var isDebug = false { didSet { updateDebugMode() } }
    var isFollowOffsetY = true { didSet { updateIsFollowOffsetY() } }
    var isShowMore = false { didSet { updateIsShowMore() } }
    var isFlowLayout = false { didSet { updateLayoutMode() } }
    var focusIndex: Int? = nil
    
    let borderView = UIView()
    let contentFullBgView = UIView()
    var peoplePlaceholderes: [UILabel] = (0 ..< PlanetView.maxPeopleCount).map {
        let v = UILabel()
        v.textAlignment = .center
        v.textColor = .white
        v.text = "\($0)"
        v.tag = $0
        v.backgroundColor = .systemBlue
        v.isUserInteractionEnabled = false
        return v
    }
    
    init() {
        super.init(frame: [0, 0, PlanetView.width, PlanetView.height])
        contentInsetAdjustmentBehavior = .never
        delegate = self
        alwaysBounceVertical = true
        showsVerticalScrollIndicator = false
        indicatorStyle = .white
        clipsToBounds = false
        
        contentFullBgView.backgroundColor = .brown
        contentFullBgView.isUserInteractionEnabled = false
        contentFullBgView.alpha = 0
        addSubview(contentFullBgView)
        
        peoplePlaceholderes.forEach {
            $0.frame = [bounds.width * 0.5 + 150.px,
                        CGFloat($0.tag) * (PeopleView.height + 10.px),
                        PeopleView.width,
                        PeopleView.height]
            $0.alpha = 0
            addSubview($0)
        }
        
        (0 ..< PeopleTurntableView.maxPeopleViewCount).forEach { _ in
            let peopleView = PeopleView()
            peopleView.userIcon.isUserInteractionEnabled = true
            peopleView.userIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(peopleDidClick(_:))))
            addSubview(peopleView)
            peopleViewsStack.append(peopleView)
        }
        
        borderView.frame = bounds
        borderView.layer.borderColor = UIColor.red.cgColor
        borderView.layer.borderWidth = 1.5
        borderView.isUserInteractionEnabled = false
        borderView.alpha = 0
        addSubview(borderView)
        
        contentSize = [0, Self.singlePeopleOffsetY * CGFloat(PlanetView.maxPeopleCount)]
        // 需要空一格，否则第一个就在中心位置
        contentInset = .init(top: Self.singlePeopleOffsetY, left: 0, bottom: 0, right: 0)
        contentOffset = [0, -Self.singlePeopleOffsetY]
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var contentSize: CGSize {
        set {
            super.contentSize = newValue
            contentFullBgView.frame = [0, 0, bounds.width, newValue.height]
        }
        get { super.contentSize }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isDebug else {
            return super.hitTest(point, with: event)
        }
        
        for (_, peopleView) in peopleViews where peopleView.alpha > 0.01 && peopleView.frame.contains(point) {
            let tp = convert(point, to: peopleView)
            if peopleView.userIcon.frame.contains(tp) {
                return peopleView.userIcon
            }
        }
        
        return self
    }
}

extension PeopleTurntableView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        borderView.y = contentOffset.y
        
        if !isFlowLayout {
            updatePeoplesLayout()
        }
    }
}

extension PeopleTurntableView {
    func update(scale: CGFloat, alpha: CGFloat) {
        self.transform = .init(scaleX: scale, y: scale)
        self.alpha = alpha
    }
    
    @objc func peopleDidClick(_ tapGR: UITapGestureRecognizer) {
        guard let peopleView = tapGR.view?.superview as? PeopleView else { return }
        setFocusIndex(peopleView.index)
    }
}

private extension PeopleTurntableView {
    func updatePeoplesLayout() {
        if isFlowLayout {
            (0 ..< Self.maxPeopleViewCount).forEach { i in
                guard let peopleView = peopleViews[i] ?? (peopleViewsStack.count > 0 ? peopleViewsStack.removeFirst() : nil) else {
                    return
                }
                peopleView.resetFlowLayout(index: i, focusIndex: focusIndex)
                peopleViews[i] = peopleView
            }
            return
        }
        
        let offsetY = contentOffset.y
        let progress = offsetY / Self.oneRoundContentHeight // 1 = 1圈
        
        let radian90 = CGFloat.radian90
        let radian105 = CGFloat.radian105
        let radian360 = CGFloat.radian360
        let singleItemRadian = PeopleTurntableView.singlePeopleRadian
        
        (0 ..< PlanetView.maxPeopleCount).forEach { i in
            // 弧度
            var radian: CGFloat = singleItemRadian * CGFloat(i) - radian90
            radian -= progress * radian360
            
            var isShow: Bool = true
            if let focusIndex = focusIndex {
                isShow = focusIndex == i
            }
            if isShow && (!isDebug || !isShowMore) {
                // 30 * 3.5 = 105
                if radian > radian105 || radian < -radian105 {
                    isShow = false
                }
            }
            
            guard isShow else {
                if let peopleView = peopleViews[i] {
                    peopleView.updateLayout(nil)
                    peopleViews[i] = nil
                    peopleViewsStack.append(peopleView)
                }
                return
            }
            
            guard let peopleView = peopleViews[i] ?? (peopleViewsStack.count > 0 ? peopleViewsStack.removeFirst() : nil) else {
                return
            }
            
            let layout = PeopleView.Layout.build(index: i,
                                                 radian: radian,
                                                 offsetY: offsetY,
                                                 isDebug: isDebug,
                                                 isFollowOffsetY: isFollowOffsetY)
            peopleView.updateLayout(layout)
            peopleViews[i] = peopleView
        }
    }
    
    func updateDebugMode() {
        showsVerticalScrollIndicator = isDebug
        
        borderView.alpha = isDebug ? 1 : 0
        contentFullBgView.alpha = isDebug ? 0.35 : 0
        peoplePlaceholderes.forEach { $0.alpha = isDebug ? 0.5 : 0 }
        
        focusIndex = nil
        isFlowLayout = false
    }
    
    func updateLayoutMode() {
        peopleViews.forEach { $1.index = -1 }
        peopleViewsStack += peopleViews.values
        peopleViews.removeAll()
        
        if isFlowLayout {
            contentSize.height = PeopleView.height * CGFloat(Self.maxPeopleViewCount) + 10.px * CGFloat(Self.maxPeopleViewCount - 1)
        } else {
            contentSize.height = Self.singlePeopleOffsetY * CGFloat(PlanetView.maxPeopleCount)
        }
        
        if isDebug {
            contentInset = .zero
        } else {
            contentInset = .init(top: Self.singlePeopleOffsetY, left: 0, bottom: 0, right: 0)
        }
        
        updatePeoplesLayout()
        peopleViewsStack.forEach { $0.alpha = 0 }
    }
    
    func updateIsFollowOffsetY() {
        guard isDebug, !isFlowLayout else { return }
        updatePeoplesLayout()
    }
    
    func updateIsShowMore() {
        guard isDebug, !isFlowLayout else { return }
        
        peopleViews.forEach { $1.index = -1 }
        peopleViewsStack += peopleViews.values
        peopleViews.removeAll()
        
        updatePeoplesLayout()
        
        peopleViewsStack.forEach { $0.alpha = 0 }
    }
    
    func setFocusIndex(_ index: Int) {
        guard isDebug else { return }
        
        focusIndex = focusIndex == nil ? index : nil
        JPrint("focusIndex ---", focusIndex ?? -1)
        
        UIView.animate(withDuration: 0.35) {
            self.updatePeoplesLayout()
            self.peoplePlaceholderes.forEach {
                if let focusIndex = self.focusIndex {
                    $0.alpha = focusIndex == $0.tag ? 0.5 : 0
                } else {
                    $0.alpha = 0.5
                }
            }
        }
    }
}
