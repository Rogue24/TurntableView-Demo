//
//  PlanetTitleView.swift
//  Neves
//
//  Created by zhoujianping on 2022/9/2.
//

class PlanetTitleView: UIView {
    
    let nameLabel = UILabel()
    let countLabel = UILabel()
    
    let nameView = GradientView()
    let countView = GradientView()
    
    let style: RelationshipPlanet.Style
    
    init(style: RelationshipPlanet.Style, layout: RelationshipPlanet.Layout, count: Int) {
        self.style = style
        super.init(frame: [0, 0, 46.px, (32.5 + 3 + 25.5).px])
        
        nameLabel.font = .systemFont(ofSize: 23.px, weight: .bold)
        nameLabel.text = style.title
        nameLabel.sizeToFit()
        nameLabel.height = 32.5.px
        
        nameView.startPoint(0, 0.5).endPoint(1, 0.5)
        nameView.frame = [HalfDiffValue(width, nameLabel.width), 0, nameLabel.width, nameLabel.height]
        nameView.addSubview(nameLabel)
        nameView.mask = nameLabel
        addSubview(nameView)
        
        countView.startPoint(0, 0.5).endPoint(1, 0.5)
        countView.addSubview(countLabel)
        countView.mask = countLabel
        addSubview(countView)
        
        updateLayout(layout, count: count, isInAnimated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(_ layout: RelationshipPlanet.Layout, count: Int? = nil, isInAnimated: Bool) {
        var scale = layout.location == .main ? 1 : (1 / layout.scale)
        scale *= layout.titleScale
        
        let colors = layout.titleColors(style: style).map { $0.cgColor }
        let diffCenterX = layout.location == .main ? (20.px + 46.px * 0.5) : 0
        
        defer {
            changeGradientColors(colors, animated: isInAnimated)
            alpha = layout.titleAlpha
            transform = .init(scaleX: scale, y: scale)
            center = [PlanetView.width * 0.5 + diffCenterX, PlanetView.height * 0.5]
        }
        
        var countX: CGFloat = layout.location == .main ? nameView.x : HalfDiffValue(width, countView.width)
        guard let count = count else {
            countView.x = countX
            return
        }
        
        guard count > 0 else {
            nameView.y = HalfDiffValue(height, nameView.height)
            
            countView.x = countX
            countView.alpha = 0
            return
        }
        
        let countStr = "\(count) 人"
        let countAttStr = NSMutableAttributedString(string: countStr, attributes: [.font: UIFont(name: "DINAlternate-Bold", size: 22.px)!])
        countAttStr.addAttributes([.font: UIFont.systemFont(ofSize: 11.px, weight: .bold), .baselineOffset: 1.px], range: NSMakeRange(countStr.count - 1, 1))
        
        countLabel.attributedText = countAttStr
        countLabel.sizeToFit()
        countLabel.height = 25.5.px
        
        nameView.y = 0
        if layout.location != .main { countX = HalfDiffValue(width, countLabel.width) }
        countView.frame = [countX, nameView.maxY + 3.px, countLabel.width, countLabel.height]
        countView.alpha = 1
    }
    
    private func changeGradientColors(_ colors: [CGColor], animated: Bool) {
        if animated {
            let colorAnim1 = CABasicAnimation(keyPath: "colors")
            colorAnim1.toValue = colors
            colorAnim1.fillMode = .forwards
            colorAnim1.isRemovedOnCompletion = false
            colorAnim1.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            colorAnim1.duration = UniverseView.switchPlanetDuration
            
            let colorAnim2 = CABasicAnimation(keyPath: "colors")
            colorAnim2.toValue = colors
            colorAnim2.fillMode = .forwards
            colorAnim2.isRemovedOnCompletion = false
            colorAnim2.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            colorAnim2.duration = UniverseView.switchPlanetDuration
            
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                self.nameView.gLayer.colors = colors
                self.countView.gLayer.colors = colors
            }
            nameView.gLayer.add(colorAnim1, forKey: "colors")
            countView.gLayer.add(colorAnim2, forKey: "colors")
            CATransaction.commit()
        } else {
            nameView.gLayer.colors = colors
            countView.gLayer.colors = colors
        }
    }
}
