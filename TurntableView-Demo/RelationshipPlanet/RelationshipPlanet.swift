//
//  RelationshipPlanet.swift
//  Neves
//
//  Created by zhoujianping on 2022/8/31.
//

enum RelationshipPlanet {
    
    enum Style {
        /// 挚友
        case bosomFriend
        /// 闺蜜
        case confidante
        /// 死党
        case bestFriend
        /// 师徒
        case masterApprentice
        
        var title: String {
            switch self {
            case .bosomFriend: return "挚友"
            case .confidante: return "闺蜜"
            case .bestFriend: return "死党"
            case .masterApprentice: return "师徒"
            }
        }
        
        var planetImgName: String {
            switch self {
            case .bosomFriend: return "gxq_rk_zhiyou"
            case .confidante: return "gxq_rk_guimi"
            case .bestFriend: return "gxq_rk_sidang"
            case .masterApprentice: return "gxq_rk_shitu"
            }
        }
    }
    
    enum Location {
        case main
        case rightTop
        case rightMid
        case rightBottom
    }
    
    struct Layout {
        let location: Location
        let scale: CGFloat
        let center: CGPoint
        let imageAlpha: CGFloat
        let titleAlpha: CGFloat
        let titleScale: CGFloat
        
        func titleColors(style: Style) -> [UIColor] {
            switch location {
            case .main:
                switch style {
                case .bosomFriend: return [.rgb(62, 43, 93), .rgb(62, 43, 93)]
                case .confidante: return [.rgb(106, 49, 31), .rgb(106, 49, 31)]
                case .bestFriend: return [.rgb(51, 77, 52), .rgb(51, 77, 52)]
                case .masterApprentice: return [.rgb(36, 53, 79), .rgb(36, 53, 79)]
                }
                
            default:
                switch style {
                case .bosomFriend: return [.rgb(120, 152, 255), .rgb(211, 105, 255)]
                case .confidante: return [.rgb(255, 105, 150), .rgb(255, 184, 149)]
                case .bestFriend: return [.rgb(120, 255, 246), .rgb(255, 230, 105)]
                case .masterApprentice: return [.rgb(117, 138, 255), .rgb(116, 211, 255)]
                }
            }
        }
        
        static let main = Layout(location: .main,
                                 scale: 1,
                                 center: [0, 185.px + PlanetView.imageWH * 0.5],
                                 imageAlpha: 1,
                                 titleAlpha: 1,
                                 titleScale: 1)
        
        static let rightTop = Layout(location: .rightTop,
                                     scale: 70.px / PlanetView.imageWH,
                                     center: [UniverseView.size.width - 95.px - 70.px * 0.5,
                                              CGFloat(85.px + 70.px * 0.5)],
                                     imageAlpha: 0.3,
                                     titleAlpha: 0.3,
                                     titleScale: 12.px / 23.px)
        
        static let rightMid = Layout(location: .rightMid,
                                     scale: 140.px / PlanetView.imageWH,
                                     center: [UniverseView.size.width - (140.px * 0.5 - 45.px),
                                              CGFloat(185.px + 140.px * 0.5)],
                                     imageAlpha: 0.5,
                                     titleAlpha: 0.7,
                                     titleScale: 18.px / 23.px)
        
        static let rightBottom = Layout(location: .rightBottom,
                                        scale: 100.px / PlanetView.imageWH,
                                        center: [UniverseView.size.width - 30.px - 100.px * 0.5,
                                                 CGFloat(464.px + 100.px * 0.5)],
                                        imageAlpha: 0.4,
                                        titleAlpha: 0.3,
                                        titleScale: 15.px / 23.px)
    }
    
}

extension UniverseView {
    static let size: CGSize = [PortraitScreenWidth, 604.px]
    static let switchPlanetDuration: TimeInterval = 1
}

extension PlanetView {
    static let radius: CGFloat = 165.px // 330 这个半径是到了头像的中点
    static let width: CGFloat = (radius + PeopleView.width - PeopleView.iconWH * 0.5) * 2
    static let height: CGFloat = (radius + PeopleView.height - PeopleView.iconWH * 0.5) * 2
    static let circlePoint: CGPoint = [width * 0.5, height * 0.5]
    static let imageWH: CGFloat = 300.px
    static let maxPeopleCount: Int = 200
}

extension PeopleView {
    static let iconWH: CGFloat = 30.px
    static let width: CGFloat = iconWH + (10 + 100).px
    static var height: CGFloat { iconWH }
}

extension PeopleTurntableView {
    static let oneRoundPeopleCount: Int = 12 // 一圈12个，一屏显示半圈，也就是6个
    static let oneRoundContentHeight = halfRoundContentHeight * 2 // 转动一圈所需的内容高度（一圈12个，一屏6个，滚一屏高度就是50%进度，所以两屏高度就是刚好能滚一圈的最佳内容高度）
    static var halfRoundContentHeight: CGFloat { PlanetView.height }
    
    static let singlePeopleRadian: CGFloat = CGFloat.radian360 / CGFloat(oneRoundPeopleCount) // 360° / 12 = 30°
    static let singlePeopleOffsetY: CGFloat = oneRoundContentHeight / CGFloat(oneRoundPeopleCount)
    
    static let maxPeopleViewCount: Int = 8 // 
}
