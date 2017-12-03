//
//  Copyright © 2017年 MatchingAgent. All rights reserved.
//
import UIKit
import MapKit


//============================================================
// MARK: - Obj-C highlightedフラグ

private extension UIView {
    /// Obj-Cの `@property BOOL highlighted;` または
    /// `- (void)setHighlighted:(BOOL)highlighted;` にアクセスするための拡張。
    func setHighlighted(_ highlighted: Bool) {
    }
}


//============================================================
// MARK: - Swift isHighlightedフラグ

/// Swiftの`isHighlighted`フラグにアクセスするためのプロトコル。
protocol HighlightedButtonHighlightable : class {
    var isHighlighted: Bool {get set}
}
/// 既知のisHighlightedをprotocol採用済みにしておく。
extension UICollectionViewCell : HighlightedButtonHighlightable {}
extension UIControl : HighlightedButtonHighlightable {}
extension UIImageView : HighlightedButtonHighlightable {}
extension UILabel : HighlightedButtonHighlightable {}
extension UITableViewCell : HighlightedButtonHighlightable {}
extension MKAnnotationView : HighlightedButtonHighlightable {}


//============================================================
// MARK: - Buttonクラス
class HighlightedButton: UIButton {
    
    //==============================
    // MARK:- Inspectable
    
    @IBInspectable var highlightedAttributedTextColor: UIColor?
    @IBInspectable var mainLabelHeightDiff: CGFloat = 2
    @IBInspectable var normalColor: UIColor?
    @IBInspectable var highlightedColor: UIColor?
    @IBInspectable var disableColor: UIColor?
    
    //==============================
    // MARK:- Outlet
    
    @IBOutlet weak var hoverView: UIView?
    @IBOutlet weak var mainColorView: UIView?
    @IBOutlet weak var mainLabel: UILabel?
    /// self.highlightedに連動するView。
    /// 上記の、Obj-CのsetHighlighted または SwiftでHighlightedButtonHighlightable採用 が必要。
    @IBOutlet var highlightedViews: [UIView]!
    
    //==============================
    // MARK:- init/deinit
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Swiftでも、"isHighlighted"でなく"highlighted"でないとObserveしないようだ
        self.addObserver(self, forKeyPath:"highlighted", options:[.new,.old], context:nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        
        self.addObserver(self, forKeyPath:"highlighted", context:nil)
    }
    
    deinit {
        self.removeObserver(self, forKeyPath:"highlighted")
    }
    
    //==============================
    // MARK:- private
    
    private var attributedString: NSAttributedString?
    
    //==============================
    // MARK:- UIControl
    
    override var isEnabled: Bool {
        didSet {
            if let normalC = self.normalColor, let disableC = self.disableColor {
                let colorView = self.mainColorView ?? self
                colorView.backgroundColor = self.isEnabled ? normalC : disableC
            }
        }
    }
    
    //==============================
    // MARK:- NSKeyValueObserving
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let isChanged: Bool
        if let newVal = change?[.newKey] as? Bool, let oldVal = change?[.oldKey] as? Bool {
            isChanged = (newVal != oldVal)
        } else {
            isChanged = true
        }
        guard isChanged else{
            return
        }
        // 変更があった場合
        self.hoverView?.isHidden = !self.isHighlighted
        
        for vw in self.highlightedViews ?? [] {
            (vw as? HighlightedButtonHighlightable)?.isHighlighted = self.isHighlighted
            vw.setHighlighted(self.isHighlighted)
        }
        // 背景の色を変える
        if let normalC = self.normalColor, let highlightedC = self.highlightedColor {
            let colorView = self.mainColorView ?? self
            colorView.backgroundColor = self.isHighlighted ? highlightedC : normalC
        }
        
        if let mainL = self.mainLabel {
            // 縦にdiff分だけ動かす
            var frame = mainL.frame
            if self.isHighlighted {
                frame.origin.y += self.mainLabelHeightDiff
            } else {
                frame.origin.y -= self.mainLabelHeightDiff
            }
            mainL.frame = frame
            
            // ラベルの色を変える
            if let highlightedAttrTxtC = self.highlightedAttributedTextColor {
                if self.isHighlighted {
                    // 色を変える
                    self.attributedString = mainL.attributedText
                    let attributedText:NSMutableAttributedString? = mainL.attributedText?.mutableCopy() as? NSMutableAttributedString
                    attributedText?.addAttribute(.foregroundColor, value:highlightedAttrTxtC, range:NSRange(location:0, length:mainL.text?.count ?? 0))
                    mainL.attributedText = attributedText
                    
                } else {
                    // 色を戻す
                    mainL.attributedText = self.attributedString
                }
            } else {
                mainL.isHighlighted = self.isHighlighted
            }
        }
    }
}
