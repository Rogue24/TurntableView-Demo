//
//  PlanetPeopleView.swift
//  Neves
//
//  Created by zhoujianping on 2022/8/31.
//

class PlanetView: UIView {
    let style: RelationshipPlanet.Style
    var layout: RelationshipPlanet.Layout
    
    weak var universe: UniverseView?
    
    lazy var planetImgView: UIImageView = { UIImageView(image: UIImage(named: style.planetImgName)) }()
    weak var turntableView: PeopleTurntableView?
    lazy var titleView: PlanetTitleView = { PlanetTitleView(style: style, layout: layout, count: Self.maxPeopleCount) }()
    
    var isDebug = false { didSet { updateDebugMode() } }
    
    let btn1 = UIButton(type: .system)
    let btn2 = UIButton(type: .system)
    
    let kSwitch1 = UISwitch()
    let switchLabel1 = UILabel()
    
    let kSwitch2 = UISwitch()
    let switchLabel2 = UILabel()
    
    init(style: RelationshipPlanet.Style, layout: RelationshipPlanet.Layout) {
        self.style = style
        self.layout = layout
        super.init(frame: [0, 0, PlanetView.width, PlanetView.height])
        clipsToBounds = false
        
        let planetImgWH = Self.imageWH
        planetImgView.image = UIImage(named: style.planetImgName)
        planetImgView.frame = [HalfDiffValue(frame.width, planetImgWH),
                               HalfDiffValue(frame.height, planetImgWH),
                               planetImgWH, planetImgWH]
        planetImgView.alpha = layout.imageAlpha
        addSubview(planetImgView)
        
        titleView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(switchMainPlanet)))
        addSubview(titleView)
        
        transform = .init(scaleX: layout.scale, y: layout.scale)
        center = layout.center
        
        btn1.frame = [bounds.width * 0.5 - 70.px, 80.px, 60.px, 60.px]
        btn1.backgroundColor = .orange
        btn1.setTitle("流式", for: .normal)
        btn1.setTitleColor(.white, for: .normal)
        btn1.layer.cornerRadius = 30.px
        btn1.layer.masksToBounds = true
        btn1.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
        btn1.tag = 0
        btn1.alpha = 0
        addSubview(btn1)
        
        btn2.frame = [bounds.width * 0.5 - 70.px, bounds.height - 210.px, 60.px, 60.px]
        btn2.backgroundColor = .blue
        btn2.setTitle("转盘", for: .normal)
        btn2.setTitleColor(.white, for: .normal)
        btn2.layer.cornerRadius = 30.px
        btn2.layer.masksToBounds = true
        btn2.addTarget(self, action: #selector(btnDidClick(_:)), for: .touchUpInside)
        btn2.tag = 1
        btn2.alpha = 0
        addSubview(btn2)
        
        kSwitch1.frame.origin = [btn2.frame.origin.x + HalfDiffValue(btn2.frame.width, kSwitch1.frame.width), btn2.frame.maxY + 8.px]
        kSwitch1.isOn = true
        kSwitch1.addTarget(self, action: #selector(switchDidClick(_:)), for: .valueChanged)
        kSwitch1.tag = 0
        kSwitch1.alpha = 0
        addSubview(kSwitch1)
        
        switchLabel1.textAlignment = .center
        switchLabel1.textColor = .rgb(30, 20, 10, a: 0.8)
        switchLabel1.text = "跟随offsetY"
        switchLabel1.font = .systemFont(ofSize: 10.px)
        switchLabel1.frame = [kSwitch1.frame.maxX + 10.px, kSwitch1.frame.origin.y, 60.px, kSwitch1.frame.height]
        switchLabel1.alpha = 0
        addSubview(switchLabel1)
        
        kSwitch2.frame.origin = [kSwitch1.frame.origin.x, kSwitch1.frame.maxY + 8.px]
        kSwitch2.isOn = false
        kSwitch2.addTarget(self, action: #selector(switchDidClick(_:)), for: .valueChanged)
        kSwitch2.tag = 1
        kSwitch2.alpha = 0
        addSubview(kSwitch2)
        
        switchLabel2.textAlignment = .center
        switchLabel2.textColor = .rgb(30, 20, 10, a: 0.8)
        switchLabel2.text = "半圈·复用"
        switchLabel2.font = .systemFont(ofSize: 10.px)
        switchLabel2.frame = [kSwitch2.frame.maxX + 10.px, kSwitch2.frame.origin.y, 60.px, kSwitch2.frame.height]
        switchLabel2.alpha = 0
        addSubview(switchLabel2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard isDebug, let turntableView = self.turntableView else {
            return super.hitTest(point, with: event)
        }
        
        if btn1.frame.contains(point) ||
           btn2.frame.contains(point) ||
           titleView.frame.contains(point) ||
           kSwitch1.frame.contains(point) ||
           kSwitch2.frame.contains(point)
        {
            return super.hitTest(point, with: event)
        }
        
        // 得以`turntableView`为基准坐标系来判断
        // `tp`是`point`坐落在`turntableView`上的点
        // `turntableView.contentFullBgView.frame`是坐落于`turntableView`上的位置区域
        
        // 获取在`turntableView`上的坐标
        let tp = convert(point, to: turntableView)
        
        // 触碰点在`turntableView.contentFullBgView`的区域内才响应
        guard turntableView.contentFullBgView.frame.contains(tp) else {
            return super.hitTest(point, with: event)
        }
        
        return turntableView.hitTest(tp, with: event)
    }
}

extension PlanetView {
    @objc func switchMainPlanet() {
        guard let universe = universe else { return }
        universe.switchMainPlanet(self)
    }
    
    @objc func btnDidClick(_ sender: UIButton) {
        updateLayoutMode(sender.tag == 0)
    }
    
    @objc func switchDidClick(_ sender: UISwitch) {
        if sender.tag == 0 {
            updateIsFollowOffsetY(sender.isOn)
        } else {
            updateIsShowMore(sender.isOn)
        }
    }
}

extension PlanetView {
    func insertTurntableView(_ turntableView: PeopleTurntableView) {
        insertSubview(turntableView, belowSubview: titleView)
        self.turntableView = turntableView
    }
    
    func changeActivity(_ isActivity: Bool, completion: (() -> ())? = nil) {
        let scale: CGFloat = isActivity ? 1 : (300 / (330 + 60))
        let alpha: CGFloat = isActivity ? 1 : 0
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: []) {
            self.turntableView?.update(scale: scale, alpha: alpha)
        } completion: { _ in
            completion?()
        }
    }
}

private extension PlanetView {
    func updateDebugMode() {
        guard let universe = self.universe,
              let turntableView = self.turntableView else { return }
        
        let scale: CGFloat = isDebug ? 0.75 : 1
        let center: CGPoint = isDebug ? [universe.width * 0.4, universe.height * 0.5] : layout.center
        let btnAlpha: CGFloat = isDebug ? 1 : 0
        
        universe.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1) {
            turntableView.isDebug = self.isDebug
            self.transform = .init(scaleX: scale, y: scale)
            self.center = center
            self.btn1.alpha = btnAlpha
            self.btn2.alpha = btnAlpha
            self.kSwitch1.alpha = btnAlpha
            self.switchLabel1.alpha = btnAlpha
            self.kSwitch2.alpha = btnAlpha
            self.switchLabel2.alpha = btnAlpha
        } completion: { _ in
            universe.isUserInteractionEnabled = true
        }
    }
    
    func updateLayoutMode(_ isFlowLayout: Bool) {
        guard let universe = self.universe,
              let turntableView = self.turntableView, turntableView.isFlowLayout != isFlowLayout
        else { return }
        
        universe.isUserInteractionEnabled = false
        UIView.animate(withDuration: 1) {
            turntableView.isFlowLayout = isFlowLayout
        } completion: { _ in
            universe.isUserInteractionEnabled = true
        }
    }
    
    func updateIsFollowOffsetY(_ isFollowOffsetY: Bool) {
        guard let universe = self.universe,
              let turntableView = self.turntableView, turntableView.isFollowOffsetY != isFollowOffsetY
        else { return }
        
        UIView.transition(with: switchLabel1, duration: 0.2) {
            self.switchLabel1.text = isFollowOffsetY ? "跟随offsetY" : "不跟随offsetY"
        }
        
        universe.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            turntableView.isFollowOffsetY = isFollowOffsetY
        } completion: { _ in
            universe.isUserInteractionEnabled = true
        }
    }
    
    func updateIsShowMore(_ isShowMore: Bool) {
        guard let universe = self.universe,
              let turntableView = self.turntableView, turntableView.isShowMore != isShowMore
        else { return }
        
        UIView.transition(with: switchLabel2, duration: 0.2) {
            self.switchLabel2.text = isShowMore ? "全部·非复用" : "半圈·复用"
        }
        
        universe.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.5) {
            turntableView.isShowMore = isShowMore
        } completion: { _ in
            universe.isUserInteractionEnabled = true
        }
    }
}
