//
//  IconButtonView.swift
//  tapple
//
//  Created by 海川 和弥 on 2017/10/31.
//  Copyright © 2017年 MatchingAgent. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol IconButtonViewStyle {
    var font: UIFont { get }
    var sidePadding: CGFloat { get }
    var height: CGFloat { get }
    var imageHeight: CGFloat { get }
    var buttonHeight: CGFloat { get }
    var backgroundColorViewHeight: CGFloat { get }
    var isRoundRect: Bool { get }
}

/// 左右に画像がおくことができるButtonが必要だったので、ViewにButtonを置いて対応
final class IconButtonView: UIView {
    var data: Data? {
        didSet {
            setData(data)
            setColor(colorType: colorType)
        }
    }

    /// disable用の色にする。実際にタップは可能なまま
    ///
    /// - Parameter flag: trueならdisableの色, falseなら元の色に戻す
    var isDisableColor: Bool = false {
        didSet {
            setColor(colorType: colorType)
        }
    }

    private var colorType: ColorType? {
        didSet {
            setColor(colorType: colorType)
        }
    }

    @IBOutlet private weak var backgroundColorView: UIView!
    @IBOutlet private weak var innerView: UIView!
    @IBOutlet private weak var innerStackView: UIStackView!
    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var leftImageView: UIImageView!
    @IBOutlet private weak var rightImageView: UIImageView!
    @IBOutlet private weak var button: CCHighlightedButton!

    @IBOutlet private weak var innerViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerStackViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerStackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerStackViewCenterXConstraint: NSLayoutConstraint!
}

extension IconButtonView {
    struct Data {
        let text: String?
        let leftImage: UIImage?
        let rightImage: UIImage?

        init(text: String? = nil, leftImage: UIImage? = nil, needRightImage: Bool = false) {
            self.text = text
            self.leftImage = leftImage
            self.rightImage = needRightImage ? #imageLiteral(resourceName: "arrowGray") : nil
        }
    }

    struct ColorTheme {
        let normal: UIColor
        let highlighted: UIColor
        let title: UIColor
        let border: UIColor?
    }

    enum ColorType: ColorThemeAvailable {
        typealias ColorTheme = IconButtonView.ColorTheme
        case primary
        case secondary
        case primaryBorder
        case normal

        var colorTheme: ColorTheme {
            switch self {
            case .primary:
                return .init(normal: UIColor.tapple.pink,
                             highlighted: UIColor.tapple.darkPink,
                             title: .white,
                             border: nil)
            case .secondary:
                return .init(normal: UIColor.tapple.palePink,
                             highlighted: UIColor.tapple.lightPink,
                             title: UIColor.tapple.pink,
                             border: nil)
            case .primaryBorder:
                return .init(normal: .white,
                             highlighted: UIColor.tapple.gray5,
                             title: UIColor.tapple.pink,
                             border: UIColor.tapple.pink)
            case .normal:
                return .init(normal: .white,
                             highlighted: UIColor.tapple.gray5,
                             title: UIColor.tapple.secondaryText,
                             border: nil)
            }
        }

        var disableColorTheme: ColorTheme {
            return .init(normal: UIColor.tapple.gray5NotTransparent,
                         highlighted: UIColor.tapple.gray5NotTransparent,
                         title: UIColor.tapple.gray20,
                         border: nil)
        }
    }



    enum Style: IconButtonViewStyle {
        enum WidthType {
            case wrapContent
            case fill
            case bottom
        }

        case large(WidthType)
        case medium(WidthType)
        case small(WidthType)
        case bottom

        var widthType: WidthType {
            switch self {
            case .large(let widthType), .medium(let widthType), .small(let widthType):
                return widthType
            case .bottom:
                return .bottom
            }
        }

        var font: UIFont {
            switch self {
            case .large, .bottom:
                return .boldSystemFont(ofSize: 16)
            case .medium:
                return .boldSystemFont(ofSize: 14)
            case .small:
                return .boldSystemFont(ofSize: 13)
            }
        }

        /// 左右のマージン
        var sidePadding: CGFloat {
            switch self {
            case .large:
                return 24
            case .medium:
                return 16
            case .small:
                return 12
            case .bottom:
                // 構造上必要ないので、zero
                return 0
            }
        }

        var imageHeight: CGFloat {
            switch self {
            case .large, .medium, .small:
                return 16
            case .bottom:
                return 24
            }
        }

        var height: CGFloat {
            switch self {
            case .large:
                return 48
            case .medium:
                return 40
            case .small:
                return 28
            case .bottom:
                return 52
            }
        }

        var buttonHeight: CGFloat {
            return height
        }

