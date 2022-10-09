//
//  UnderlineSegmentedControl.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/14.
//

import Foundation
import UIKit

final class UnderlineSegmentedControl: UISegmentedControl {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.removeBackgroundAndDivider()
    }
    
    override init(items: [Any]?) {
        super.init(items: items)
        self.removeBackgroundAndDivider()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func removeBackgroundAndDivider() {
        let image = UIImage()
        self.setBackgroundImage(image, for: .normal, barMetrics: .default)
        self.setBackgroundImage(image, for: .selected, barMetrics: .default)
        self.setBackgroundImage(image, for: .highlighted, barMetrics: .default)
        
        let normalFont = UIFont(name: "AppleSDGothicNeo-Medium", size: 13)
        let selectedFont = UIFont(name: "AppleSDGothicNeo-Semibold", size: 13)
        self.setTitleTextAttributes([NSAttributedString.Key.font: normalFont as Any], for: .normal)
        self.setTitleTextAttributes([NSAttributedString.Key.font: selectedFont as Any], for: .selected)
        self.setTitleTextAttributes([NSAttributedString.Key.font: selectedFont as Any], for: .highlighted)
        
        self.setDividerImage(image, forLeftSegmentState: .selected, rightSegmentState: .normal, barMetrics: .default)
    }
    
    private lazy var underlineView: UIView = {
        let width = self.bounds.size.width / CGFloat(self.numberOfSegments) - 10
        let height = 3.0
        let xPosition = CGFloat(self.selectedSegmentIndex * Int(width))
        let yPosition = self.bounds.size.height - 2.0
        let frame = CGRect(x: xPosition, y: yPosition, width: width, height: height)
        let view = UIView(frame: frame)
        view.backgroundColor = UIColor.P01
        self.addSubview(view)
        return view
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let underlineFinalXPosition = (self.bounds.width / CGFloat(self.numberOfSegments)) * CGFloat(self.selectedSegmentIndex)
        UIView.animate(
            withDuration: 0.3) {
                self.underlineView.frame.origin.x = underlineFinalXPosition
            }
    }
    
}
