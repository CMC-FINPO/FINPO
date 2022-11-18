//
//  ServiceTypeCollectionViewCell.swift
//  FINPO
//
//  Created by 이동희 on 2022/07/03.
//

import Foundation
import UIKit
import SnapKit

class PolicyTypeCollectionViewCell: UICollectionViewCell {
    let tagLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.font = UIFont(name: "AppleSDGothicNeo-Medium", size: 14)
        label.textColor = UIColor(hexString: "5B43EF")
        label.backgroundColor = UIColor(hexString: "F0F0F0")
        label.topInset = 3
        label.bottomInset = 3
        label.rightInset = 3
        label.leftInset = 3
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().inset(1)
            $0.trailing.greaterThanOrEqualToSuperview().inset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
   
    }
}