        var backgroundColorViewHeight: CGFloat {
            return height
        }

        var isRoundRect: Bool {
            switch self {
            case .large, .medium, .small:
                return true
            case .bottom:
                return false
            }
        }
    }
}

extension IconButtonView {

    /// IconButtonViewを生成。用意してあるstyle以外を使いたい場合に使おう。
    ///
    /// - Parameters:
    ///   - data: 表示するdata
    ///   - customStyle: layout調整用。色々指定できる。
    ///   - colorType: 色
    static func instantiate(data: Data? = nil, customStyle: IconButtonViewStyle, colorType: ColorType) -> IconButtonView {
        let view = IconButtonView.instantiate()
        view.prepareUI(style: customStyle)
        view.colorType = colorType
        view.data = data
        return view
    }

    /// IconButtonViewを生成
    ///
    /// - Parameters:
    ///   - data: 表示するdata
    ///   - style: layout. wrapContent型を使う場合、stackViewの中に置かないと動かないので注意
    ///   - colorType: 色
    static func instantiate(data: Data? = nil, style: Style, colorType: ColorType) -> IconButtonView {
        return instantiate(data: data, customStyle: style, colorType: colorType)
    }

    var rxTap: ControlEvent<Void> {
        return button.rx.tap
    }

    private func prepareUI(style: IconButtonViewStyle) {
        if let style = style as? Style {
            layoutWidthType(style.widthType)
        }

        label.font = style.font

        [leftImageView, rightImageView].forEach { imageView in
            imageView?.heightAnchor.constraint(equalToConstant: style.imageHeight).isActive = true
            imageView?.widthAnchor.constraint(equalToConstant: style.imageHeight).isActive = true
        }

        innerViewLeftConstraint.constant = style.sidePadding
        innerViewRightConstraint.constant = style.sidePadding
        backgroundColorView.layer.masksToBounds = true
        if style.isRoundRect {
            backgroundColorView.layer.cornerRadius = style.backgroundColorViewHeight / 2
        }

        backgroundColorView.heightAnchor.constraint(equalToConstant: style.backgroundColorViewHeight).isActive = true
        button.heightAnchor.constraint(equalToConstant: style.buttonHeight).isActive = true
        heightAnchor.constraint(equalToConstant: style.height).isActive = true
    }

    private func setData(_ data: Data?) {
        let data = data ?? Data()

        label.isHidden = data.text == nil
        label.text = data.text

        let imagePairs: [(UIImageView, UIImage?)] = [(leftImageView, data.leftImage), (rightImageView, data.rightImage)]
        imagePairs.forEach { (imageView, image) in
            imageView.isHidden = image == nil
            imageView.image = image
        }
    }

    private func setColor(colorType: ColorType?) {
        guard let colorType = colorType else { return }
        let colorTheme = isDisableColor ? colorType.disableColorTheme : colorType.colorTheme
        backgroundColorView.backgroundColor = colorTheme.normal
        label.textColor = colorTheme.title

        button.mainColorView = backgroundColorView
        button.normalColor = colorTheme.normal
        button.highlightedColor = colorTheme.highlighted

        [leftImageView, rightImageView].forEach { imageView in
            imageView.image = imageView.image?.tintedImage(with: colorTheme.title)
        }

        backgroundColorView.layer.borderColor = colorTheme.border?.cgColor
        if colorType == .primaryBorder {
            backgroundColorView.layer.borderWidth = 1
        }
    }

    private func layoutWidthType(_ widthType: Style.WidthType) {
        switch widthType {
        case .wrapContent:
            // もともと3つともtrueなので、trueにする意味はあまりない
            innerStackViewLeftConstraint.isActive = true
            innerStackViewRightConstraint.isActive = true
            innerStackViewCenterXConstraint.isActive = false
        case .fill:
            innerView.addSubview(leftImageView)
            innerView.addSubview(label)
            innerView.addSubview(rightImageView)

            leftImageView.leftAnchor.constraint(equalTo: innerView.leftAnchor).isActive = true
            rightImageView.rightAnchor.constraint(equalTo: innerView.rightAnchor).isActive = true
            label.centerXAnchor.constraint(equalTo: innerView.centerXAnchor).isActive = true
            leftImageView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor).isActive = true
            rightImageView.centerYAnchor.constraint(equalTo: innerView.centerYAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: innerView.centerYAnchor).isActive = true
        case .bottom:
            // もともと3つともtrueなので、trueにする意味はあまりない
            innerStackViewLeftConstraint.isActive = false
            innerStackViewRightConstraint.isActive = false
            innerStackViewCenterXConstraint.isActive = true
        }
    }
}
