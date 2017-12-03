//
//  ViewController.swift
//  buttonSample
//
//  Created by kazuya umikawa on 2017/12/03.
//  Copyright © 2017年 sun54907. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalCentering
        self.view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = UIColor.init(white: 0.3, alpha: 0.5)
        
        if #available(iOS 11.0, *) {
            stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        } else {
            stackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
            stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
            stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        }
        
        let iconButtonView = IconButtonView.create(data: .init(title: "クリック"), style: .medium(.wrapContent), colorType: .primary)
        stackView.addArrangedSubview(iconButtonView)

        let iconButtonView2 = IconButtonView.create(data: .init(title: "クリック", leftImage: #imageLiteral(resourceName: "camera")), style: .large(.wrapContent), colorType: .secondary)
        stackView.addArrangedSubview(iconButtonView2)

        let iconButtonView3 = IconButtonView.create(data: .init(title: "クリック", leftImage: #imageLiteral(resourceName: "camera"), rightImage: #imageLiteral(resourceName: "mail")), style: .large(.wrapContent), colorType: .primaryBorder)
        stackView.addArrangedSubview(iconButtonView3)

        let iconButtonView4 = IconButtonView.create(data: .init(title: "クリック"), style: .small(.wrapContent), colorType: .normal)
        stackView.addArrangedSubview(iconButtonView4)
    }
}

