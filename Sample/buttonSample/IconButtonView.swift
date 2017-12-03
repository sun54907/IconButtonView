//
//  IconButtonView.swift
//  tapple
//
//  Created by 海川 和弥 on 2017/10/31.
//  Copyright © 2017年 MatchingAgent. All rights reserved.
//

import UIKit

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
    @IBOutlet private weak var button: HighlightedButton!

    @IBOutlet private weak var innerViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerStackViewLeftConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerStackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var innerStackViewCenterXConstraint: NSLayoutConstraint!
}

extension IconButtonView {
    struct Data {
        let title: String?
        let leftImage: UIImage?
        let rightImage: UIImage?

        init(title: String? = nil, leftImage: UIImage? = nil, rightImage: UIImage? = nil) {
            self.title = title
            self.leftImage = leftImage
            self.rightImage = rightImage
        }
    }

    struct ColorTheme {
        let normal: UIColor
        let highlighted: UIColor
        let title: UIColor
        let border: UIColor?
    }

    enum ColorType {
        typealias ColorTheme = IconButtonView.ColorTheme
        case primary
        case secondary
        case primaryBorder
        case normal

        var colorTheme: ColorTheme {
            switch self {
            case .primary:
                return .init(normal: UIColor.red,
                             highlighted: UIColor.red.lighter()!,
                             title: .white,
                             border: nil)
            case .secondary:
                return .init(normal: UIColor.orange,
                             highlighted: UIColor.orange.lighter()!,
                             title: UIColor.orange.darker()!,
                             border: nil)
            case .primaryBorder:
                return .init(normal: .white,
                             highlighted: UIColor.gray,
                             title: UIColor.red,
                             border: UIColor.red)
            case .normal:
                return .init(normal: .white,
                             highlighted: UIColor.lightGray,
                             title: UIColor.gray,
                             border: nil)
            }
        }

        var disableColorTheme: ColorTheme {
            return .init(normal: UIColor.lightGray,
                         highlighted: UIColor.lightGray,
                         title: UIColor.darkGray,
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
    static func create(data: Data? = nil, customStyle: IconButtonViewStyle, colorType: ColorType) -> IconButtonView {
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
    static func create(data: Data? = nil, style: Style, colorType: ColorType) -> IconButtonView {
        return create(data: data, customStyle: style, colorType: colorType)
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

        label.isHidden = data.title == nil
        label.text = data.title

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
            imageView?.image = imageView?.image?.withRenderingMode(.alwaysTemplate)
            imageView?.tintColor = colorTheme.title
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

// MARK: - other extensions

extension UIColor {

    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }

    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }

    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

extension NSObject {
    class func instantiate(nibName nameOrNil: String? = nil, bundle bundleOrNil: Bundle? = nil, withOwner ownerOrNil: Any? = nil, options optionsOrNil: [AnyHashable : Any]? = nil) -> Self {
        let nibName = (nameOrNil ?? "\(self)")
        return UINib.instantiate(type:self, nibName:nibName, bundle:bundleOrNil, withOwner:ownerOrNil, options:optionsOrNil)!
    }
}


extension UINib {
    class func instantiate<T>(type:T.Type, nibName name: String, bundle bundleOrNil: Bundle?, withOwner ownerOrNil: Any?, options optionsOrNil: [AnyHashable : Any]? = nil) -> T? {

        for any in self.init(nibName:name, bundle:bundleOrNil).instantiate(withOwner:ownerOrNil, options:optionsOrNil) {
            if let obj = any as? T {
                return obj
            }
        }
        return nil
    }
}

