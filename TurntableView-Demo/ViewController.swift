//
//  ViewController.swift
//  TurntableView-Demo
//
//  Created by 周健平 on 2022/9/21.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rgb(30, 27, 43)
        
        let titleLabel = UILabel()
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 20.px, weight: .semibold)
        titleLabel.text = "点击主星球名字切换Debug模式"
        titleLabel.sizeToFit()
        titleLabel.frame.origin = [15.px, NavTopMargin]
        view.addSubview(titleLabel)
        
        let universeView = UniverseView()
        universeView.y = PortraitScreenHeight - DiffTabBarH - universeView.height - 80
        view.addSubview(universeView)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
}

