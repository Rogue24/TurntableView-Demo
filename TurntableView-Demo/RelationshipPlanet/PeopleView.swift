//
//  PeopleView.swift
//  Neves
//
//  Created by zhoujianping on 2022/8/31.
//

class PeopleView: UIView {
    let nameH: CGFloat = 16.5.px
    let relH: CGFloat = 16.5.px
    let relLevelIconWH: CGFloat = 11.3.px
    let relNumIconWH: CGFloat = 13.px
    lazy var infoSize: CGSize = [100.px, nameH + 4.px + relH]
    
    let lineBgView = UIView()
    let userIcon = UIImageView(image: UIImage(named: "jp_icon"))
    let infoView = UIView()
    
    let tagLabel = UILabel()
    
    let nameLabel = UILabel()
    let relLevelIcon = UIImageView(image: UIImage(named: "gxq_lv5"))
    let relBgView = GradientView()
    let relLabel = UILabel()
    let relNumIcon = UIImageView(image: UIImage(named: "gxq_icon_qmz"))
    let relNumLabel = UILabel()
    
    var index: Int = -1
    
    init() {
        super.init(frame: [0, 0, PeopleView.width, PeopleView.height])
        alpha = 0
        
        let peopleIconWH = Self.iconWH
        layer.anchorPoint = [peopleIconWH * 0.5 / frame.width, 0.5]
        
        let lineSize: CGSize = [20.px, 1.px]
        let lineSpace: CGFloat = 5.px
        lineBgView.layer.anchorPoint = [1, 0.5]
        lineBgView.frame = [-lineSize.width - lineSpace, HalfDiffValue(frame.height, lineSize.height), lineSize.width + lineSpace + peopleIconWH * 0.5, lineSize.height]
        addSubview(lineBgView)
        
        let line = CAGradientLayer()
        line.frame = .init(origin: .zero, size: lineSize)
        line.startPoint = [0, 0.5]
        line.endPoint = [1, 0.5]
        line.colors = [UIColor.clear.cgColor, UIColor(white: 1, alpha: 1).cgColor, UIColor.clear.cgColor]
        line.opacity = 0.5
        lineBgView.layer.addSublayer(line)
        
        userIcon.frame = [0, 0, peopleIconWH, peopleIconWH]
        userIcon.layer.cornerRadius = peopleIconWH * 0.5
        userIcon.layer.masksToBounds = true
        userIcon.contentMode = .scaleAspectFill
        addSubview(userIcon)
        
        infoView.frame = [userIcon.frame.maxX + 10.px,HalfDiffValue(frame.height, infoSize.height), infoSize.width, infoSize.height]
        infoView.clipsToBounds = false
        addSubview(infoView)
        
        nameLabel.frame = [0, 0, infoSize.width * 2, nameH]
        nameLabel.font = .systemFont(ofSize: 12.px)
        nameLabel.textColor = .init(white: 1, alpha: 0.8)
        infoView.addSubview(nameLabel)
        
        let y: CGFloat = infoSize.height - relH
        relLevelIcon.frame = [1.px, y + HalfDiffValue(relH, relLevelIconWH), relLevelIconWH, relLevelIconWH]
        infoView.addSubview(relLevelIcon)
        
        relLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
        relLabel.text = "宝贝"
        relLabel.sizeToFit()
        relLabel.frame.size.height = relH
        
        relBgView
            .startPoint(0, 0.5)
            .endPoint(1, 0.5)
            .colors(.rgb(117, 138, 255), .rgb(116, 211, 255))
        relBgView.addSubview(relLabel)
        relBgView.mask = relLabel
        relBgView.frame = [relLevelIcon.frame.maxX + 5.px, y, relLabel.frame.width, relLabel.frame.height]
        infoView.addSubview(relBgView)
        
        relNumIcon.frame = [relBgView.maxX + 10.px, y + HalfDiffValue(relH, relNumIconWH), relNumIconWH, relNumIconWH]
        infoView.addSubview(relNumIcon)
        
        relNumLabel.font = .systemFont(ofSize: 12.px, weight: .medium)
        relNumLabel.text = "9999"
        relNumLabel.textColor = .init(white: 1, alpha: 0.5)
        relNumLabel.sizeToFit()
        relNumLabel.frame = [relNumIcon.maxX + 4.px, y, relNumLabel.frame.width, relH]
        infoView.addSubview(relNumLabel)
        
        tagLabel.frame = userIcon.bounds
        tagLabel.font = .boldSystemFont(ofSize: 15.px)
        tagLabel.textColor = .magenta
        tagLabel.textAlignment = .center
        
        tagLabel.alpha = 0
        userIcon.addSubview(tagLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func resetFlowLayout(index: Int, focusIndex: Int?) {
        guard self.index != index else { return }
        self.index = index
        nameLabel.text = "健了个平 - \(index)"
        tagLabel.text = "\(index)"
        
        center = [PlanetView.circlePoint.x + 150.px,
                  PeopleView.height * 0.5 + (PeopleView.height + 10.px) * CGFloat(index)]
        
        if let focusIndex = focusIndex {
            alpha = focusIndex == index ? 1 : 0
        } else {
            alpha = 1
        }
        
        lineBgView.transform = CGAffineTransform(rotationAngle: 0)
        infoView.alpha = 1
        tagLabel.alpha = 1
    }
    
    func updateLayout(_ layout: Layout?) {
        guard let layout = layout else {
            alpha = 0
            index = -1
            return
        }
        
        center = layout.center
        lineBgView.transform = layout.lineTransform
        infoView.alpha = layout.infoAlpha
        
        guard index != layout.index else { return }
        index = layout.index
        nameLabel.text = "健了个平 - \(index)"
        tagLabel.text = "\(index)"
        
        alpha = layout.isDebug ? 0.35 : 1
        tagLabel.alpha = layout.isDebug ? 1 : 0
    }
}

extension PeopleView {
    struct Layout {
        let index: Int
        let center: CGPoint
        let infoAlpha: CGFloat
        let lineTransform: CGAffineTransform
        
        let isDebug: Bool
        
        static func build(index: Int, radian: CGFloat, offsetY: CGFloat, isDebug: Bool, isFollowOffsetY: Bool) -> Layout {
            let singlePeopleOffsetY = PeopleTurntableView.singlePeopleOffsetY
            let minHideOffsetY = CGFloat(index) * singlePeopleOffsetY - singlePeopleOffsetY
            let minShowOffsetY = CGFloat(index) * singlePeopleOffsetY
            
            let circlePoint = PlanetView.circlePoint
            let radius = PlanetView.radius
            let singleItemOffsetY = PeopleTurntableView.singlePeopleOffsetY
            let halfRoundOffsetY = PeopleTurntableView.halfRoundContentHeight // 转半圈所需偏移量
            
            // 中心点
            let centerX = circlePoint.x + radius * cos(radian)
            let centerY = circlePoint.y + radius * sin(radian)
            let diffY = (!isDebug || isFollowOffsetY) ? offsetY : 0
            let center: CGPoint = [centerX, diffY + centerY]

            // 线的角度和显示
            let lineTransform = CGAffineTransform(rotationAngle: radian)

            // 信息的透明度
            var infoAlpha: CGFloat = 1
            if offsetY > minHideOffsetY {
                infoAlpha = 1 - (offsetY - minHideOffsetY) / singleItemOffsetY
            } else {
                let oy = offsetY + halfRoundOffsetY
                if oy > minShowOffsetY {
                    infoAlpha = (oy - minShowOffsetY) / singleItemOffsetY
                } else {
                    infoAlpha = 0
                }
            }
            if infoAlpha < 0 {
                infoAlpha = 0
            } else if infoAlpha > 1 {
                infoAlpha = 1
            }
            
            return Layout(index: index,
                          center: center,
                          infoAlpha: infoAlpha,
                          lineTransform: lineTransform,
                          isDebug: isDebug)
        }
    }
}
