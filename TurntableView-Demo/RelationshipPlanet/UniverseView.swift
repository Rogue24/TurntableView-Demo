//
//  UniverseView.swift
//  Neves
//
//  Created by zhoujianping on 2022/9/1.
//

class UniverseView: UIView {
    
    let turntableView = PeopleTurntableView()
    
    let bosomFriendPlanet = PlanetView(style: .bosomFriend, layout: .main)
    let confidantePlanet = PlanetView(style: .confidante, layout: .rightTop)
    let bestFriendPlanet = PlanetView(style: .bestFriend, layout: .rightMid)
    let masterApprenticePlanet = PlanetView(style: .masterApprentice, layout: .rightBottom)
    
    lazy var allPlanet: [PlanetView] = [bosomFriendPlanet, confidantePlanet, bestFriendPlanet, masterApprenticePlanet]
    lazy var mainPlanet: PlanetView = bosomFriendPlanet
    
    init() {
        super.init(frame: .init(origin: .zero, size: UniverseView.size))
        backgroundColor = .rgb(30, 27, 43)
        
        bosomFriendPlanet.universe = self
        confidantePlanet.universe = self
        bestFriendPlanet.universe = self
        masterApprenticePlanet.universe = self
        
        addSubview(bosomFriendPlanet)
        addSubview(confidantePlanet)
        addSubview(bestFriendPlanet)
        addSubview(masterApprenticePlanet)
        
        bosomFriendPlanet.layer.zPosition = 1
        bosomFriendPlanet.insertTurntableView(turntableView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UniverseView {
    func switchMainPlanet(_ fromPlanet: PlanetView) {
        guard fromPlanet.layout.location != .main else {
            switchDebugMode(fromPlanet)
            return
        }
        
        isUserInteractionEnabled = false
        
        let leavePlant = mainPlanet
        
        let fromLayout = fromPlanet.layout
        let mainLayout = mainPlanet.layout
        
        leavePlant.layout = fromLayout
        fromPlanet.layout = mainLayout
        mainPlanet = fromPlanet
        
        let duration: TimeInterval = Self.switchPlanetDuration
        let controlPoints = getControlPoints(from: fromLayout, to: mainLayout)
        let toMainAnim = createPathAnimation(from: fromLayout.center, to: mainLayout.center,
                                             controlPoint: controlPoints.toMain,
                                             duration: duration)
        let leaveAnim = createPathAnimation(from: mainLayout.center, to: fromLayout.center,
                                            controlPoint: controlPoints.leave,
                                            duration: duration)
        
        leavePlant.changeActivity(false)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock(nil)
        fromPlanet.layer.add(toMainAnim, forKey: "position")
        leavePlant.layer.add(leaveAnim, forKey: "position")
        CATransaction.commit()
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut) {
            fromPlanet.layer.zPosition = 2
            fromPlanet.transform = .init(scaleX: mainLayout.scale, y: mainLayout.scale)
            fromPlanet.planetImgView.alpha = mainLayout.imageAlpha
            fromPlanet.titleView.updateLayout(mainLayout, isInAnimated: true)

            leavePlant.layer.zPosition = 1
            leavePlant.transform = .init(scaleX: fromLayout.scale, y: fromLayout.scale)
            leavePlant.planetImgView.alpha = fromLayout.imageAlpha
            leavePlant.titleView.updateLayout(fromLayout, isInAnimated: true)
            
        } completion: { _ in
            self.allPlanet.forEach { $0.turntableView = nil }
            self.isUserInteractionEnabled = true
            
            fromPlanet.layer.removeAllAnimations()
            fromPlanet.layer.zPosition = 1
            fromPlanet.center = mainLayout.center
            fromPlanet.insertTurntableView(self.turntableView)
            fromPlanet.changeActivity(true)
            
            leavePlant.layer.removeAllAnimations()
            leavePlant.layer.zPosition = 0
            leavePlant.center = fromLayout.center
        }
    }
    
    private func getControlPoints(from fromLayout: RelationshipPlanet.Layout,
                                  to mainLayout: RelationshipPlanet.Layout) -> (toMain: CGPoint, leave: CGPoint) {
        var toMainControlPoint: CGPoint = .zero
        var leaveControlPoint: CGPoint = .zero
        
        switch fromLayout.location {
        case .rightTop:
            toMainControlPoint.x = fromLayout.center.x
            toMainControlPoint.y = mainLayout.center.y + 100.px
            
            leaveControlPoint.x = mainLayout.center.x
            leaveControlPoint.y = fromLayout.center.y - 100.px
            
        case .rightMid:
            toMainControlPoint.x = mainLayout.center.x + 50.px
            toMainControlPoint.y = mainLayout.center.y + 300.px
            
            leaveControlPoint.x = fromLayout.center.x - 50.px
            leaveControlPoint.y = fromLayout.center.y - 300.px
            
        case .rightBottom:
            toMainControlPoint.x = mainLayout.center.x
            toMainControlPoint.y = fromLayout.center.y + 80.px
            
            leaveControlPoint.x = fromLayout.center.x
            leaveControlPoint.y = mainLayout.center.y - 80.px
            
        default:
            break
        }
        
        return (toMainControlPoint, leaveControlPoint)
    }
    
    private func createPathAnimation(from: CGPoint,
                                     to: CGPoint,
                                     controlPoint: CGPoint,
                                     duration: TimeInterval) -> CAKeyframeAnimation {
        let path = UIBezierPath()
        path.move(to: from)
        path.addQuadCurve(to: to, controlPoint: controlPoint)
        
        let anim = CAKeyframeAnimation(keyPath: "position")
        anim.path = path.cgPath
        anim.fillMode = .forwards
        anim.isRemovedOnCompletion = false
        anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        anim.duration = duration
        return anim
    }
}

extension UniverseView {
    func switchDebugMode(_ fromPlanet: PlanetView) {
        isUserInteractionEnabled = false
        fromPlanet.isDebug.toggle()
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut) {
            self.allPlanet.forEach {
                guard $0 != self.mainPlanet else { return }
                $0.alpha = fromPlanet.isDebug ? 0 : 1
            }
        } completion: { _ in
            self.isUserInteractionEnabled = true
        }
    }
}
