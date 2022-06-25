//
//  AddPurposeCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/06/25.
//

import Foundation
import UIKit
import SnapKit

class AddPurposeCollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var statusButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor(hexString: "000000"), for: .normal)
        button.setTitleColor(UIColor(hexString: "FFFFFF"), for: .selected)
        button.setBackgroundColor(UIColor(hexString: "F0F0F0"), for: .normal)
        button.setBackgroundColor(UIColor(hexString: "5B43EF"), for: .selected)
        button.titleLabel?.font = UIFont(name: "AppleSDGothicNeo-SemiBold", size: 16)
        return button
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.layer.cornerRadius = 3
    }
    
    func setup() {
        contentView.backgroundColor = UIColor(hexString: "F0F0F0")
        contentView.addSubview(statusButton)
        statusButton.snp.makeConstraints {
            $0.center.equalTo(contentView.snp.center)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            
        }
    }
    
}
